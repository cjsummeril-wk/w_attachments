part of w_attachments_client.payloads.attachments_module_actions;

class SelectAttachmentUsagesPayload {
  final List<int> usageIds;
  final bool maintainSelections;

  SelectAttachmentUsagesPayload({@required this.usageIds, this.maintainSelections: false});
}
