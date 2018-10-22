library w_attachments_client.components;

import 'dart:html' as html;

import 'package:dnd/dnd.dart';
import 'package:meta/meta.dart';
import 'package:truss/truss.dart' show PanelTitle, PanelTitleProps, PanelToolbar, PanelToolbarProps;
import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;
import 'package:w_module/w_module.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;
import 'package:web_skin_dart/ui_components.dart';
import 'package:web_skin_dart/ui_core.dart';

import 'package:w_attachments_client/src/components/utils.dart' as utils;

import 'package:w_attachments_client/src/payloads/module_actions.dart';
import 'package:w_attachments_client/src/action_provider.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/components/utils.dart' as utils;
import 'package:w_attachments_client/src/models/models.dart';
import 'package:w_attachments_client/src/payloads/module_actions.dart';
import 'package:w_attachments_client/src/test/component_test_ids.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';
import 'package:w_attachments_client/src/components/component_test_ids.dart' as test_id;

part 'attachment_action_renderer.dart';
part 'attachment_region.dart';
part 'attachment_avatar_handler.dart';
part 'attachment_card.dart';
part 'attachment_card_header.dart';
part 'attachment_file_label.dart';
part 'attachment_icon_renderer.dart';
part 'attachments_components.dart';
part 'attachments_container.dart';
part 'attachments_header.dart';
part 'attachments_panel_toolbar.dart';
part 'empty_attachment_card.dart';
part 'group_action_renderer.dart';
part 'group_panel.dart';

typedef html.Element AvatarFactory();
