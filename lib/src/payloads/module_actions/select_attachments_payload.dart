part of w_attachments_client.payloads.attachments_module_actions;

class SelectAttachmentsPayload {
  final List<int> attachmentIds;
  final bool maintainSelections;

  SelectAttachmentsPayload({@required this.attachmentIds, this.maintainSelections: false});
}