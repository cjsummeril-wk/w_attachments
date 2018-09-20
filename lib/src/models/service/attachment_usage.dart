part of w_attachments_client.models.service;

class AttachmentUsage {
  String accountResourceId;
  int anchorId;
  int attachmentId;
  int id;
  String label;
  int parentId;

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
}
