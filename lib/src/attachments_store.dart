import 'dart:async';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_flux/w_flux.dart';
import 'package:w_module/w_module.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_api.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';

import 'package:w_attachments_client/src/payloads/module_actions.dart';

import 'package:w_attachments_client/src/action_provider.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/constants.dart';
import 'package:w_attachments_client/src/models/models.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_attachments_client/src/utils.dart';

typedef ActionProvider ActionProviderFactory(AttachmentsApi api);

class AttachmentsStore extends Store {
  static const attachmentType = 'Attachment';
  static const newUploadLabel = 'New Attachment';

  // attachments panel properties
  final ActionProviderFactory actionProviderFactory;
  final AttachmentsActions attachmentsActions;
  final AttachmentsEvents attachmentsEvents;
  final AnnotationsApi _annotationsApi;
  final cef.ExtensionContext _extensionContext;

  final Logger _logger = new Logger('w_attachments_client.attachments_store');

  AttachmentsConfig _moduleConfig;
  AttachmentsApi _api;
  ActionProvider _actionProvider;
  DispatchKey dispatchKey;

  List<Attachment> _attachments = <Attachment>[];
  @visibleForTesting
  set attachments(List<Attachment> attachments) => _attachments = attachments;

  List<AttachmentUsage> _attachmentUsages = <AttachmentUsage>[];
  @visibleForTesting
  set attachmentUsages(List<AttachmentUsage> usages) => _attachmentUsages = usages;

  List<Anchor> _anchors = <Anchor>[];
  @visibleForTesting
  set anchors(List<Anchor> anchors) => _anchors = anchors;
  List<Anchor> get anchors => _anchors;

  // CEF-specific properties
  cef.Selection _currentSelection;

  // headerless properties
  ContextGroup currentlyDisplayedSingle;
  bool _showingHeaderlessGroup = false;

  // group and filter properties
  List<Filter> _filtersVar = [];
  Map<String, Filter> _filtersByName = {};
  List<Group> _groups = [];

  // content extension framework properties
  Iterable<String> _currentScopes = [];
  Set<int> _currentlySelectedAttachments = new Set<int>();
  Set<int> _currentlySelectedAttachmentUsages = new Set<int>();

  AttachmentsStore(
      {@required this.actionProviderFactory,
      @required this.attachmentsActions,
      @required this.attachmentsEvents,
      @required this.dispatchKey,
      @required extensionContext,
      @required AnnotationsApi annotationsApi,
      AttachmentsConfig moduleConfig,
      List<Attachment> attachments,
      List<ContextGroup> groups,
      List<Filter> initialFilters})
      : _attachments = attachments,
        _extensionContext = extensionContext,
        _groups = groups,
        _annotationsApi = annotationsApi,
        this._moduleConfig = moduleConfig ?? new AttachmentsConfig() {
    _rebuildAndRedrawGroups();
    _api = new AttachmentsApi(attachmentsActions, this);

    _actionProvider = actionProviderFactory != null
        ? actionProviderFactory(_api)
        : StandardActionProvider.actionProviderFactory(_api);

    if (initialFilters != null) {
      _filters = initialFilters;
    }

    // Module Action Listeners
    triggerOnActionV2(attachmentsActions.setActionItemState, _setActionItemState);
    triggerOnActionV2(attachmentsActions.setGroups, _setGroups);
    triggerOnActionV2(attachmentsActions.setFilters, _setFilters);
    triggerOnActionV2(attachmentsActions.updateAttachmentsConfig, _setAttachmentsConfig);

    // Attachment Action Listeners
    triggerOnActionV2(attachmentsActions.addAttachment, _addAttachment);
    triggerOnActionV2(attachmentsActions.dropFiles, _dropFiles);
    triggerOnActionV2(attachmentsActions.deselectAttachments, _deselectAttachments);
    triggerOnActionV2(attachmentsActions.selectAttachments, _selectAttachments);

    [
      attachmentsActions.createAttachmentUsage.listen(_handleCreateAttachmentUsage),
      attachmentsActions.getAttachmentsByIds.listen(_handleGetAttachmentsByIds),
      attachmentsActions.getAttachmentsByProducers.listen(_handleGetAttachmentsByProducers),
      attachmentsActions.getAttachmentUsagesByIds.listen(_getAttachmentUsagesByIds),
      attachmentsActions.upsertAttachment.listen(_upsertAttachment),
      attachmentsActions.updateAttachmentLabel.listen(_handleUpdateAttachmentLabel),
      attachmentsActions.refreshPanelToolbar.listen(_handleRefreshPanelToolbar)
    ].forEach(manageActionSubscription);

    // Service Stream Listeners
    listenToStream(_annotationsApi.uploadStatusStream, _handleUploadStatus);

    // Event Listeners
    listenToStream(attachmentsEvents.attachmentRemoved, _handleAttachmentRemoved);

    // CEF Listeners
    listenToStream(_extensionContext.observedRegionApi.didChangeScopes, _onDidChangeScopes);
    listenToStream(_extensionContext.selectionApi.didChangeSelections, _onDidChangeSelection);
    listenToStream(_extensionContext.observedRegionApi.didChangeVisibleRegions, _onDidChangeVisibleRegions);
    listenToStream(_extensionContext.observedRegionApi.didChangeSelectedRegions, _onDidChangeSelectedRegions);
  }

