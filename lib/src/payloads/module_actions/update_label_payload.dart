part of w_attachments_client.payloads.attachments_module_actions;

class UpdateLabelPayload {
  final int idToUpdate;
  final String newLabel;

  UpdateLabelPayload({@required this.idToUpdate, @required this.newLabel});
}
