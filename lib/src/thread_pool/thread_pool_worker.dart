part of w_attachments_client.thread_pool;

class ThreadPoolWorker {
  final String key;
  final ThreadPoolWorkerCallback task;
  final ThreadPoolWorkerCallback cancelCallback;
  bool _isRunning = false;

  ThreadPoolWorker({@required this.key, @required this.task, this.cancelCallback});

  bool get isRunning => _isRunning;

  run() async {
    _isRunning = true;
    await task(this);
    _isRunning = false;
  }

  cancel() async {
    if (_isRunning && cancelCallback != null) {
      await cancelCallback(this);
    }
    _isRunning = false;
  }
}
