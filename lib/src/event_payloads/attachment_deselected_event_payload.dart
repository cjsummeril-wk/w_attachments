part of w_attachments_client.event_payloads;

class AttachmentDeselectedEventPayload {
  final String deselectedAttachmentKey;

  const AttachmentDeselectedEventPayload({@required this.deselectedAttachmentKey});
}
