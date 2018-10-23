import 'dart:async';
import 'package:meta/meta.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/models/action_item.dart';
import 'package:w_attachments_client/src/models/filter.dart';
import 'package:w_attachments_client/src/models/group.dart';
import 'package:w_attachments_client/src/payloads/module_actions.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';

class AttachmentsApi {
  final AttachmentsActions _attachmentsActions;
  final AttachmentsStore _attachmentsStore;

  AttachmentsApi(this._attachmentsActions, this._attachmentsStore);

  /// Retrieves the current module configuration instance.
  AttachmentsConfig get moduleConfig => _attachmentsStore.moduleConfig;

  // Getters
  /// attachments is the list of all [Attachment]s loaded into the store.
  List<Attachment> get attachments => _attachmentsStore.attachments;

  /// attachmentUsages is the list of all [AttachmentUsage]s loaded into the store.
  List<AttachmentUsage> get attachmentUsages => _attachmentsStore.attachmentUsages;

  /// currentlyDisplayedSingle is the [ContextGroup] that is currently displayed in headless mode.
  ContextGroup get currentlyDisplayedSingle => _attachmentsStore.currentlyDisplayedSingle;

  /// filtersByName is a map to allow direct fetching of currently applied [Filter]s on a particular selection.
  Map<String, Filter> get filtersByName => _attachmentsStore.filtersByName;

  /// groups is the list of all [ContextGroup]s shown in the attachments panel currently.
  List<Group> get groups => _attachmentsStore.groups;

  /// filters is the list of all currently defined [Filter]s.
  List<Filter> get filters => _attachmentsStore.filters;

  /// label is the name applied to the zip file from zip download, default is "AttachmentPackage".
  String get label => _attachmentsStore.label;

  /// The primary anchor for new attachments, this is used when uploading via the top level menu button.
  String get primarySelection => _attachmentsStore.primarySelection;

  /// true if the attachments panel is displayed in headerless mode, false if not.
  bool get showingHeaderlessGroup => _attachmentsStore.showingHeaderlessGroup;

  bool get isValidSelection => _attachmentsStore.isValidSelection;

  cef.Selection get currentSelection => _attachmentsStore.currentSelection;

  // Custom Getter methods
  /// getAnchorsByWurl is the list of all [Anchor]s whose ProducerWurl matches the provided one.
  List<Anchor> getAnchorsByWurl(String wurl) => _attachmentsStore.anchorsByWurl(wurl);

  /// getAttachmentsByProducerWurl is the list of all [Attachments]s whose AttachmentUsage maps to the provided wurl.
  List<Attachment> getAttachmentsByProducerWurl(String wurl) => _attachmentsStore.attachmentsForProducerWurl(wurl);

  /// getAttachmentUsagesByAnchorId is the list of all [AttachmentUsage]s whose AnchorId matches the provided one.
  List<AttachmentUsage> getAttachmentUsagesByAnchorId(int anchorId) =>
      _attachmentsStore.attachmentUsagesByAnchorId(anchorId);

  /// getAttachmentUsagesByAnchors is the list of all [AttachmentUsage]s whose AnchorId matches an ID of one of the anchors provided.
  List<AttachmentUsage> getAttachmentUsagesByAnchors(List<Anchor> anchors) =>
      _attachmentsStore.attachmentUsagesByAnchors(anchors);

  /// getAttachmentsFromUsages is the list of all [Attachment]s whose AttachmentId is defined in one of the provided AttachmentUsages.
  List<Attachment> getAttachmentsFromUsages(List<AttachmentUsage> usages) =>
      _attachmentsStore.attachmentsOfUsages(usages);

  // Attachment Actions
  /// Updates the label on the [Attachment] with the [newLabel] via w-annotations-service
  ///
  ///   [attachmentId] is the id of the attachment where the label is being changed.
  ///   [newLabel] is the new label the bundle should get
  Future<Null> updateAttachmentLabel({@required int attachmentId, @required String newLabel}) async =>
      await _attachmentsActions
          .updateAttachmentLabel(new UpdateAttachmentLabelPayload(idToUpdate: attachmentId, newLabel: newLabel));

  // Module Actions
  Future<Null> createAttachmentUsage({cef.Selection selection}) async {
    await _attachmentsActions.createAttachmentUsage(new CreateAttachmentUsagePayload(producerSelection: selection));
  }

  /// Calls w-annotations-service endpoint to retrieve all attachments, attachment usages, and anchors for the
  /// provided producerWurls.
  ///
  ///   [producerWurlsToLoad] is a list of Selection keys associated with an attachment bundle.
  ///   [maintainAttachments] sets whether or not the list should be cleared before load or appended to
  ///   if [maintainAttachments] is false (default), the list will be cleared; if true the list will be maintained
  Future<Null> getAttachmentsByProducers(
          {@required List<String> producerWurlsToLoad, bool maintainAttachments: false}) async =>
      await _attachmentsActions.getAttachmentsByProducers(new GetAttachmentsByProducersPayload(
          producerWurls: producerWurlsToLoad, maintainAttachments: maintainAttachments));

  /// Calls w-annotations-service endpoint to retrieve attachment usages for the provided id
  ///
  /// [UsageIds] contains a list of ids in order to grab the proper usages
  Future<Null> getAttachmentUsagesByIds(List<int> usageIds) async {
    GetAttachmentUsagesByIdsPayload requestPayload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);
    await _attachmentsActions.getAttachmentUsagesByIds(requestPayload);
  }

  /// setActionState sets the state of a StatefulActionItem to a new state
  ///
  ///   [action] is the action that should be modified
  ///   [state] is the string state in the item's map to set current state to
  Future<Null> setActionState(StatefulActionItem action, String newState) async =>
      _attachmentsActions.setActionItemState(new ActionStateChangePayload(action: action, newState: newState));

  /// setGroups replaces the current list of [ContextGroup]s being displayed in the panel
  /// with the supplied list and rerenders the panel accordingly.
  ///
  ///   [groups] is the new list of [Group]s
  Future<Null> setGroups({@required List<Group> groups}) async =>
      await _attachmentsActions.setGroups(new SetGroupsPayload(groups: groups));

  /// setFilters replaces the current list of [Filter]s being displayed in the panel
  /// with the supplied list and rerenders the panel accordingly.
  ///
  ///   [filters] is the new list of [Filter]s`
  Future<Null> setFilters({@required List<Filter> filters}) async =>
      await _attachmentsActions.setFilters(new SetFiltersPayload(filters: filters));

  Future<Null> updateAttachmentsConfig(AttachmentsConfig newConfig) async =>
      await _attachmentsActions.updateAttachmentsConfig(newConfig);

  Future<Null> refreshPanelToolbar() async => await _attachmentsActions.refreshPanelToolbar();
}
