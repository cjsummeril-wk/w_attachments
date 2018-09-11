import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:web_skin_dart/ui_components.dart';

import 'package:w_attachments_client/w_attachments_client.dart';

class SampleReaderPermissionsActionProvider implements ActionProvider {
  AttachmentsApi _api;
  static bool readOnly = false;
  static bool allowMultiple = true;

  SampleReaderPermissionsActionProvider._internal({@required api}) : _api = api;

  static ActionProvider actionProviderFactory(AttachmentsApi api) {
    return new SampleReaderPermissionsActionProvider._internal(api: api);
  }

  @override
  List<PanelActionItem> getPanelActions() {
    List<PanelActionItem> panelActions = [];

//    ActionItem downloadAsZip = new PanelActionItem(
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

    if (_api.showingHeaderlessGroup) {
      ActionItem uploadFile = new PanelActionItem(
          icon: ActionItem.iconBuilder(icon: IconGlyph.UPLOADED),
          tooltip: readOnly ? 'Read only, cannot upload file' : 'Upload File',
          testId: 'wa.AttachmentControls.Icon.UploadFile',
          isDisabled: readOnly,
          callback: ((StatefulActionItem action) {
            final dynamic uuid = new Uuid();
            var selection = _api.primarySelection ?? _api.currentlyDisplayedSingle.uploadSelection;
            _api.createAttachmentUsage(producerWurl: selection, attachmentId: uuid.v4().toString().substring(0, 22));
          }));
      panelActions.add(uploadFile);
    }

    return panelActions;
  }

  @override
  List<AttachmentActionItem> getAttachmentActions(Attachment bundle) {
    List<AttachmentActionItem> bundleActions = [];

//    if (bundle.isUploadComplete) {
//      ActionItem download = new AttachmentActionItem(
//          icon: ActionItem.iconBuilder(icon: IconGlyph.DOWNLOADED),
//          label: 'Download',
//          isDisabled: false,
//          callback: ((StatefulActionItem action, Attachment bundle) => _api.downloadAttachment(keyToDownload: bundle.id)));
//      bundleActions.add(download);
//    }
//
//    // does not display at all when readOnly
//    if (!readOnly && (bundle.isUploadComplete || bundle.isUploadFailed)) {
//      ActionItem remove = new AttachmentActionItem(
//          icon: ActionItem.iconBuilder(icon: IconGlyph.TRASH),
//          label: 'Remove Attachment',
//          isDisabled: false,
//          callback: ((StatefulActionItem action, Attachment bundle) => _api.removeAttachment(keyToRemove: bundle.id)));
//      bundleActions.add(remove);
//    }

    // disabled option for readOnly setting
//    if (bundle.isUploadComplete || bundle.isUploadFailed) {
//      ActionItem replace = new AttachmentActionItem(
//          icon: ActionItem.iconBuilder(icon: IconGlyph.XBRL_REPLACE_EXTENSION),
//          label: 'Replace Attachment',
//          isDisabled: readOnly,
//          callback: ((StatefulActionItem action, Attachment attachment) =>
//              _api.replaceAttachment(keyToReplace: attachment.id)));
//      bundleActions.add(replace);
//    }
//
//    if ([Status.Pending, Status.Started, Status.Progress].contains(bundle.uploadStatus)) {
//      ActionItem cancel = new AttachmentActionItem(
//          icon: ActionItem.iconBuilder(icon: IconGlyph.TRASH),
//          label: 'Cancel Upload',
//          isDisabled: false,
//          callback: ((StatefulActionItem action, Attachment attachment) =>
//              _api.cancelUpload(keyToCancel: attachment.id)));
//      bundleActions.add(cancel);
//    }

    return bundleActions;
  }

  @override
  List<GroupActionItem> getGroupActions(ContextGroup group) {
    List<GroupActionItem> groupActions = [];

//    ActionItem upload = new GroupActionItem(
//        icon: ActionItem.iconBuilder(icon: IconGlyph.UPLOADED),
//        tooltip: 'Upload File',
//        isDisabled: readOnly,
//        callback: ((StatefulActionItem action, ContextGroup group) =>
//            _api.uploadFiles(toUpload: group.uploadSelection, allowMultiple: allowMultiple)));
//    groupActions.add(upload);

    return groupActions;
  }
}
