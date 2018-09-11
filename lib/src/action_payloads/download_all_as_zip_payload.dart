part of w_attachments_client.action_payloads;

class DownloadAllAsZipPayload {
  final List<String> keysToDownload;
  final String label;
  final String zipSelection;

  DownloadAllAsZipPayload({@required this.keysToDownload, @required this.label, @required this.zipSelection});
}
