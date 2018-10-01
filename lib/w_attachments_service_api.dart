library w_attachments_client.service_api;

import 'dart:async';
import 'dart:html' hide Client, Selection;

import 'package:app_intelligence/app_intelligence_browser.dart' show AppIntelligence;
import 'package:messaging_sdk/messaging_sdk.dart' as msg;
import 'package:meta/meta.dart';
import 'package:w_annotations_api/annotations_api_v1/f_f_get_attachment_usages_by_ids_response.dart';
import 'package:w_common/disposable.dart';

import 'package:w_attachments_client/src/attachments_service.dart';
import 'package:w_attachments_client/src/service_models.dart';

export 'package:w_attachments_client/src/models/filter.dart';
export 'package:w_attachments_client/src/models/group.dart';
export 'package:w_attachments_client/src/attachments_service.dart';
export 'package:w_attachments_client/src/service_models.dart';

part 'src/attachments_service_api.dart';
