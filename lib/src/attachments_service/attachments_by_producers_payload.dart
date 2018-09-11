part of w_attachments_client.service;

class AttachmentsByProducersPayload {
  final List<Attachment> attachments;
  final List<AttachmentUsage> attachmentUsages;
  final List<Anchor> anchors;

  const AttachmentsByProducersPayload({@required this.attachments, @required this.attachmentUsages, @required this.anchors});
}
