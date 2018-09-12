library w_attachments_client.action_payloads;

import 'dart:html' show File;

import 'package:meta/meta.dart';

import 'package:w_attachments_client/src/models/action_item.dart';
import 'package:w_attachments_client/src/models/group.dart';
import 'package:w_attachments_client/src/models/filter.dart';
import 'package:w_attachments_client/src/models/tree_node.dart';
import 'package:w_attachments_client/src/service_models.dart';

part 'action_payloads/action_state_change_payload.dart';
part 'action_payloads/add_attachment_payload.dart';
part 'action_payloads/cancel_upload_attachment_payload.dart';
part 'action_payloads/cancel_uploads_attachments_payload.dart';
part 'action_payloads/create_attachment_usage_payload.dart';
part 'action_payloads/deselect_attachments_payload.dart';
part 'action_payloads/download_all_as_zip_payload.dart';
part 'action_payloads/download_attachment_payload.dart';
part 'action_payloads/drop_files_payload.dart';
part 'action_payloads/hover_over_node_payload.dart';
part 'action_payloads/hover_out_node_payload.dart';
part 'action_payloads/get_attachments_by_producers_payload.dart';
part 'action_payloads/remove_attachment_payload.dart';
part 'action_payloads/replace_attachment_payload.dart';
part 'action_payloads/select_attachments_payload.dart';
part 'action_payloads/set_filters_payload.dart';
part 'action_payloads/set_groups_payload.dart';
part 'action_payloads/update_attachment_payload.dart';
part 'action_payloads/update_filename_payload.dart';
part 'action_payloads/update_label_payload.dart';
part 'action_payloads/upload_attachment_payload.dart';
part 'action_payloads/upsert_attachment_payload.dart';