part of w_attachments_client.action_payloads;

class CreateAttachmentUsagePayload {
  final String producerWurl;
  final String attachmentId;

  CreateAttachmentUsagePayload({@required this.producerWurl, @required this.attachmentId});
}
