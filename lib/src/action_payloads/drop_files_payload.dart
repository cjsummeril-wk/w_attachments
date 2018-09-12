part of w_attachments_client.action_payloads;

class DropFilesPayload {
  final String selection;
  final List<File> files;

  DropFilesPayload({@required this.selection, @required this.files});
}
