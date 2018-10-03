part of w_attachments_client.event_payloads;

class AttachmentRemovedEventPayload {
  final int removedSelectionId;
  final bool responseStatus;

  const AttachmentRemovedEventPayload({@required this.removedSelectionId, @required this.responseStatus});
}
