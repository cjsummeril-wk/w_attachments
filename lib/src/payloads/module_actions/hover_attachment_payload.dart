part of w_attachments_client.payloads.attachments_module_actions;

class HoverAttachmentPayload {
  final int previousAttachmentId;
  final int nextAttachmentId;

  HoverAttachmentPayload({@required this.previousAttachmentId, this.nextAttachmentId});
}
