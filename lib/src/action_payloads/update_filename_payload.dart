part of w_attachments_client.action_payloads;

class UpdateFilenamePayload {
  final String keyToUpdate;
  final String newFilename;

  const UpdateFilenamePayload({@required this.keyToUpdate, @required this.newFilename});
}
