import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
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
  final cef.ExtensionContext extensionContext;

  final Logger _logger = new Logger('w_attachments_client.attachments_store');

  AttachmentsConfig _moduleConfig;
  AttachmentsApi _api;
  ActionProvider _actionProvider;
  DispatchKey dispatchKey;
  List<Attachment> _attachments = [];
  List<AttachmentUsage> _attachmentUsages = [];
  Map<String, List<Anchor>> _anchors = {};

  // headerless properties
  ContextGroup currentlyDisplayedSingle;
  bool _showingHeaderlessGroup = false;

  Set<String> _currentlySelected = new Set<String>();

  // group and filter properties
  List<Filter> _filtersVar = [];
  Map<String, Filter> _filtersByName = {};
  List<Group> _groups = [];

  // nested tree properties
  AttachmentsTreeNode _hoveredNode;
  AttachmentsTreeNode _rootNode;
  Map<String, List<AttachmentsTreeNode>> _treeNodes = {};

  AttachmentsStore(
      {@required this.actionProviderFactory,
      @required this.attachmentsActions,
      @required this.attachmentsEvents,
      @required this.attachmentsService,
      @required this.dispatchKey,
      @required this.extensionContext,
      AttachmentsConfig moduleConfig,
      List<Attachment> attachments,
      List<ContextGroup> groups,
      List<Filter> initialFilters})
      : _attachments = attachments,
        _groups = groups,
        this._moduleConfig = moduleConfig ?? new AttachmentsConfig() {
    _regroup();
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
    triggerOnActionV2(attachmentsActions.getAttachmentsByProducers, _getAttachmentsByProducers);
    triggerOnActionV2(attachmentsActions.setActionItemState, _setActionItemState);
    triggerOnActionV2(attachmentsActions.setGroups, _setGroups);
    triggerOnActionV2(attachmentsActions.setFilters, _setFilters);
    triggerOnActionV2(attachmentsActions.updateAttachmentsConfig, _setAttachmentsConfig);

    // Attachment Action Listeners
    triggerOnActionV2(attachmentsActions.addAttachment, _addAttachment);
    triggerOnActionV2(attachmentsActions.dropFiles, _dropFiles);
    triggerOnActionV2(attachmentsActions.deselectAttachments, _deselectAttachments);
    triggerOnActionV2(attachmentsActions.selectAttachments, _selectAttachments);
//    triggerOnActionV2(attachmentsActions.uploadFiles, _selectAndUploadFiles);

    [
      attachmentsActions.hoverOverAttachmentNode.listen(_hoverOverAttachmentNodes),
      attachmentsActions.hoverOutAttachmentNode.listen(_hoverOutAttachmentNodes),
      attachmentsActions.updateAttachment.listen(_updateAttachment),
      attachmentsActions.upsertAttachment.listen(_upsertAttachment),
      attachmentsActions.refreshPanelToolbar.listen(_handleRefreshPanelToolbar)
    ].forEach(manageActionSubscription);

    // Service Stream Listeners
    listenToStream(attachmentsService.uploadStatusStream, _handleUploadStatus);

    // Event Listeners
    listenToStream(attachmentsEvents.attachmentRemoved, _handleAttachmentRemoved);
  }

  AttachmentsConfig get moduleConfig => _moduleConfig;

  AttachmentsApi get api => _api;

  ActionProvider get actionProvider => _actionProvider;

  List<ActionItem> get actionItems => _actionProvider.getPanelActions();

  String get primarySelection => _moduleConfig.primarySelection;

  Set<String> get currentlySelected => _currentlySelected;

  bool get enableClickToSelect => _moduleConfig.enableClickToSelect;

  bool get enableLabelEdit => _moduleConfig.enableLabelEdit;

  bool get showFilenameAsLabel => _moduleConfig.showFilenameAsLabel;

  bool get showingHeaderlessGroup => _showingHeaderlessGroup;

  // zip download properties
  String get label => _moduleConfig.label;
