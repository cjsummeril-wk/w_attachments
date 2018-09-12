library w_attachments_client.components;

import 'dart:async';
import 'dart:html' as html;

import 'package:dnd/dnd.dart';
import 'package:meta/meta.dart';
import 'package:truss/truss.dart' show PanelTitle, PanelTitleProps, PanelToolbar, PanelToolbarProps;
import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;
import 'package:w_module/w_module.dart';
import 'package:w_virtual_components/w_virtual_components.dart' as w_virtual_components;
import 'package:web_skin_dart/ui_components.dart';
import 'package:web_skin_dart/ui_core.dart';

import 'package:w_attachments_client/src/components/utils.dart' as utils;
import 'package:w_attachments_client/src/action_payloads.dart';
import 'package:w_attachments_client/src/action_provider.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/models.dart';
import 'package:w_attachments_client/src/service_models.dart';

part 'components/attachment_action_renderer.dart';
part 'components/attachment_avatar_handler.dart';
part 'components/attachment_card.dart';
part 'components/attachment_card_header.dart';
part 'components/attachment_file_label.dart';
part 'components/attachment_icon_renderer.dart';
part 'components/attachment_tree_node_renderer.dart';
part 'components/attachments_components.dart';
part 'components/attachments_container.dart';
part 'components/attachments_controls.dart';
part 'components/attachments_header.dart';
part 'components/attachments_panel_toolbar.dart';
part 'components/empty_attachment_card.dart';
part 'components/group_action_renderer.dart';
part 'components/group_panel.dart';

typedef html.Element AvatarFactory();