  AttachmentsConfig get moduleConfig => _moduleConfig;

  AttachmentsApi get api => _api;

  ActionProvider get actionProvider => _actionProvider;

  List<ActionItem> get actionItems => _actionProvider.getPanelActions();

  String get primarySelection => _moduleConfig.primarySelection;

  Set<int> get currentlySelectedAttachments => _currentlySelectedAttachments;

  Set<int> get currentlySelectedAttachmentUsages => _currentlySelectedAttachmentUsages;

  bool get enableClickToSelect => _moduleConfig.enableClickToSelect;

  bool get enableLabelEdit => _moduleConfig.enableLabelEdit;

  bool get showFilenameAsLabel => _moduleConfig.showFilenameAsLabel;

  bool get showingHeaderlessGroup => _showingHeaderlessGroup;

  /// isValidSelection returns true if there is a valid selection in the content
  bool get isValidSelection => _currentSelection != null;

  cef.Selection get currentSelection => _currentSelection;

  /// currentScopes returns the list of scopes that we have loaded attachments for
  Iterable<String> get currentScopes => _currentScopes;

  // zip download properties
  String get label => _moduleConfig.label;
//  Selection get zipSelection => _moduleConfig.zipSelection;

  // attachment getters/setters
  List<Attachment> get attachments => new List<Attachment>.unmodifiable(_attachments);
  List<int> get attachmentIds => new List<int>.unmodifiable(_attachments.map((attachment) => attachment?.id));

  List<AttachmentUsage> get attachmentUsages => new List<AttachmentUsage>.unmodifiable(_attachmentUsages);

  List<Anchor> anchorsByWurl(String wurl) =>
    new List<Anchor>.unmodifiable(_anchors.where((anchor) => anchor?.producerWurl == wurl));

  List<int> get anchorIds => new List<int>.unmodifiable(_anchors.map((anchor) => anchor?.id));

  List<AttachmentUsage> attachmentUsagesByAnchorId(int anchorId) =>
      new List<AttachmentUsage>.unmodifiable(_attachmentUsages.where((usage) => usage.anchorId == anchorId));

  List<AttachmentUsage> attachmentUsagesByAnchors(List<Anchor> anchors) {
    List<AttachmentUsage> attachmentUsagesToReturn = [];
    List<int> attachmentUsagesToGet = new List<int>.from(anchors.map((Anchor anchor) => anchor.id));
    attachmentUsagesToReturn
        .addAll(_attachmentUsages.where((AttachmentUsage usage) => attachmentUsagesToGet.contains(usage.anchorId)));
    return attachmentUsagesToReturn;
  }

