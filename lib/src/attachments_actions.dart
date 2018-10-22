import 'package:w_common/disposable.dart';
import 'package:w_flux/w_flux.dart';

import 'package:w_attachments_client/src/payloads/module_actions.dart';
import 'package:w_attachments_client/src/attachments_config.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';

class AttachmentsActions extends Disposable {
  final addAttachment = new Action<AddAttachmentPayload>();
  final dropFiles = new Action<DropFilesPayload>();
  final updateAttachmentLabel = new Action<UpdateAttachmentLabelPayload>();
  final upsertAttachment = new Action<UpsertAttachmentPayload>();

  final selectAttachments = new Action<SelectAttachmentsPayload>();
  final deselectAttachments = new Action<DeselectAttachmentsPayload>();

  final hoverAttachment = new Action<HoverAttachmentPayload>();

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

  AttachmentsActions() {
    [
      addAttachment,
      deselectAttachments,
      dropFiles,
      getAttachmentsByProducers,
      hoverAttachment,
      refreshPanelToolbar,
      selectAttachments,
      setActionItemState,
      setFilters,
      setGroups,
      updateAttachmentLabel,
      updateAttachmentsConfig,
      upsertAttachment
    ].forEach(manageDisposable);
  }
}
