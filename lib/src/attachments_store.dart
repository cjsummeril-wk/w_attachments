import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:w_annotations_api/annotations_api_v1.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_flux/w_flux.dart';
import 'package:w_module/w_module.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/action_payloads.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';

typedef ActionProvider ActionProviderFactory(AttachmentsApi api);

class AttachmentsStore extends Store {
  static const attachmentType = 'Attachment';
  static const newUploadLabel = 'New Attachment';

  // attachments panel properties
  final ActionProviderFactory actionProviderFactory;
  final AttachmentsActions attachmentsActions;
  final AttachmentsEvents attachmentsEvents;
  final AttachmentsService attachmentsService;
  final cef.ExtensionContext _extensionContext;

  final Logger _logger = new Logger('w_attachments_client.attachments_store');

  AttachmentsConfig _moduleConfig;
  AttachmentsApi _api;
  ActionProvider _actionProvider;
  DispatchKey dispatchKey;

  List<Attachment> _attachments = [];
  @visibleForTesting
  void set attachments(List<Attachment> attachments) => _attachments = attachments;

  List<AttachmentUsage> _attachmentUsages = [];
  @visibleForTesting
  void set attachmentUsages(List<AttachmentUsage> usages) => _attachmentUsages = usages;

  Map<String, List<Anchor>> _anchorsByWurls = {};
  @visibleForTesting
  void set anchors(Map<String, List<Anchor>> anchorsByWurls) => _anchorsByWurls = anchorsByWurls;

  // CEF-specific properties
  cef.Selection _currentSelection;

  // headerless properties
  ContextGroup currentlyDisplayedSingle;
  bool _showingHeaderlessGroup = false;

  // group and filter properties
  List<Filter> _filtersVar = [];
  Map<String, Filter> _filtersByName = {};
  List<Group> _groups = [];

  // nested tree properties
  AttachmentsTreeNode _hoveredNode;
  AttachmentsTreeNode _rootNode;
  Map<dynamic, List<AttachmentsTreeNode>> _treeNodes = {};

  // content extension framework properties
  Iterable<String> _currentScopes = [];
  Set<int> _currentlySelectedAttachments = new Set<int>();

  AttachmentsStore(
      {@required this.actionProviderFactory,
      @required this.attachmentsActions,
      @required this.attachmentsEvents,
      @required this.attachmentsService,
      @required this.dispatchKey,
      @required extensionContext,
      AttachmentsConfig moduleConfig,
      List<Attachment> attachments,
      List<ContextGroup> groups,
      List<Filter> initialFilters})
      : _attachments = attachments,
        _extensionContext = extensionContext,
        _groups = groups,
        this._moduleConfig = moduleConfig ?? new AttachmentsConfig() {
    _rebuildAndRedrawGroups();
    _api = new AttachmentsApi(attachmentsActions, this);

    _actionProvider = actionProviderFactory != null
        ? actionProviderFactory(_api)
        : StandardActionProvider.actionProviderFactory(_api);

    if (initialFilters != null) {
      _filters = initialFilters;
    }

    _rootNode = new GroupTreeNode(
        new ContextGroup(sortMethod: showFilenameAsLabel ? FilenameGroupSort.compare : LabelGroupSort.compare),
        _actionProvider,
        this,
        attachmentsActions);

    // Module Action Listeners
    triggerOnActionV2(attachmentsActions.createAttachmentUsage, _createAttachmentUsage);
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
      attachmentsActions.getAttachmentsByIds.listen(_handleGetAttachmentsByIds),
      attachmentsActions.hoverOverAttachmentNode.listen(_hoverOverAttachmentNodes),
      attachmentsActions.getAttachmentsByProducers.listen(_getAttachmentsByProducers),
      attachmentsActions.getAttachmentUsagesByIds.listen(_getAttachmentUsagesByIds),
      attachmentsActions.hoverOutAttachmentNode.listen(_hoverOutAttachmentNodes),
      attachmentsActions.updateAttachment.listen(_updateAttachment),
      attachmentsActions.upsertAttachment.listen(_upsertAttachment),
      attachmentsActions.refreshPanelToolbar.listen(_handleRefreshPanelToolbar)
    ].forEach(manageActionSubscription);

    // Service Stream Listeners
    listenToStream(attachmentsService.uploadStatusStream, _handleUploadStatus);

    // Event Listeners
    listenToStream(attachmentsEvents.attachmentRemoved, _handleAttachmentRemoved);