//  Selection get zipSelection => _moduleConfig.zipSelection;

  // attachment getters/setters
  List<Attachment> get attachments => new List<Attachment>.unmodifiable(_attachments);
  List<String> get attachmentKeys => new List<String>.unmodifiable(_attachments.map((attachment) => attachment?.id));
  List<AttachmentUsage> get attachmentUsages => new List<AttachmentUsage>.unmodifiable(_attachmentUsages);
  List<Anchor> getAnchorsByWurl(String wurl) =>
      _anchors[wurl] == null ? [] : new List<Anchor>.unmodifiable(_anchors[wurl]);
  List<AttachmentUsage> getAttachmentUsagesByAnchorId(String anchorId) =>
      new List<AttachmentUsage>.unmodifiable(_attachmentUsages.where((usage) => usage.anchorId == anchorId));
  List<AttachmentUsage> getAttachmentUsagesByAnchors(List<Anchor> anchors) {
    List<AttachmentUsage> attachmentUsagesToReturn = [];
    List<String> attachmentUsagesToGet = anchors.map((Anchor anchor) => anchor.id);
    attachmentUsagesToReturn
        .addAll(_attachmentUsages.where((AttachmentUsage usage) => attachmentUsagesToGet.contains(usage.anchorId)));
    return attachmentUsagesToReturn;
  }

  List<Attachment> getAttachmentsFromUsages(List<AttachmentUsage> usages) {
    List<Attachment> attachmentsToReturn = [];
    List<String> attachmentIdsToGet = usages.map((AttachmentUsage usage) => usage.attachmentId);
    attachmentsToReturn
        .addAll(_attachments.where((Attachment attachment) => attachmentIdsToGet.contains(attachment.id)));
    return attachmentsToReturn;
  }

  List<AttachmentUsage> getUsagesFromAttachment(Attachment attachment) =>
      _attachmentUsages.where((AttachmentUsage usage) => usage.attachmentId == attachment.id);
  List<Attachment> getAttachmentsByProducerWurl(String producerWurl) {
    List<AttachmentUsage> usages = getAttachmentUsagesByAnchors(getAnchorsByWurl(producerWurl));
    return getAttachmentsFromUsages(usages);
  }

  // nested tree getters/setters
  AttachmentsTreeNode get rootNode => _rootNode;
  AttachmentsTreeNode get hoveredNode => _hoveredNode;
  Map<String, List<AttachmentsTreeNode>> get treeNodes => _treeNodes;

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
    _currentlySelected = null;
    currentlyDisplayedSingle = null;
  }

  _regroup() {
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
      group.regroup(_attachments);
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

  _removeAttachmentFromClientCache(String key) {
    Attachment attachmentToRemove = _getAttachmentByKey(key);
    if (attachmentToRemove != null && _attachments.contains(attachmentToRemove)) {
      _attachments.remove(attachmentToRemove);
      _regroup();
      attachmentsActions.deselectAttachments(new DeselectAttachmentsPayload(selectionKeys: [attachmentToRemove?.id]));
    }
  }

  _dropFiles(DropFilesPayload request) {
    if (request?.selection != null && request?.files?.isNotEmpty == true) {
//      _uploadFiles(request.selection, request.files);
    }
  }

//  _downloadAllAttachmentsAsZip(DownloadAllAsZipPayload request) async {
//    // Remove keys where the attachments are not isUploadComplete
//    List<String> keys = new List<String>.from(request.keysToDownload);
//    keys.removeWhere((String key) =>
//        _attachments
//            .firstWhere((Attachment attachment) => (attachment?.key == key), orElse: () => null)
//            ?.isUploadComplete ==
//        false);
//
//    await attachmentsService.downloadFilesAsZip(keys: keys, label: request.label, zipSelection: request.zipSelection);
//  }

  _getAttachmentsByProducers(GetAttachmentsByProducersPayload request) async {
    if (!request.maintainAttachments) {
      _attachments.removeWhere((Attachment attachment) => attachment.isUploadComplete || attachment.isUploadFailed);
    }
    AttachmentsByProducersPayload newAttachments =
        await attachmentsService.getAttachmentsByProducers(producerWurls: request.producerWurls);
    for (String wurl in request.producerWurls) {
      _anchors[wurl] = newAttachments.anchors.where((Anchor anchor) => anchor.producerWurl == wurl);
    }
    for (AttachmentUsage attachmentUsage in newAttachments.attachmentUsages) {
      AttachmentUsage foundAttachmentUsage =
          _attachmentUsages.firstWhere((AttachmentUsage usage) => (usage?.id == usage?.id), orElse: () => null);
      if (foundAttachmentUsage == null) {
        _attachmentUsages.add(attachmentUsage);
      }
    }
    for (Attachment attachment in newAttachments.attachments) {
      Attachment foundAttachment =
          _attachments.firstWhere((Attachment existing) => (existing?.id == attachment?.id), orElse: () => null);
      if (foundAttachment == null) {
        _attachments.add(attachment);
      }
    }
    _regroup();
  }

  _setActionItemState(ActionStateChangePayload request) {
    if (request?.action != null) {
      request.action.itemState = request.newState;
    }
  }

  _setFilters(SetFiltersPayload request) {
    _filters = request.filters;
  }

  _setGroups(SetGroupsPayload request) {
    _groups = request.groups;
    _regroup();
  }

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
      _regroup();
    }
  }

  _updateAttachment(UpdateAttachmentPayload request) {
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
    if (!request.maintainSelections && currentlySelected.isNotEmpty) {
      _deselectAttachments(new DeselectAttachmentsPayload(selectionKeys: currentlySelected.toList()));
      for (var key in currentlySelected) {
        _treeNodes[key]?.forEach((node) => node.trigger());
      }
    }
    request?.selectionKeys?.forEach((String key) {
      if (currentlySelected.add(key)) {
        attachmentsEvents.attachmentSelected(
            new AttachmentSelectedEventPayload(selectedAttachmentKey: key), dispatchKey);
        _treeNodes[key]?.forEach((node) => node.trigger());
      }
    });
  }

  _deselectAttachments(DeselectAttachmentsPayload request) {
    request?.selectionKeys?.forEach((String key) {
      if (currentlySelected.remove(key)) {
        _treeNodes[key]?.forEach((node) => node.trigger());
        attachmentsEvents.attachmentDeselected(
            new AttachmentDeselectedEventPayload(deselectedAttachmentKey: key), dispatchKey);
      }
    });
  }

  Attachment _getAttachmentByKey(String key) =>
      _attachments.firstWhere((attachment) => attachment.id == key, orElse: () => null);

  _handleAttachmentRemoved(AttachmentRemovedEventPayload removeEvent) {
    if (removeEvent.responseStatus) {
      _removeAttachmentFromClientCache(removeEvent.removedSelectionKey);
    }
  }

  _handleUploadStatus(UploadStatus uploadStatus) {
    uploadStatus.attachment.uploadStatus = uploadStatus.status;
    if (uploadStatus.status != Status.Cancelled) {
      _upsertAttachment(new UpsertAttachmentPayload(toUpsert: uploadStatus.attachment));
    }
  }

  _hoverOverAttachmentNodes(HoverOverNodePayload request) {
    _hoveredNode = request.hovered;
    _hoveredNode.trigger();
  }

  _hoverOutAttachmentNodes(HoverOutNodePayload request) {
    _hoveredNode = null;
    request.unhovered.trigger();
  }

  /// Triggers a refresh of the panel toolbar when new Action Items are to be used.
  void _handleRefreshPanelToolbar(_) {
    // when handleRefreshPanelToolbar is dispatched, trigger will occur.
    // Trigger will cause the Panel Toolbar to re-render, with new actionItems based on other changes.
    trigger();
  }
}
