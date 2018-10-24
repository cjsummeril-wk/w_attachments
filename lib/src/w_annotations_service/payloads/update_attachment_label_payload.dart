part of w_attachments_client.w_annotations_service.payloads;

class UpdateAttachmentLabelPayload {
  final int idToUpdate;
  final String newLabel;

  UpdateAttachmentLabelPayload({@required this.idToUpdate, @required this.newLabel});
}
