part of w_attachments_client.payloads.attachments_module_actions;

class CancelUploadsAttachmentsPayload {
  final List<String> keysToCancel;

  CancelUploadsAttachmentsPayload({@required this.keysToCancel});
}
