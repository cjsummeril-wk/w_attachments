import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_common/disposable.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';

import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/highlight_styles.dart';
import 'package:w_attachments_client/src/payloads/module_actions.dart';

class ExtensionContextAdapter extends Disposable {
  final AttachmentsActions _actions;
  final cef.ExtensionContext _extensionContext;
  final AttachmentsStore _store;
  cef.Selection _currentSelection;
  Iterable<String> _currentScopes = [];
  int _currentlyHoveredAttachmentId;

  final Logger _logger = new Logger('w_attachments_client.extension_context_adapter');

  /// Map of all current highlights for visible active and selected comment
  /// anchors organized by anchorId.
  Map<int, cef.Highlight> _highlights = <int, cef.Highlight>{};

  /// Keeps a cache of regions around so when an attachment or reference becomes active, we don't have
  /// to rebuild the region payload in order to set active on ObservedRegionApi.
  Map<String, cef.ObservedRegion> _regionCache = <String, cef.ObservedRegion>{};

  ExtensionContextAdapter(
      {@required cef.ExtensionContext extensionContext,
      @required AttachmentsActions actions,
      @required AttachmentsStore store})
      : _extensionContext = extensionContext,
        _store = store,
        _actions = actions {
    listenToStream(_observedRegionApi.didChangeScopes, _onDidChangeScopes);
    listenToStream(_selectionApi.didChangeSelections, _onDidChangeSelection);
    listenToStream(_observedRegionApi.didChangeVisibleRegions, _onDidChangeVisibleRegions);
    listenToStream(_observedRegionApi.didChangeSelectedRegions, _onDidChangeSelectedRegions);
  }

  // getter for the observedRegionApi from the extension context
  cef.ObservedRegionApi get _observedRegionApi => _extensionContext.observedRegionApi;

  // getter for the selectionApi from the extension context
  cef.SelectionApi get _selectionApi => _extensionContext.selectionApi;

  /// isValidSelection returns true if there is a valid selection in the content
  bool get isValidSelection => _currentSelection != null;

  cef.Selection get currentSelection => _currentSelection;

  /// currentScopes returns the list of scopes that we have loaded attachments for
  Iterable<String> get currentScopes => _currentScopes;

  int get currentlyHoveredAttachmentId => _currentlyHoveredAttachmentId;

  // adds an observed region to the local cache, used for lookup later
  cef.ObservedRegion _cacheRegion(cef.ObservedRegion region) => _regionCache[region.wuri] = region;

  // called when the content provider tells us the selection has changed
  void _onDidChangeSelection(List<cef.Selection> currentSelections) {
    // if any of them is NOT empty AND if the list of those that are not empty has one entry, it is VALID
    final valid = (currentSelections != null &&
        currentSelections.isNotEmpty &&
        currentSelections.where((s) => !s.isEmpty).length == 1);
    // only fire the action if the value of isValidSelection changed to avoid many many useless actions
    if (valid != isValidSelection) {
      _store.trigger();
    }
    if (valid) {
      _currentSelection = currentSelections.firstWhere((s) => !s.isEmpty);
    } else {
      _currentSelection = null;
    }
  }

  // called when the content provider tells us the scopes have changed
  void _onDidChangeScopes(_) {
    var allScopes = _observedRegionApi.getScopes();
    var currentScopes = _currentScopes.toSet();
    // create a set of the scopes we need to subscribe to
    final List<String> scopesToObtain = allScopes.difference(currentScopes).toList();
    final GetAttachmentsByProducersPayload payload =
        new GetAttachmentsByProducersPayload(producerWurls: scopesToObtain);
    _actions.getAttachmentsByProducers(payload);
    // create a set of the scopes we need to unsubscribe from
    // TODO RAM-828: remove old attachments we no longer need to show
    // final Set<String> scopesToRemove = currentScopes.difference(allScopes);
    // set _currentScopes to the new list of scopes
    _currentScopes = allScopes;
    _store.trigger();
  }

