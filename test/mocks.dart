library w_attachments_client.test.mocks;

import 'dart:async';
import 'dart:html' show File, Window;

import 'package:frugal/frugal.dart' as frugal;
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:messaging_sdk/messaging_sdk.dart';
import 'package:w_annotations_api/annotations_api_v1.dart';
import 'package:w_transport/w_transport.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/w_attachments_service_api.dart';

export 'package:w_attachments_client/src/attachments_service.dart';

part './mocks/attachments_actions_mock.dart';
part './mocks/attachments_events_mock.dart';
part './mocks/attachments_service_api_mock.dart';
part './mocks/attachments_service_stub.dart';
part './mocks/attachments_store_mock.dart';
part './mocks/client_mock.dart';
part './mocks/extension_context_mock.dart';
part './mocks/frugal_mock.dart';
part './mocks/file_mock.dart';
part './mocks/window_mock.dart';