  List<Attachment> attachmentsOfUsages(List<AttachmentUsage> usages) {
    List<Attachment> attachmentsToReturn = [];
    List<String> attachmentIdsToGet = new List<String>.from(usages.map((AttachmentUsage usage) => usage.attachmentId));
    attachmentsToReturn
        .addAll(_attachments.where((Attachment attachment) => attachmentIdsToGet.contains(attachment.id)));
    return attachmentsToReturn;
  }

  List<AttachmentUsage> usagesOfAttachment(Attachment attachment) {
    return _attachmentUsages.where((AttachmentUsage usage) => usage.attachmentId == attachment.id).toList();
  }

  List<Attachment> attachmentsForProducerWurl(String producerWurl) {
    List<AttachmentUsage> usages = attachmentUsagesByAnchors(anchorsByWurl(producerWurl));
    return attachmentsOfUsages(usages);
  }

  // group and filter getters/setters
  List<Group> get groups => new List<Group>.from(_groups);

  List<Filter> get _filters => _filtersVar;
  List<Filter> get filters => new List<Filter>.from(_filters);
  Map<String, Filter> get filtersByName => new Map<String, Filter>.from(_filtersByName);
  set _filters(List<Filter> newFilters) {
    _filtersVar = newFilters;
    _filtersByName = _filtersVar?.fold({}, (result, filter) {
          result[filter.name] = filter;
          return result;
        }) ??
        {};
  }

  // drag-and-drop getters/setters
  bool get enableDraggable => _moduleConfig.enableDraggable;
  bool get enableUploadDropzones => _moduleConfig.enableUploadDropzones;

  @override
  onDispose() {
    _attachments.clear();
    _groups.clear();
    _filters.clear();
    _currentlySelectedAttachments = null;
    currentlyDisplayedSingle = null;
  }

  _rebuildAndRedrawGroups() {
    _showingHeaderlessGroup = false;
    if (_groups.isEmpty) {
      return false;
    }

    if (_groups.length == 1 &&
        _groups.first.childGroups?.isNotEmpty != true &&
        _groups.first is ContextGroup &&
        (_groups.first as ContextGroup).displayAsHeaderless) {
      currentlyDisplayedSingle = _groups.first;
      _showingHeaderlessGroup = true;
    } else {
      currentlyDisplayedSingle = null;
    }
    for (var group in _groups) {
      group.rebuildAndRedrawGroup(_attachments);
    }
    trigger();
  }

  _removeAttachmentFromClientCache(int id) {
    Attachment attachmentToRemove = _getAttachmentById(id);
    if (attachmentToRemove != null && _attachments.contains(attachmentToRemove)) {
      _attachments.remove(attachmentToRemove);
      _rebuildAndRedrawGroups();
      attachmentsActions.deselectAttachments(new DeselectAttachmentsPayload(attachmentIds: [attachmentToRemove?.id]));
    }
  }

  _dropFiles(DropFilesPayload request) {
    if (request?.selection != null && request?.files?.isNotEmpty == true) {
//      _uploadFiles(request.selection, request.files);
    }
  }

  _handleCreateAttachmentUsage(CreateAttachmentUsagePayload payload) async {
    if (!isValidSelection) {
      _logger.warning('_createAttachmentUsage without valid selection');
      return;
    }

    try {
      final region = await _extensionContext.observedRegionApi.create(selection: payload.producerSelection);

      CreateAttachmentUsageResponse response =
          await _annotationsApi.createAttachmentUsage(producerWurl: region.wuri, attachmentId: payload.attachmentId);

      if (response == null) {
        _logger.warning('Something went wrong with CreateAttachmentUsage for ${payload.producerSelection}');
        return;
      }

      _anchors.add(response.anchor);
      _attachmentUsages.add(response.attachmentUsage);
      // need to check if the attachment associated with this usage already exists, and if not, add it.
      _attachments = removeAndAddType([response.attachment], _attachments, true);

      _rebuildAndRedrawGroups();
    } catch (e, stacktrace) {
      _logger.warning(e, stacktrace);
    }
  }

