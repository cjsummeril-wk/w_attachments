part of w_attachments_client.action_payloads;

class SelectAttachmentsPayload {
  final List<int> attachmentIds;
  final bool maintainSelections;

  SelectAttachmentsPayload({@required this.attachmentIds, this.maintainSelections: false});
}
