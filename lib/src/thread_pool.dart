library w_attachments_client.thread_pool;

import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:w_common/disposable.dart';

part 'thread_pool/thread_pool.dart';
part 'thread_pool/thread_pool_worker.dart';

typedef void ThreadPoolWorkerCallback(ThreadPoolWorker task);
