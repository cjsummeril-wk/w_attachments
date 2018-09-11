part of w_attachments_client.action_payloads;

class GetAttachmentsByProducersPayload {
  final List<String> producerWurls;
  final bool maintainAttachments;

  const GetAttachmentsByProducersPayload({@required this.producerWurls, this.maintainAttachments: false});
}
