import 'package:w_common/disposable.dart';
import 'package:w_flux/w_flux.dart';

import 'package:w_attachments_client/src/action_payloads.dart';
import 'package:w_attachments_client/src/attachments_config.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';

class AttachmentsActions extends Disposable {
  final addAttachment = new Action<AddAttachmentPayload>();
  final dropFiles = new Action<DropFilesPayload>();
  final updateAttachment = new Action<UpdateAttachmentPayload>();
  final updateLabel = new Action<UpdateLabelPayload>();
  final upsertAttachment = new Action<UpsertAttachmentPayload>();

  final selectAttachments = new Action<SelectAttachmentsPayload>();
  final deselectAttachments = new Action<DeselectAttachmentsPayload>();

  // module-level actions
  final createAttachmentUsage = new Action<CreateAttachmentUsagePayload>();
  final getAttachmentsByIds = new Action<GetAttachmentsByIdsPayload>();
  final getAttachmentsByProducers = new Action<GetAttachmentsByProducersPayload>();
  final getAttachmentUsagesByIds = new Action<GetAttachmentUsagesByIdsPayload>();
  final setActionItemState = new Action<ActionStateChangePayload>();
  final setGroups = new Action<SetGroupsPayload>();
  final setFilters = new Action<SetFiltersPayload>();
  final updateAttachmentsConfig = new Action<AttachmentsConfig>();
  final refreshPanelToolbar = new Action<Null>();

  // Nested Attachment Tree Actions
  final hoverOverAttachmentNode = new Action<HoverOverNodePayload>();
  final hoverOutAttachmentNode = new Action<HoverOutNodePayload>();

  AttachmentsActions() {
    [
      addAttachment,
      dropFiles,
      updateAttachment,
      updateLabel,
      upsertAttachment,
      selectAttachments,
      deselectAttachments,
      getAttachmentsByProducers,
      setActionItemState,
      setFilters,
      setGroups,
      updateAttachmentsConfig,
      refreshPanelToolbar,
      hoverOverAttachmentNode,
      hoverOutAttachmentNode
    ].forEach(manageDisposable);
  }
}
