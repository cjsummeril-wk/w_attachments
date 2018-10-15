part of w_attachments_client.payloads.attachments_module_events;

class AttachmentRemovedEventPayload {
  final int removedSelectionId;
  final bool responseStatus;

  const AttachmentRemovedEventPayload({@required this.removedSelectionId, @required this.responseStatus});
}
