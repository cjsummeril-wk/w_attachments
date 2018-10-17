part of w_attachments_client.payloads.attachments_module_events;

class AttachmentUploadCanceledEventPayload {
  final List<String> canceledSelectionKeys;
  final bool cancelCompleted;

  const AttachmentUploadCanceledEventPayload({@required this.canceledSelectionKeys, @required this.cancelCompleted});
}
