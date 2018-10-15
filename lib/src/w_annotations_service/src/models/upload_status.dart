part of w_attachments_client.w_annotations_service.models;

enum Status { Pending, Started, Complete, Failed, Progress, Cancelled }

class UploadStatus {
  final Attachment attachment;
  final Status status;
  RequestProgress requestProgress;

  UploadStatus(this.attachment, this.status);
}