  _handleGetAttachmentsByProducers(GetAttachmentsByProducersPayload payload) async {
    GetAttachmentsByProducersResponse response =
        await _annotationsApi.getAttachmentsByProducers(producerWurls: payload.producerWurls);

    if (response == null) {
      _logger.warning('No associated data for wurls ${payload.producerWurls}.');
      return;
    }

    if (!payload.maintainAttachments) {
      _anchors.clear();
      _attachmentUsages.clear();
      _attachments.clear();
    }

    for (String wurl in payload.producerWurls) {
      List<Anchor> responseAnchors = response.anchors.where((Anchor a) => a.producerWurl.startsWith(wurl)).toList();
      if (responseAnchors?.isNotEmpty == true) {
        _anchors = removeAndAddType(responseAnchors, _anchors, payload.maintainAttachments);
      } else {
        _logger.warning('Wurl $wurl was not associated with any anchors.');
      }
    }

    _attachmentUsages = removeAndAddType(response.attachmentUsages, _attachmentUsages, payload.maintainAttachments);
    _attachments = removeAndAddType(response.attachments, _attachments, payload.maintainAttachments);

    _rebuildAndRedrawGroups();
  }

  _getAttachmentUsagesByIds(GetAttachmentUsagesByIdsPayload payload) async {
    if (payload.attachmentUsageIds != null && payload.attachmentUsageIds.isNotEmpty) {
      List<AttachmentUsage> response =
          await _annotationsApi.getAttachmentUsagesByIds(usageIdsToLoad: payload.attachmentUsageIds);

      if (response == null) {
        _logger.warning("Invalid attachment usage ids: ", payload.attachmentUsageIds);
        return null;
      }

      return _attachmentUsages = removeAndAddType(response, _attachmentUsages, false);
    } else {
      _logger.warning("Unable to locate attachment usages with given ids: ", payload.attachmentUsageIds);
      return null;
    }
  }

  Future<Null> _handleUpdateAttachmentLabel(UpdateAttachmentLabelPayload payload) async {
    _annotationsApi.updateAttachmentLabel(attachmentId: payload.idToUpdate, attachmentLabel: payload.newLabel);
  }

  _setActionItemState(ActionStateChangePayload request) {
    if (request?.action != null) {
      request.action.itemState = request.newState;
    }
  }

  _setFilters(SetFiltersPayload request) {
    _filters = request.filters;
  }

  void _setGroups(SetGroupsPayload request) {
    _groups = request.groups;
    _rebuildAndRedrawGroups();
  }

  _setAttachmentsConfig(AttachmentsConfig config) {
    _moduleConfig = config;
  }

  _upsertAttachment(UpsertAttachmentPayload request) {
    if (_attachments.contains(request.toUpsert)) {
      // trigger to update attachments view.
      trigger();
    } else {
      _addAttachment(new AddAttachmentPayload(toAdd: request.toUpsert));
    }
  }

  _addAttachment(AddAttachmentPayload request) {
    if (!_attachments.contains(request.toAdd)) {
      _attachments.add(request.toAdd);
      _rebuildAndRedrawGroups();
    }
  }

  _selectAttachments(SelectAttachmentsPayload request) {
    if (!request.maintainSelections && currentlySelectedAttachments.isNotEmpty) {
      _deselectAttachments(new DeselectAttachmentsPayload(attachmentIds: currentlySelectedAttachments.toList()));
    }
    List<int> attachmentIds = request?.attachmentIds;
    if (attachmentIds != null) {
      for (int id in attachmentIds) {
        if (currentlySelectedAttachments.add(id)) {
          print('setting attachment $id to selected');
          attachmentsEvents.attachmentSelected(
              new AttachmentSelectedEventPayload(selectedAttachmentId: id), dispatchKey);
        }
      }
    }
  }

  _deselectAttachments(DeselectAttachmentsPayload request) {
    List<int> attachmentIds = request?.attachmentIds;
    if (attachmentIds != null) {
      for (int id in attachmentIds) {
        if (currentlySelectedAttachments.remove(id)) {
          attachmentsEvents.attachmentDeselected(
              new AttachmentDeselectedEventPayload(deselectedAttachmentId: id), dispatchKey);
        }
      }
    }
  }

