part of w_attachments_client.models.service;

class Anchor extends ServiceModel {
  String accountResourceId;
  bool disconnected;
  String producerWurl;

  Anchor();

  Anchor.fromFAnchor(FAnchor fAnchor) {
    id = fAnchor.id;
    accountResourceId = fAnchor.accountResourceId;
    producerWurl = fAnchor.producerWurl;
    disconnected = fAnchor.disconnected;
  }

  FAnchor toFAnchor() => new FAnchor()
    ..id = id
    ..accountResourceId = accountResourceId
    ..disconnected = disconnected
    ..producerWurl = producerWurl;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return other is Anchor &&
        other.accountResourceId == accountResourceId &&
        other.disconnected == disconnected &&
        other.id == id &&
        other.producerWurl == producerWurl;
  }
}
