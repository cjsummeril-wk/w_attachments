part of w_attachments_client.action_payloads;

class UploadAttachmentPayload {
  final String selection; // WURL type
  final bool allowMultiple;

  UploadAttachmentPayload({@required this.selection, this.allowMultiple: true});
}
