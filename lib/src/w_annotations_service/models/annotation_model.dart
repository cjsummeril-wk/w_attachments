part of w_attachments_client.w_annotations_service.models;

abstract class AnnotationModel {
  int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other);
}
