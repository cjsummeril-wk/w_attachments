part of w_attachments_client.w_annotations_service.payloads;

class GetAttachmentsByProducersPayload {
  final List<String> producerWurls;
  final bool maintainAttachments;

  GetAttachmentsByProducersPayload({@required this.producerWurls, this.maintainAttachments: false});
}
