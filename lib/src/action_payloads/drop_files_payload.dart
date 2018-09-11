part of w_attachments_client.action_payloads;

class DropFilesPayload {
  final String selection;
  final List<File> files;

  DropFilesPayload({@required String this.selection, @required List<File> this.files});
}
