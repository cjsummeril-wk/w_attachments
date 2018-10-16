part of w_attachments_client.test.w_annotations_service.mocks;

class _MockStreamSubscription extends Mock implements StreamSubscription<UploadStatus> {}

class _MockUploadStatusStream extends Mock implements Stream<UploadStatus> {
  @override
  StreamSubscription<UploadStatus> listen(void onData(UploadStatus event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      new _MockStreamSubscription();
}

class AttachmentsServiceMock extends Mock implements AttachmentsService {
  @override
  Stream<UploadStatus> get uploadStatusStream => new _MockUploadStatusStream();
}
