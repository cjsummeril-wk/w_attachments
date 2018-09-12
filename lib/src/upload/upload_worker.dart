part of w_attachments_client.upload;

class UploadWorker extends ThreadPoolWorker {
  BaseRequest request;

  UploadWorker({@required String key, @required Function task, Function cancelCallback})
      : super(key: key, task: task, cancelCallback: cancelCallback);
}
