part of w_attachments_client.event_payloads;

class AttachmentRemovedEventPayload {
  final String removedSelectionKey;
  final bool responseStatus;

  const AttachmentRemovedEventPayload({@required this.removedSelectionKey, @required this.responseStatus});
}
