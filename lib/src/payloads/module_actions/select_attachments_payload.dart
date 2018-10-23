part of w_attachments_client.payloads.attachments_module_actions;

class SelectAttachmentsPayload {
  final List<int> attachmentIds;
  final List<int> usageIds;
  final bool maintainSelections;

  SelectAttachmentsPayload({this.attachmentIds, this.usageIds, this.maintainSelections: false});
}
