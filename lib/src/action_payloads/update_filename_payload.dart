part of w_attachments_client.action_payloads;

class UpdateFilenamePayload {
  final String keyToUpdate;
  final String newFilename;

  UpdateFilenamePayload({@required this.keyToUpdate, @required this.newFilename});
}
