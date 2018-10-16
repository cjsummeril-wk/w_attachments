part of w_attachments_client.w_annotations_service.payloads;

class CreateAttachmentUsagePayload {
  final cef.Selection producerSelection;
  final int attachmentId;

  CreateAttachmentUsagePayload({@required this.producerSelection, this.attachmentId});
}
