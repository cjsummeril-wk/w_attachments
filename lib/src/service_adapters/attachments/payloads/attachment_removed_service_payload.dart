part of w_attachments_client.service;

class AttachmentRemovedServicePayload {
  final String removedSelectionKey;
  final bool responseStatus;

  const AttachmentRemovedServicePayload({@required this.removedSelectionKey, @required this.responseStatus});
}
