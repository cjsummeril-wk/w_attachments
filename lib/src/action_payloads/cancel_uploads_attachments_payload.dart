part of w_attachments_client.action_payloads;

class CancelUploadsAttachmentsPayload {
  final List<String> keysToCancel;

  const CancelUploadsAttachmentsPayload({@required this.keysToCancel});
}
