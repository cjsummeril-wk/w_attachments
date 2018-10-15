part of w_attachments_client.w_annotations_service.models;

class Attachment extends AnnotationModel {
  String accountResourceId;
  String fsResourceId;
  String fsResourceType;
  String filename;
  String label;
  String userName;
  Status uploadStatus;

  Attachment();

  Attachment.fromFAttachment(FAttachment fAttachment) {
    id = fAttachment.id;
    accountResourceId = fAttachment.accountResourceId;
    fsResourceId = fAttachment.fsResourceId;
    fsResourceType = fAttachment.fsResourceType;
    filename = fAttachment.filename;
  }

  String get filemime => filename?.contains('.') == true ? filename.split('.')[1] : null;

  bool get isUploadFailed => false;

  bool get isUploadComplete => false;

  FAttachment toFAttachment() => new FAttachment()
    ..id = id
    ..accountResourceId = accountResourceId
    ..fsResourceId = fsResourceId
    ..fsResourceType = fsResourceType
    ..filename = filename;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return other is Attachment &&
        other.accountResourceId == accountResourceId &&
        other.id == id &&
        other.fsResourceId == fsResourceId &&
        other.fsResourceType == fsResourceType &&
        other.label == label &&
        other.userName == userName &&
        other.uploadStatus == uploadStatus;
  }
}