  Attachment _getAttachmentById(int id) =>
      _attachments.firstWhere((attachment) => attachment.id == id, orElse: () => null);

  void _handleAttachmentRemoved(AttachmentRemovedEventPayload removeEvent) {
    if (removeEvent.responseStatus) {
      _removeAttachmentFromClientCache(removeEvent.removedSelectionId);
    }
  }

  _handleGetAttachmentsByIds(GetAttachmentsByIdsPayload payload) async {
    if (payload.attachmentIds?.isNotEmpty == true) {
      List<Attachment> attachmentsResult = await _annotationsApi.getAttachmentsByIds(idsToLoad: payload.attachmentIds);

      if (attachmentsResult?.isNotEmpty == true) {
        // only replace attachments that are currently tracked by usages
        List<Attachment> inScopeAttachments = [];
        for (Attachment serverAttach in attachmentsResult) {
          if ((_attachmentUsages.any((AttachmentUsage inScopeUsage) => inScopeUsage.attachmentId == serverAttach.id))) {
            inScopeAttachments.add(serverAttach);
          } else {
            _logger.warning('Attachments store received out of scope attachment id: ${serverAttach.id}');
          }
        }
        _attachments = inScopeAttachments;
        trigger();
      } else {
        _logger.warning('Service returned null/empty for getAttachmentsByIds');
      }
    }
  }

  void _handleUploadStatus(UploadStatus uploadStatus) {
    uploadStatus.attachment.uploadStatus = uploadStatus.status;
    if (uploadStatus.status != Status.Cancelled) {
      _upsertAttachment(new UpsertAttachmentPayload(toUpsert: uploadStatus.attachment));
    }
  }

  /// Triggers a refresh of the panel toolbar when new Action Items are to be used.
  void _handleRefreshPanelToolbar(_) {
    // when handleRefreshPanelToolbar is dispatched, trigger will occur.
    // Trigger will cause the Panel Toolbar to re-render, with new actionItems based on other changes.
    trigger();
  }

  void _onDidChangeSelection(List<cef.Selection> currentSelections) {
    // if any of them is NOT empty AND if the list of those that are not empty, it is VALID
    final valid = (currentSelections != null &&
        currentSelections.isNotEmpty &&
        currentSelections.where((s) => !s.isEmpty).length == 1);
    // only fire the action if the value of isValidSelection changed to avoid many many useless actions
    if (valid != isValidSelection) {
      trigger();
    }
    if (valid) {
      _currentSelection = currentSelections.firstWhere((s) => !s.isEmpty);
      print('new selection $_currentSelection');
    } else {
      _currentSelection = null;
    }
  }

  /// Map of all current highlights for visible active and selected comment
  /// threads orginized by threadId.
  Map<int, cef.Highlight> _highlights = <int, cef.Highlight>{};

  /// Keeps a cache of regions around so when an attachment or reference becomes active, we don't have
  /// to rebuild the region payload in order to set active on ObservedRegionApi.
  Map<String, cef.ObservedRegion> _regionCache = <String, cef.ObservedRegion>{};

  // converts a string wuri to an ObservedRegion object
  cef.ObservedRegion _fetchRegion(String wuri) => _regionCache[wuri];

  // adds an observed region to the local cache, used for lookup later
  cef.ObservedRegion _cacheRegion(cef.ObservedRegion region) => _regionCache[region.wuri] = region;

  void _onDidChangeScopes(Null _) {
    var allScopes = _extensionContext.observedRegionApi.getScopes();
    var currentScopes = _currentScopes.toSet();
    // create a set of the scopes we need to subscribe to
    final List<String> scopesToObtain = allScopes.difference(currentScopes).toList();
    final GetAttachmentsByProducersPayload payload =
        new GetAttachmentsByProducersPayload(producerWurls: scopesToObtain);
    _handleGetAttachmentsByProducers(payload);
    // create a set of the scopes we need to unsubscribe from
    // TODO: remove old attachments we no longer need to show
    // final Set<String> scopesToRemove = currentScopes.difference(allScopes);
    // set _currentScopes to the new list of scopes
    _currentScopes = allScopes;
    trigger();
  }

