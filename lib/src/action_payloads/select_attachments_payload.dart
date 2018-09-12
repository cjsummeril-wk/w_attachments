part of w_attachments_client.action_payloads;

class SelectAttachmentsPayload {
  final List<String> selectionKeys;
  final bool maintainSelections;

  SelectAttachmentsPayload({@required this.selectionKeys, this.maintainSelections: false});
}
