library w_attachments_client.models.action_item;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:react/react_client.dart';
import 'package:web_skin_dart/ui_components.dart';

import 'package:w_attachments_client/src/models/group.dart';
import 'package:w_attachments_client/src/service_models.dart';

part 'action_item/action_item.dart';
part 'action_item/panel_action_item.dart';
part 'action_item/group_action_item.dart';
part 'action_item/attachment_action_item.dart';
part 'action_item/stateful_action_item.dart';

typedef Future<Null> PanelActionCallback(StatefulActionItem action);
typedef bool ShouldShowPanelActionItemCallback();

typedef Future<Null> GroupActionCallback(StatefulActionItem action, ContextGroup group);
typedef Future<Null> AttachmentActionCallback(StatefulActionItem action, Attachment attachment);
