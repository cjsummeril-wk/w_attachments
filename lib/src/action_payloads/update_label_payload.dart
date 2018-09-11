part of w_attachments_client.action_payloads;

class UpdateLabelPayload {
  final String keyToUpdate;
  final String newLabel;

  const UpdateLabelPayload({@required this.keyToUpdate, @required this.newLabel});
}
