part of w_attachments_client.payloads.attachments_module_actions;

class UploadAttachmentPayload {
  final String selection; // WURL type
  final bool allowMultiple;

  UploadAttachmentPayload({@required this.selection, this.allowMultiple: true});
}