  // called when the content provider tells us the selected regions changed
  _onDidChangeSelectedRegions(_) {
    _logger.fine("Selected regions changed");
    // get the currently selected regions
    Set<cef.ObservedRegion> regions = _extensionContext.observedRegionApi.getSelectedRegionsV2();
    print("Selected regions changed to $regions");

    // convert the set of ObservedRegion to a set of usages that are
    // paired to a selected region
    final usages = regions
      .expand((region) => attachmentUsagesByAnchors(anchorsByWurl(region.wuri)).toSet());
    final attachments = attachmentsOfUsages(usages);

    // update the list of selected threads in our store
    attachmentsActions.selectAttachments(new SelectAttachmentsPayload(
      attachmentIds: attachments.map((a) => a.id),
      usageIds: usages.map((usage) => usage.id)
    ));
    _refreshHighlights();
  }

  // when visible regions change update our highlights
  _onDidChangeVisibleRegions(_) {
    _logger.fine("Visible regions changed");
    print('visible regions changed');
    _extensionContext.observedRegionApi.getVisibleRegions().forEach(_cacheRegion);
    _refreshHighlights();
  }

  // if the active thread changes in our store call cef.changeActiveRegion
  // and update the highlights
//  void _activeChanged(SubstateChange<String> change) {
//    final activeThread = _store.state.threads.map[change.next];
//    String nextRegionId = activeThread?.regionId;
//    _extensionContext.observedRegionApi.changeActiveRegion(activeRegion: _fetchRegion(nextRegionId));
//    _updateHighlightStyle(change.prev, change.next);
//  }

//  // if the hovered thread changes in our store update the highlights
//  void _hoverChanged(SubstateChange<String> change) {
//    _logger.fine("Thread hovered, updating highlights");
//    _updateHighlightStyle(change.prev, change.next);
//  }

  /// Make sure only have highlights for Threads in our ThreadList that are visible and unfiltered.
  void _refreshHighlights() {
    final visibleRegionWuris = _extensionContext.observedRegionApi.getVisibleRegions().map((region) => region.wuri).toSet();
    final visibleAnchorIds = _anchors.where((anchor) => visibleRegionWuris.contains(anchor.producerWurl)).map((a) => a.id);
    print(visibleRegionWuris);
    print('visible anchor ids $visibleAnchorIds');

    final currentHighlightKeys = new Set<int>.from(_highlights.keys);
    final futureHighlightKeys = new Set<int>.from(anchorIds);
    print(currentHighlightKeys);
    print(futureHighlightKeys);
    futureHighlightKeys.retainWhere(visibleAnchorIds.contains);
    print('after retaining $futureHighlightKeys');

    for (int id in futureHighlightKeys.difference(currentHighlightKeys)) {
      Anchor anchorToHighlight = _anchors.firstWhere((anchor) => anchor.id == id, orElse: () => null);
      print(anchorToHighlight);
      if (anchorToHighlight != null && anchorToHighlight.producerWurl != null) {
        _addHighlight(id, anchorToHighlight.producerWurl);
      }
    }

    currentHighlightKeys.difference(futureHighlightKeys).forEach(_removeHighlight);
  }

  void _addHighlight(int id, String wuri) {
    print('adding highlights');
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

  void _updateHighlightStyle(int prev, int next) {
    _highlights[prev]?.updateV2(styles: _highlightStyle(prev));
    _highlights[next]?.updateV2(styles: _highlightStyle(next));
  }

  // Warning, changing these will break the example app
  cef.HighlightStyles _highlightStyle(int id) {
    bool isActive = _currentlySelectedAttachments.contains(id);
    bool isHovered = false;
//      id == _store.state.wCommentsApp.panelCommon.hovered || id == _store.state.wCommentsApp.popoverCommon.hovered;
    if (isActive && isHovered) {
      return activePanelHoverStyles;
    } else if (isActive) {
      print('active');
      return activeHighlightStyles;
    } else if (isHovered) {
      return normalPanelHoverStyles;
    } else {
      print('normal');
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
