part of w_attachments_client.action_payloads;

class CreateAttachmentUsagePayload {
  final String producerWurl;
  final int attachmentId;

  CreateAttachmentUsagePayload({@required this.producerWurl, this.attachmentId});
}
