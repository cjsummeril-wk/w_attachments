part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentIconRendererProps> AttachmentIconRenderer;

@Props()
class AttachmentIconRendererProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  Attachment attachment;
}

@Component()
class AttachmentIconRendererComponent extends FluxUiComponent<AttachmentIconRendererProps> {
  @override
  redrawOn() => [];

  @override
  render() => props.attachment == null ? _renderBlank() : _renderIcon();

  _renderBlank() => (Icon()..addTestId('wa.CardComponent.HeaderTitle.BlankDocTypeIcon'))();

  _renderIcon() =>
      ([Status.Started, Status.Progress].contains(props.attachment.uploadStatus) ? _renderSpinner() : _renderDocIcon());

  _renderDocIcon() {
    IconGlyph docGlyph;
    IconColors docIconColorSetting = IconColors.TWO;
    if (props.attachment.uploadStatus != null) {
      switch (props.attachment.uploadStatus) {
        case Status.Pending:
          docGlyph = IconGlyph.PENDING;
          break;
        case Status.Started:
          docGlyph = IconGlyph.PENDING_FILL;
          break;
        case Status.Progress:
          docGlyph = IconGlyph.PENDING_FILL;
          break;
        case Status.Failed:
        case Status.Cancelled:
          docGlyph = IconGlyph.BLOCKED;
          docIconColorSetting = IconColors.ONE;
          break;
        case Status.Complete:
        default:
          docGlyph = FileMimeType.IconByMimeType[props.attachment.filemime] ?? IconGlyph.FILE_G2;
          break;
      }
    } else if (props.attachment.isUploadFailed == true) {
      docGlyph = IconGlyph.BLOCKED;
      docIconColorSetting = IconColors.ONE;
    } else {
      docGlyph = FileMimeType.IconByMimeType[props.attachment.filemime] ?? IconGlyph.FILE_G2;
    }
    return (Icon()
      ..addTestId('wa.CardComponent.HeaderTitle.DocTypeIcon')
      ..colors = docIconColorSetting
      ..glyph = docGlyph)();
  }

  _renderSpinner() => (ProgressSpinner()..size = ProgressSpinnerSize.SMALL)();
}
