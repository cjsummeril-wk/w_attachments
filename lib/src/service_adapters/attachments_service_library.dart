library w_attachments_client.service;

import 'dart:async';
import 'dart:core';
import 'dart:html' hide Client, Selection;
import 'dart:math';

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:frugal/frugal.dart' as frugal;
import 'package:logging/logging.dart';
import 'package:messaging_sdk/messaging_sdk.dart' as msg;
import 'package:meta/meta.dart';
import 'package:truss/modal_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:w_annotations_api/annotations_api_v1.dart';
import 'package:w_common/disposable.dart';

import 'package:w_attachments_client/src/components/utils.dart' as component_utils;
import 'package:w_attachments_client/src/service_models.dart';
import 'package:w_attachments_client/src/upload.dart';

import '../utils.dart';

part 'package:w_attachments_client/src/service_adapters/attachments/payloads/get_attachments_by_producers_response.dart';
part 'package:w_attachments_client/src/service_adapters/attachments/payloads/attachment_removed_service_payload.dart';
part 'package:w_attachments_client/src/service_adapters/attachments/attachments_service.dart';
part 'package:w_attachments_client/src/service_adapters/attachments/attachments_test_service.dart';
part 'package:w_attachments_client/src/service_adapters/attachments/payloads/create_attachment_usage_response.dart';
part 'package:w_attachments_client/src/service_adapters/service_constants.dart';
