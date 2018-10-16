import 'package:web_skin_dart/ui_core.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

@PropsMixin()
abstract class AttachmentPropsMixin {
  Map get props;

  /// The Dispatcher actions
  AttachmentsActions actions;

  /// The Filing mall
  AttachmentsStore store;
}
