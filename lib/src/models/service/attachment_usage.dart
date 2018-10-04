part of w_attachments_client.models.service;

class AttachmentUsage {
  String accountResourceId;
  int anchorId;
  int attachmentId;
  int id;
  String label;
  int parentId;

  AttachmentUsage();

  AttachmentUsage.fromFAttachmentUsage(FAttachmentUsage fAttachmentUsage)
      : id = fAttachmentUsage.id,
        label = fAttachmentUsage.label,
        accountResourceId = fAttachmentUsage.accountResourceId,
        anchorId = fAttachmentUsage.anchorId,
        parentId = fAttachmentUsage.parentId,
        attachmentId = fAttachmentUsage.attachmentId;

  FAttachmentUsage toFAttachmentUsage(AttachmentUsage attachmentUsage) => new FAttachmentUsage()
    ..id = id
    ..label = label
    ..accountResourceId = accountResourceId
    ..anchorId = anchorId
    ..parentId = parentId
    ..attachmentId = attachmentId;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return other is AttachmentUsage &&
        other.accountResourceId == accountResourceId &&
        other.anchorId == anchorId &&
        other.attachmentId == attachmentId &&
        other.id == id &&
        other.label == label &&
        other.parentId == parentId;
  }
}
