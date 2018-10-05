part of w_attachments_client.service;

class GetAttachmentsByProducersResponse {
  final List<Attachment> attachments;
  final List<AttachmentUsage> attachmentUsages;
  final List<Anchor> anchors;

  const GetAttachmentsByProducersResponse(
      {@required this.attachments, @required this.attachmentUsages, @required this.anchors});
}
