part of w_attachments_client.models.service;

class Attachment {
  String accountResourceId;
  String id;
  String fsResourceId;
  String fsResourceType;
  String filename;
  String label;
  String userName;
  Status uploadStatus;

  Attachment();

  Attachment.fromFAttachment(FAttachment fAttachment)
      : id = fAttachment.id,
        accountResourceId = fAttachment.accountResourceId,
        fsResourceId = fAttachment.fsResourceId,
        fsResourceType = fAttachment.fsResourceType,
        filename = fAttachment.filename;

  String get filemime => filename?.contains('.') == true ? filename.split('.')[1] : null;

  bool get isUploadFailed => false;

  bool get isUploadComplete => false;

  FAttachment toFAttachment(Attachment attachment) => new FAttachment()
    ..id = id
    ..accountResourceId = accountResourceId
    ..fsResourceId = fsResourceId
    ..fsResourceType = fsResourceType
    ..filename = filename;
}