    // CEF Listeners
    listenToStream(_extensionContext.observedRegionApi.didChangeScopes, _onDidChangeScopes);
    listenToStream(_extensionContext.selectionApi.didChangeSelections, _onDidChangeSelection);
  }

  AttachmentsConfig get moduleConfig => _moduleConfig;

  AttachmentsApi get api => _api;

  ActionProvider get actionProvider => _actionProvider;

  List<ActionItem> get actionItems => _actionProvider.getPanelActions();

  String get primarySelection => _moduleConfig.primarySelection;

  Set<int> get currentlySelectedAttachments => _currentlySelectedAttachments;

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
  List<String> get attachmentKeys => new List<String>.unmodifiable(_attachments.map((attachment) => attachment?.id));
  List<AttachmentUsage> get attachmentUsages => new List<AttachmentUsage>.unmodifiable(_attachmentUsages);
  List<Anchor> anchorsByWurl(String wurl) =>
      _anchorsByWurls[wurl] == null ? [] : new List<Anchor>.unmodifiable(_anchorsByWurls[wurl]);
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

  List<AttachmentUsage> usagesOfAttachment(Attachment attachment) =>
      _attachmentUsages.where((AttachmentUsage usage) => usage.attachmentId == attachment.id);
  List<Attachment> attachmentsForProducerWurl(String producerWurl) {
    List<AttachmentUsage> usages = attachmentUsagesByAnchors(anchorsByWurl(producerWurl));
    return attachmentsOfUsages(usages);
  }

  // nested tree getters/setters
  AttachmentsTreeNode get rootNode => _rootNode;
  AttachmentsTreeNode get hoveredNode => _hoveredNode;
  Map<dynamic, List<AttachmentsTreeNode>> get treeNodes => _treeNodes;

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
    _rootNode.clearChildren();
    _rootNode = null;
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
    if (_groups.any((Group group) => group.hasChildren)) {
      _rootNode.clearChildren();
      _rootNode.addChildren(_generateTreeNodes(_groups));
      _rootNode.triggerRoot();
    }
  }

  List<GroupTreeNode> _generateTreeNodes(List<Group> groups) {
    List<GroupTreeNode> nodes = [];
    if (groups?.isNotEmpty == true) {
      for (var group in groups) {
        GroupTreeNode groupNode;
        groupNode = new GroupTreeNode(group, actionProvider, this, attachmentsActions,
            children: group.hasChildren ? _generateTreeNodes(group.childGroups) : null);
        if (group.attachments?.isNotEmpty == true) {
          group.attachments.forEach((attachment) {
            if (_treeNodes[attachment.id] == null) {
              _treeNodes[attachment.id] = [];
            }
            var attachmentNode = new AttachmentTreeNode(attachment, actionProvider, this, attachmentsActions);
            groupNode.addChild(attachmentNode);
            _treeNodes[attachment.id].add(attachmentNode);
          });
        }

        if (groupNode.children?.isNotEmpty != true) {
          groupNode.addChild(new EmptyTreeNode(this, attachmentsActions));
        }

        nodes.add(groupNode);
        if (_treeNodes[group.key] == null) {
          _treeNodes[group.key] = [];
        }
        _treeNodes[group.key].add(groupNode);
      }
    }
    return nodes;
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

  _createAttachmentUsage(CreateAttachmentUsagePayload payload) async {
    if (!isValidSelection) {
      _logger.warning('_createAttachmentUsage without valid selection');
      return;
    }

    try {
      final region = await _extensionContext.observedRegionApi.create(selection: payload.producerSelection);

      CreateAttachmentUsageResponse resp = await attachmentsService.createAttachmentUsage(producerWurl: region.wuri);

      _anchorsByWurls[resp.anchor.producerWurl] ??= [];
      _anchorsByWurls[resp.anchor.producerWurl].add(resp.anchor);
      _attachmentUsages.add(resp.attachmentUsage);
      // need to check if the attachment associated with this usage already exists, and if not, add it.
      Attachment foundAttachment =
          _attachments.firstWhere((Attachment existing) => (existing?.id == resp.attachment?.id), orElse: () => null);
      if (foundAttachment == null) {
        _attachments.add(resp.attachment);
      }

      _rebuildAndRedrawGroups();
    } catch (e, stacktrace) {
      _logger.warning(e, stacktrace);
    }
  }

  _getAttachmentsByProducers(GetAttachmentsByProducersPayload payload) async {
    GetAttachmentsByProducersResponse response =
        await attachmentsService.getAttachmentsByProducers(producerWurls: payload.producerWurls);

    for (String wurl in payload.producerWurls) {
      List<Anchor> responseAnchors = response?.anchors?.where((Anchor anchor) => anchor.producerWurl.startsWith(wurl));
      if (responseAnchors.isNotEmpty) {
        _anchorsByWurls[wurl] ??= [];
        for (Anchor anchor in responseAnchors) {
          if (!_anchorsByWurls[wurl].any((a) => a.id == anchor.id)) {
            _anchorsByWurls[wurl].add(anchor);
          }
        }
      } else {
        _logger.warning('Wurl $wurl was not associated with any anchors.');
      }
    }

    for (AttachmentUsage attachmentUsage in response.attachmentUsages) {
      // check to see if there is an attachmentUsage already existent
      AttachmentUsage foundAttachmentUsage = _attachmentUsages
          .firstWhere((AttachmentUsage usage) => (usage?.id == attachmentUsage?.id), orElse: () => null);
      if (foundAttachmentUsage == null) {
        _attachmentUsages.add(attachmentUsage);
      }
    }
    for (Attachment attachment in response.attachments) {
      Attachment foundAttachment =
          _attachments.firstWhere((Attachment existing) => (existing?.id == attachment?.id), orElse: () => null);
      if (foundAttachment == null) {
        _attachments.add(attachment);
      }
    }
    _rebuildAndRedrawGroups();
  }

  _getAttachmentUsagesByIds(List<int> usageIds) async {
    if (usageIds != null && usageIds.isNotEmpty) {
      List<AttachmentUsage> response = await attachmentsService.getAttachmentUsagesByIds(usageIdsToLoad: usageIds);
      if (response != null) {
        for (AttachmentUsage responseUsage in response) {
          AttachmentUsage matchedUsage =
              _attachmentUsages.firstWhere((AttachmentUsage usage) => usage.id == responseUsage.id, orElse: () => null);
          if (responseUsage != matchedUsage) {
            _attachmentUsages.remove(matchedUsage);
            _attachmentUsages.add(responseUsage);
          }
        }
        return _attachmentUsages;
      } else {
        _logger.warning("Unable to locate attachment usages with given ids: ", usageIds);
        return null;
      }
    } else {
      _logger.warning("Invalid attachment usage ids: ", usageIds);
    }
    return null;
  }

  // TODO: convert to setter
  _setActionItemState(ActionStateChangePayload request) {
    if (request?.action != null) {
      request.action.itemState = request.newState;
    }
  }

  // TODO: convert to setter
  _setFilters(SetFiltersPayload request) {
    _filters = request.filters;
  }

  // TODO: convert to setter
  void _setGroups(SetGroupsPayload request) {
    _groups = request.groups;
    _rebuildAndRedrawGroups();
  }

  // TODO: convert to setter
  _setAttachmentsConfig(AttachmentsConfig config) {
    _moduleConfig = config;
  }

  _upsertAttachment(UpsertAttachmentPayload request) {
    if (_attachments.contains(request.toUpsert)) {
      _updateAttachment(new UpdateAttachmentPayload(toUpdate: request.toUpsert));
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

  void _updateAttachment(UpdateAttachmentPayload request) {
    trigger();
    // treeNodes are not rendered as part of a general `trigger()` so must be triggered individually
    List nodes = _treeNodes[request.toUpdate.id];
    if (nodes?.isNotEmpty == true) {
      for (AttachmentsTreeNode node in nodes) {
        node.trigger();
      }
    }
  }

  _selectAttachments(SelectAttachmentsPayload request) {
    if (!request.maintainSelections && currentlySelectedAttachments.isNotEmpty) {
      _deselectAttachments(new DeselectAttachmentsPayload(attachmentIds: currentlySelectedAttachments.toList()));
      for (var key in currentlySelectedAttachments) {
        _treeNodes[key]?.forEach((node) => node.trigger());
      }
    }
    List<int> attachmentIds = request?.attachmentIds;
    if (attachmentIds != null) {
      for (int id in attachmentIds) {
        if (currentlySelectedAttachments.add(id)) {
          attachmentsEvents.attachmentSelected(
              new AttachmentSelectedEventPayload(selectedAttachmentId: id), dispatchKey);
          _treeNodes[id]?.forEach((node) => node.trigger());
        }
      }
    }
  }

  _deselectAttachments(DeselectAttachmentsPayload request) {
    List<int> attachmentIds = request?.attachmentIds;
    if (attachmentIds != null) {
      for (int id in attachmentIds) {
        if (currentlySelectedAttachments.remove(id)) {
          _treeNodes[id]?.forEach((node) => node.trigger());
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
      List<Attachment> attachmentsResult =
          await attachmentsService.getAttachmentsByIds(idsToLoad: payload.attachmentIds);

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
        this._attachments = inScopeAttachments;
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

  void _hoverOverAttachmentNodes(HoverOverNodePayload request) {
    _hoveredNode = request.hovered;
    _hoveredNode.trigger();
  }

  void _hoverOutAttachmentNodes(HoverOutNodePayload request) {
    _hoveredNode = null;
    request.unhovered.trigger();
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
    } else {
      _currentSelection = null;
    }
  }

  void _onDidChangeScopes(Null _) {
    var allScopes = _extensionContext.observedRegionApi.getScopes();
    var currentScopes = _currentScopes.toSet();
    // create a set of the scopes we need to subscribe to
    final List<String> scopesToObtain = allScopes.difference(currentScopes).toList();
    final GetAttachmentsByProducersPayload payload =
        new GetAttachmentsByProducersPayload(producerWurls: scopesToObtain);
    _getAttachmentsByProducers(payload);
    // create a set of the scopes we need to unsubscribe from
    // TODO: remove old attachments we no longer need to show
    // final Set<String> scopesToRemove = currentScopes.difference(allScopes);
    // set _currentScopes to the new list of scopes
    _currentScopes = allScopes;
    trigger();
  }
}
