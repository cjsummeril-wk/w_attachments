part of w_attachments_client.models.service;

class Anchor {
  String accountResourceId;
  bool disconnected;
  String id;
  String producerWurl;

  Anchor.fromFAnchor(FAnchor fAnchor)
      : id = fAnchor.id,
        accountResourceId = fAnchor.accountResourceId,
        producerWurl = fAnchor.producerWurl,
        disconnected = fAnchor.disconnected;

  FAnchor toFAnchor(Anchor anchor) => new FAnchor()
    ..id = id
    ..accountResourceId = accountResourceId
    ..disconnected = disconnected
    ..producerWurl = producerWurl;
}
