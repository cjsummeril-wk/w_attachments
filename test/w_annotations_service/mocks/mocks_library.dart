library w_attachments_client.test.w_annotations_service.mocks;

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:frugal/frugal.dart';
import 'package:messaging_sdk/messaging_sdk.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/service_adapters/attachments_service.dart';

import 'package:w_annotations_api/annotations_api_v1.dart';

part 'attachments_service_mock.dart';
part 'fannotations_client_mock.dart';
part 'nats_messaging_client_mock.dart';
part 'service_mock_proxy.dart';