  // called when the content provider tells us the selected regions changed
  void _onDidChangeSelectedRegions(_) {
    _logger.fine("Selected regions changed");
    // get the currently selected regions
    Set<cef.ObservedRegion> regions = _observedRegionApi.getSelectedRegionsV2();

    // convert the set of ObservedRegion to a set of usages that are
    // paired to a selected region
    final List<AttachmentUsage> usages = regions
        .expand((region) => _store.attachmentUsagesByAnchors(_store.anchorsByWurl(region.wuri)).toSet())
        .toList();
    final List<Attachment> attachments = _store.attachmentsOfUsages(usages);

    // update the list of selected attachments and/or usages in our store, based on ViewMode
    switch (_store.moduleConfig.viewModeSetting) {
      case ViewModeSettings.Groups:
      case ViewModeSettings.Headerless:
        _actions.selectAttachments(new SelectAttachmentsPayload(attachmentIds: attachments.map((a) => a.id).toList()));
        break;
      case ViewModeSettings.References:
        _actions.selectAttachmentUsages(
            new SelectAttachmentUsagesPayload(usageIds: usages.map((usage) => usage.id).toList()));
        break;
    }
    _refreshHighlights();
  }

  // when visible regions change update our highlights
  void _onDidChangeVisibleRegions(_) {
    _logger.fine("Visible regions changed");
    _observedRegionApi.getVisibleRegions().forEach(_cacheRegion);
    _refreshHighlights();
  }

  /// if the selected attachment or usage changes in our store, update the highlights
  void selectedChanged(Set<int> anchorIds) {
    _logger.fine("Selections changed, updating highlights");
    _updateHighlightStyle(anchorIds);
  }

  /// if the hovered attachment or usage changes in our store, update the highlights
  void hoverChanged(HoverAttachmentPayload payload) {
    _logger.fine("Hovered changed, updating highlights");
    Set<int> anchorIdsToUpdate = new Set<int>();
    anchorIdsToUpdate = _store.anchorIdsByAttachmentId(payload.previousAttachmentId)
      ..addAll(_store.anchorIdsByAttachmentId(payload.nextAttachmentId));
    _currentlyHoveredAttachmentId = payload.nextAttachmentId;

    _updateHighlightStyle(anchorIdsToUpdate);
  }

  // Make sure only have highlights for Anchors in our Anchors list that are visible.
  void _refreshHighlights() {
    final visibleRegionWuris = _observedRegionApi.getVisibleRegions().map((region) => region.wuri).toSet();
    final visibleAnchorIds =
        _store.anchors.where((anchor) => visibleRegionWuris.contains(anchor.producerWurl)).map((a) => a.id);

    final currentHighlightKeys = new Set<int>.from(_highlights.keys);
    final futureHighlightKeys = new Set<int>.from(_store.anchorIds);
    futureHighlightKeys.retainWhere(visibleAnchorIds.contains);

    for (int id in futureHighlightKeys.difference(currentHighlightKeys)) {
      Anchor anchorToHighlight = _store.anchors.firstWhere((anchor) => anchor.id == id, orElse: () => null);
      if (anchorToHighlight != null && anchorToHighlight.producerWurl != null) {
        _addHighlight(id, anchorToHighlight.producerWurl);
      }
    }

    currentHighlightKeys.difference(futureHighlightKeys).forEach(_removeHighlight);
  }

  void _addHighlight(int id, String wuri) {
    if (_highlights.containsKey(id)) return;
    cef.Highlight newHighlight = _extensionContext.highlightApi.createV3(
      key: id.toString(),
      wuri: wuri,
      styles: _highlightStyle(id),
    );

    // keep highlight and subscribe to didChangeSelected for selection.
    if (newHighlight == null) return;

    _highlights[id] = newHighlight;
    newHighlight.wasRemoved.then((_) => _highlightWasRemoved(id));
    _logger.fine('Added highlight for $id');
  }

  void _updateHighlightStyle(Set<int> highlightsToUpdate) {
    for (int highlightId in highlightsToUpdate) {
      _highlights[highlightId]?.updateV2(styles: _highlightStyle(highlightId));
    }
  }

  cef.HighlightStyles _highlightStyle(int id) {
    bool isSelected = _store.currentlySelectedAnchors.contains(id);
    bool isHovered = _store.anchorIdsByAttachmentId(_currentlyHoveredAttachmentId).contains(id);
    if (isSelected && isHovered) {
      return selectedPanelHoverStyles;
    } else if (isSelected) {
      return selectedHighlightStyles;
    } else if (isHovered) {
      return normalPanelHoverStyles;
    } else {
      return normalHighlightStyles;
    }
  }

  void _removeHighlight(int id) {
    _highlights[id]?.remove();
  }

  void _highlightWasRemoved(int id) {
    if (!_highlights.containsKey(id)) return;
    _highlights.remove(id);
    _logger.fine('Removed highlight for $id');
  }
}
