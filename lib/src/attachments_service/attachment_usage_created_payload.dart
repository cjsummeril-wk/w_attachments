part of w_attachments_client.service;

class AttachmentUsageCreatedPayload {
  final Attachment attachment;
  final AttachmentUsage attachmentUsage;
  final Anchor anchor;

  const AttachmentUsageCreatedPayload({@required this.attachment, @required this.attachmentUsage, @required this.anchor});
}
