part of w_attachments_client.payloads.attachments_module_actions;

class DropFilesPayload {
  final String selection;
  final List<File> files;

  DropFilesPayload({@required this.selection, @required this.files});
}
