part of w_attachments_client.payloads.attachments_module_actions;

class UpdateFilenamePayload {
  final String keyToUpdate;
  final String newFilename;

  UpdateFilenamePayload({@required this.keyToUpdate, @required this.newFilename});
}
