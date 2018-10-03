part of w_attachments_client.action_payloads;

class CreateAttachmentUsagePayload {
  final cef.Selection producerSelection;
  final int attachmentId;

  CreateAttachmentUsagePayload({@required this.producerSelection, this.attachmentId});
}
