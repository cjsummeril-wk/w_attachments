library w_attachments_client.service;

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:html' hide Client, Selection;
import 'dart:math';

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:frugal/frugal.dart';
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

import './utils.dart';

part './attachments_service/attachments_by_producers_payload.dart';
part './attachments_service/attachment_removed_service_payload.dart';
part './attachments_service/attachments_service.dart';
part './attachments_service/attachments_test_service.dart';
part './attachments_service/attachment_usage_created_payload.dart';
