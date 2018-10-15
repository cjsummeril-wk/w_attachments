import 'package:w_attachments_client/src/models/action_item.dart';
import 'package:w_attachments_client/src/models/group.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_models.dart';

abstract class ActionProvider {
  List<PanelActionItem> getPanelActions();

  List<AttachmentActionItem> getAttachmentActions(Attachment attachment);

  List<GroupActionItem> getGroupActions(ContextGroup group);
}
