library w_attachments_client.test.mocks;

import 'dart:async';
import 'dart:html' show File, Window;

import 'package:frugal/frugal.dart' as frugal;
import 'package:mockito/mockito.dart';
import 'package:messaging_sdk/messaging_sdk.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_api.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/attachments_module.dart';

part 'annotations_api_mock.dart';
part 'attachments_actions_mock.dart';
part 'attachments_module_mock.dart';
part 'attachments_events_mock.dart';
part 'attachments_store_mock.dart';
part 'extension_context_mock.dart';
part 'frugal_mock.dart';
part 'file_mock.dart';
part 'window_mock.dart';
