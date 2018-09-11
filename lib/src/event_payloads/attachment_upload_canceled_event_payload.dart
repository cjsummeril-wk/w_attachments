part of w_attachments_client.event_payloads;

class AttachmentUploadCanceledEventPayload {
  final List<String> canceledSelectionKeys;
  final bool cancelCompleted;

  const AttachmentUploadCanceledEventPayload({@required this.canceledSelectionKeys, @required this.cancelCompleted});
}
