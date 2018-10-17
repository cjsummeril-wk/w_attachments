library w_attachments_client.payloads.attachments_module_actions;

import 'dart:html' show File;

import 'package:meta/meta.dart';

import 'package:w_attachments_client/src/models/action_item.dart';
import 'package:w_attachments_client/src/models/group.dart';
import 'package:w_attachments_client/src/models/filter.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';

part 'module_actions/action_state_change_payload.dart';
part 'module_actions/add_attachment_payload.dart';
part 'module_actions/cancel_upload_attachment_payload.dart';
part 'module_actions/cancel_uploads_attachments_payload.dart';
part 'module_actions/deselect_attachments_payload.dart';
part 'module_actions/download_all_as_zip_payload.dart';
part 'module_actions/download_attachment_payload.dart';
part 'module_actions/drop_files_payload.dart';
part 'module_actions/remove_attachment_payload.dart';
part 'module_actions/replace_attachment_payload.dart';
part 'module_actions/select_attachments_payload.dart';
part 'module_actions/set_filters_payload.dart';
part 'module_actions/set_groups_payload.dart';
part 'module_actions/update_filename_payload.dart';
part 'module_actions/update_label_payload.dart';
part 'module_actions/upload_attachment_payload.dart';
part 'module_actions/upsert_attachment_payload.dart';
