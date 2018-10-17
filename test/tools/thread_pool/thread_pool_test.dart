library w_attachments_client.test.thread_pool.thread_pool_test;

import 'dart:async';

import 'package:test/test.dart';

import 'package:w_attachments_client/src/tools/thread_pool.dart';

void main() {
  group('ThreadPool', () {
    ThreadPool pool;
    setUp(() async {
      pool = new ThreadPool(5);
    });

    tearDown(() async {
      pool.onDispose();
    });

    test('should throw exception when invalid input is provided to constructor', () async {
      try {
        new ThreadPool(null);
      } catch (e) {
        expect(e, new isInstanceOf<Exception>());
      }

      try {
        new ThreadPool(-2);
      } catch (e) {
        expect(e, new isInstanceOf<Exception>());
      }
    });

    test('should start tasks when they are present', () async {
      pool.addTasks([
        new ThreadPoolWorker(
            key: 'some sorta task',
            task: ((ThreadPoolWorker task) async => new Future.delayed(new Duration(seconds: 3))))
      ]);
      expect(pool.tasks.length, 1);
      expect(pool.tasks.first.isRunning, isFalse);
      expect(pool.busyWorkers, isEmpty);
      await new Future.delayed(Duration.ZERO);
      expect(pool.tasks, isEmpty);
      expect(pool.busyWorkers, isNotEmpty);
      expect(pool.busyWorkers.first.isRunning, isTrue);
    });

    test('should process workerCount number of tasks at any given time', () async {
      pool.addTasks(new List.generate(
          9,
          ((int index) => new ThreadPoolWorker(
              key: 'task number $index',
              task: ((ThreadPoolWorker task) async => new Future.delayed(new Duration(seconds: 3)))))));
      // length of tasks after addTasks call will be number of tasks minus number of workers
      expect(pool.tasks.length, 9);
      // need to await async processing
      await new Future.delayed(Duration.ZERO);
      expect(pool.tasks.length, 4);
      expect(pool.busyWorkers.length, 5);
    });

    test('should remove a non-running ThreadPoolWorker from task list when cancelTask is called', () async {
      bool cancelled = false;
      ThreadPoolWorker cancelTask = new ThreadPoolWorker(
          key: 'cancelable',
          task: ((ThreadPoolWorker task) async => new Future.delayed(new Duration(seconds: 3))),
          cancelCallback: ((ThreadPoolWorker task) => cancelled = true));
      pool.addTasks([cancelTask]);

      expect(pool.tasks.contains(cancelTask), isTrue);
      expect(cancelTask.isRunning, isFalse);

      await pool.cancelTask('cancelable');
      expect(pool.tasks, isEmpty);
      expect(pool.busyWorkers, isEmpty);
      expect(cancelTask.isRunning, isFalse);
      expect(cancelled, isFalse);
    });

    test('should call task.cancel and remove a running ThreadPoolWorker from busyWorkers when cancelTask is called',
        () async {
      bool cancelled = false;
      ThreadPoolWorker cancelTask = new ThreadPoolWorker(
          key: 'cancelable',
          task: ((ThreadPoolWorker task) async {
            int testCounter = 0;
            while (!cancelled && testCounter++ < 10) {
              await new Future.delayed(new Duration(milliseconds: 1));
            }
          }),
          cancelCallback: ((ThreadPoolWorker task) async => cancelled = true));
      pool.addTasks([cancelTask]);

      expect(pool.tasks.contains(cancelTask), isTrue);
      expect(cancelTask.isRunning, isFalse);
      // need to await async processing
      await new Future.delayed(Duration.ZERO);
      expect(pool.busyWorkers.contains(cancelTask), isTrue);
      expect(cancelTask.isRunning, isTrue);

      pool.cancelTask('cancelable');
      await new Future.delayed(Duration.ZERO);
      expect(pool.tasks, isEmpty);
      expect(pool.busyWorkers, isEmpty);
      expect(cancelled, isTrue);
      expect(cancelTask.isRunning, isFalse);
    });

    test('should process subsequent tasks if a ThreadPoolWorker is null', () async {
      pool.addTasks([
        null,
        new ThreadPoolWorker(
            key: 'some sorta task',
            task: ((ThreadPoolWorker task) async => new Future.delayed(new Duration(seconds: 3))))
      ]);

      expect(pool.tasks.length, 2);
      await new Future.delayed(Duration.ZERO);
      expect(pool.tasks, isEmpty);
      expect(pool.busyWorkers.length, 1);
    });
  });
}
