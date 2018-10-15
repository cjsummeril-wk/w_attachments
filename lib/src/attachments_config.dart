import 'package:web_skin_dart/ui_components.dart';

enum ViewModeSettings {Groups, Headerless, References}

class AttachmentsConfig {
  static const defaultZipName = 'AttachmentPackage';

  final IconGlyph emptyViewIcon;
  final String emptyViewText;
  final bool enableClickToSelect;
  final bool enableDraggable;
  final bool enableLabelEdit;
  final bool enableUploadDropzones;
  final String label;
  final String primarySelection;
  final bool showFilenameAsLabel;
  final String zipSelection;
  final ViewModeSettings viewModeSetting;

  AttachmentsConfig({
    this.emptyViewIcon: IconGlyph.FOLDER_ATTACHMENTS_G2,
    this.emptyViewText: 'No Attachments Found',
    this.enableClickToSelect: true,
    this.enableDraggable: true,
    this.enableLabelEdit: true,
    this.enableUploadDropzones: true,
    this.label: defaultZipName,
    this.primarySelection,
    this.showFilenameAsLabel: false,
    this.zipSelection,
    this.viewModeSetting : ViewModeSettings.References
  });
}
