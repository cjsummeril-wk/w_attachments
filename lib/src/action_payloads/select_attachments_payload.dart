part of w_attachments_client.action_payloads;

class SelectAttachmentsPayload {
  final List<String> selectionKeys;
  final bool maintainSelections;

  const SelectAttachmentsPayload({@required List<String> this.selectionKeys, bool this.maintainSelections: false});
}
