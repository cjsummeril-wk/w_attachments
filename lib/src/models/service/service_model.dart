part of w_attachments_client.models.service;

abstract class ServiceModel {
  int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other);
}
