part of w_attachments_client.thread_pool;

class ThreadPool extends Disposable {
  final int _workerCount;
  bool _stopProcessing = false;
  String _taskType = '';
  final Logger _logger = new Logger('w_attachments_client.thread_pool');
  List<ThreadPoolWorker> _busyWorkers;
  final ListQueue<ThreadPoolWorker> _tasks = new ListQueue<ThreadPoolWorker>();
  final StreamController _queueStreamController;

  ThreadPool(this._workerCount, [this._taskType]) : _queueStreamController = new StreamController() {
    if (_workerCount == null || _workerCount <= 0) {
      throw new Exception('Worker count was null or less than or equal to 0! Setting to default value of 2 workers.');
    }

    _busyWorkers = [];
    manageStreamController(_queueStreamController);
    listenToStream(_queueStreamController.stream, _checkQueue);
  }

  @visibleForTesting
  List<ThreadPoolWorker> get busyWorkers => new List<ThreadPoolWorker>.unmodifiable(_busyWorkers);

  @visibleForTesting
  List<ThreadPoolWorker> get tasks => new List<ThreadPoolWorker>.unmodifiable(_tasks);

  @visibleForTesting
  int get workerCount => _workerCount;

  addTasks(List<ThreadPoolWorker> newTasks) {
    _tasks.addAll(newTasks);
    for (int i = 0; i < _workerCount; i++) {
      if (_queueStreamController?.isClosed == false) {
        _queueStreamController.add(null);
      }
    }
  }

  cancelTask(String cancelKey) {
    ThreadPoolWorker taskToCancel = _tasks.firstWhere((task) => task.key == cancelKey, orElse: () => null);
    if (taskToCancel != null) {
      _tasks.remove(taskToCancel);
      taskToCancel.cancel();
    }

    taskToCancel = _busyWorkers.firstWhere((task) => task.key == cancelKey, orElse: () => null);
    if (taskToCancel != null) {
      taskToCancel.cancel();
    }
  }

  Future _checkQueue(_) async {
    if (_busyWorkers.length >= _workerCount || _tasks.isEmpty || _stopProcessing) return;

    ThreadPoolWorker task = _tasks.removeFirst();

    if (task == null) {
      _logger.severe('Task is null!');
      if (_queueStreamController?.isClosed == false) {
        _queueStreamController.add(null);
      }
      return;
    }

    _busyWorkers.add(task);

    // async call to run
    try {
      await task.run();
      _logger.fine('$_taskType task complete');
    } catch (e, stackTrace) {
      _logger.severe('Error running $_taskType task', e, stackTrace);
    }

    _busyWorkers.remove(task);

    if (_queueStreamController?.isClosed == false) {
      _queueStreamController.add(null);
    }
  }

  @override
  onDispose() {
    _stopProcessing = true;
    _tasks.clear();
    _busyWorkers.forEach((ThreadPoolWorker worker) => worker.cancel());
    _busyWorkers.clear();
  }
}
