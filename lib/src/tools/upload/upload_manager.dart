part of w_attachments_client.upload;

class UploadManager extends Disposable {
  static int _refCount = 0;
  static UploadManager _uploadManager;
  static const maxUploadsInProgress = 2;
  final ThreadPool _pool = new ThreadPool(maxUploadsInProgress, 'Attachment Upload');

  factory UploadManager() {
    if (_refCount <= 0) {
      _uploadManager = new UploadManager._internal();
      _refCount = 0;
    }
    _refCount++;
    return _uploadManager;
  }

  UploadManager._internal() {
    manageDisposable(_pool);
  }

  @override
  Future<Null> dispose() async {
    _refCount--;
    if (_refCount <= 0) {
      await super.dispose();
      _uploadManager = null;
    }
  }

  addUploadTasks(List<UploadWorker> uploadTasks) {
    _pool.addTasks(uploadTasks);
  }

  cancelUploadTask(String cancelTaskKey) {
    _pool.cancelTask(cancelTaskKey);
  }
}
