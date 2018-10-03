part of w_attachments_client.action_payloads;

class UpdateLabelPayload {
  final int idToUpdate;
  final String newLabel;

  UpdateLabelPayload({@required this.idToUpdate, @required this.newLabel});
}
