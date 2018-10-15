library w_attachments_client.w_annotations_service.attachments;

import 'dart:async';
import 'dart:core';
import 'dart:html' hide Client, Selection;
import 'dart:math';

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:frugal/frugal.dart' as frugal;
import 'package:logging/logging.dart';
import 'package:messaging_sdk/messaging_sdk.dart' as msg;
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:w_annotations_api/annotations_api_v1.dart';
import 'package:w_common/disposable.dart';

import 'package:w_attachments_client/src/components/utils.dart' as component_utils;
import 'package:w_attachments_client/src/upload.dart';

import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_payloads.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/service_adapters/service_constants.dart';

import '../utils.dart';

part 'attachments/attachments_service.dart';
part 'attachments/attachments_test_service.dart';
