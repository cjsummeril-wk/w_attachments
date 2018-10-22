part of w_attachments_client.w_annotations_service.models;

class Attachment extends AnnotationModel {
  String accountResourceId;
  String fsResourceId;
  String filemime;
  String filename;
  String label;
  String userName;
  Status uploadStatus;

  Attachment();

  Attachment.fromFAttachment(FAttachment fAttachment) {
    id = fAttachment.id;
    accountResourceId = fAttachment.accountResourceId;
    fsResourceId = fAttachment.fsResourceId;
    filemime = fAttachment.filemime;
    filename = fAttachment.filename;
    label = fAttachment.label;
  }

  bool get isUploadFailed => false;

  bool get isUploadComplete => false;

  FAttachment toFAttachment() => new FAttachment()
    ..id = id
    ..accountResourceId = accountResourceId
    ..fsResourceId = fsResourceId
    ..filemime = filemime
    ..filename = filename
    ..label = label;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return other is Attachment &&
        other.accountResourceId == accountResourceId &&
        other.id == id &&
        other.fsResourceId == fsResourceId &&
        other.label == label &&
        other.userName == userName &&
        other.uploadStatus == uploadStatus;
  }
}
