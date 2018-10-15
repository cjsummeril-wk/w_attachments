import 'package:meta/meta.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;
import 'package:web_skin_dart/ui_components.dart';

import 'package:w_attachments_client/src/models/action_item.dart';
import 'package:w_attachments_client/src/models/group.dart';
import 'package:w_attachments_client/src/action_provider.dart';
import 'package:w_attachments_client/src/attachments_api.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';

class StandardActionProvider implements ActionProvider {
  AttachmentsApi _api;
  static bool readOnly = false;

  StandardActionProvider._internal({@required AttachmentsApi api}) : _api = api;

  static ActionProvider actionProviderFactory(AttachmentsApi api) {
    return new StandardActionProvider._internal(api: api);
  }

  @override
  List<PanelActionItem> getPanelActions() {
    List<PanelActionItem> panelActions = [];

//     ActionItem downloadAsZip = new PanelActionItem(
//        icon: ActionItem.iconBuilder(icon: IconGlyph.FOLDER_ZIP_G2),
//        states: {
//          'default': ActionItem.iconBuilder(icon: IconGlyph.FOLDER_ZIP_G2),
//          'progress': (ProgressSpinner()..size = ProgressSpinnerSize.SMALL)()
//        },
//        tooltip: 'Download All in Zip',
//        testId: 'wa.AttachmentControls.Icon.ZipAll',
//        isDisabled: false,
//        shouldShow: () => _api?.attachments?.isNotEmpty == true,
//        callback: ((StatefulActionItem action) async {
//          _api.setActionState(action, 'progress');
//          await _api.downloadAllAttachmentsAsZip(
//              keys: _api.attachmentKeys, label: _api.label, zipSelection: _api.zipSelection);
//          _api.setActionState(action, 'default');
//        }));
//    panelActions.add(downloadAsZip);
//

    if (_api.showingHeaderlessGroup) {
      ActionItem uploadFile = new PanelActionItem(
          icon: ActionItem.iconBuilder(icon: IconGlyph.UPLOADED),
          tooltip: 'Upload File',
          testId: 'wa.AttachmentControls.Icon.UploadFile',
          isDisabled: readOnly || !_api.isValidSelection,
          callback: ((StatefulActionItem action) {
            cef.Selection selection = _api.currentSelection;
            _api.createAttachmentUsage(selection: selection);
          }));
      panelActions.add(uploadFile);
    }

    return panelActions;
  }

  @override
  List<AttachmentActionItem> getAttachmentActions(Attachment attachment) {
    List<AttachmentActionItem> attachmentActions = [];
//    if (attachment.isUploadComplete) {
//      ActionItem download = new AttachmentActionItem(
//        icon: ActionItem.iconBuilder(icon: IconGlyph.DOWNLOADED),
//        label: 'Download',
//        isDisabled: false,
//        callback: ((StatefulActionItem action, Attachment attachment) => _api.downloadAttachment(keyToDownload: attachment.id)));
//      attachmentActions.add(download);
//    }
//    if (attachment.isUploadComplete || attachment.isUploadFailed) {
//      ActionItem remove = new AttachmentActionItem(
//        icon: ActionItem.iconBuilder(icon: IconGlyph.TRASH),
//        label: 'Remove Attachment',
//        isDisabled: false,
//        callback: ((StatefulActionItem action, Attachment attachment) => _api.removeAttachment(keyToRemove: attachment.id)));
//      attachmentActions.add(remove);
//    }
//    if ([Status.Pending, Status.Started, Status.Progress].contains(attachment.uploadStatus)) {
//      ActionItem cancel = new AttachmentActionItem(
//        icon: ActionItem.iconBuilder(icon: IconGlyph.TRASH),
//        label: 'Cancel Upload',
//        isDisabled: false,
//        callback: ((StatefulActionItem action, Attachment attachment) =>
//          _api.cancelUpload(keyToCancel: attachment.id)));
//      attachmentActions.add(cancel);
//    }
//    if (attachment.isUploadComplete || attachment.isUploadFailed) {
//      ActionItem replace = new AttachmentActionItem(
//        icon: ActionItem.iconBuilder(icon: IconGlyph.XBRL_REPLACE_EXTENSION),
//        label: 'Replace Attachment',
//        isDisabled: false,
//        callback: ((StatefulActionItem action, Attachment attachment) =>
//          _api.replaceAttachment(keyToReplace: attachment.id)));
//      attachmentActions.add(replace);
//    }

    return attachmentActions;
  }

  @override
  List<GroupActionItem> getGroupActions(ContextGroup group) {
    List<GroupActionItem> groupActions = [];

//    ActionItem upload = new GroupActionItem(
//        icon: ActionItem.iconBuilder(icon: IconGlyph.UPLOADED),
//        tooltip: 'Upload File',
//        isDisabled: false,
//        callback: ((StatefulActionItem action, ContextGroup group) =>
//            _api.uploadFiles(toUpload: group.uploadSelection)));
//    groupActions.add(upload);

    return groupActions;
  }
}
