part of w_attachments_client.w_annotations_service.payloads;

class CreateAttachmentUsageResponse {
  final Attachment attachment;
  final AttachmentUsage attachmentUsage;
  final Anchor anchor;

  const CreateAttachmentUsageResponse(
      {@required this.attachment, @required this.attachmentUsage, @required this.anchor});
}
