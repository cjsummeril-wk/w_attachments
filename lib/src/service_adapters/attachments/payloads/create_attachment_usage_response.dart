part of w_attachments_client.service;

class CreateAttachmentUsageResponse {
  final Attachment attachment;
  final AttachmentUsage attachmentUsage;
  final Anchor anchor;

  const CreateAttachmentUsageResponse(
      {@required this.attachment, @required this.attachmentUsage, @required this.anchor});
}
