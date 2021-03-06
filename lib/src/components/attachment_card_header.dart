part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentCardHeaderProps> AttachmentCardHeader;

@Props()
class AttachmentCardHeaderProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  ActionProvider actionProvider;
  Attachment attachment;
  bool isSelected;
  bool isHovered;
}

@Component(subtypeOf: CardHeaderComponent)
class AttachmentCardHeaderComponent extends FluxUiComponent<AttachmentCardHeaderProps> {
  String get _labelText => (props.store.showFilenameAsLabel) ? props.attachment.filename : props.attachment.label;

  @override
  redrawOn() => [];

  @override
  render() {
    ClassNameBuilder headerClasses = new ClassNameBuilder()
      ..add('attachment-card__header', !props.isSelected)
      ..add('attachment-card__header--selected', props.isSelected)
      ..add('is-clickable');

    return (CardHeader()
      ..addTestId(test_id.AttachmentCardIds.attachmentCardHeaderId)
      ..className = headerClasses.toClassName()
      ..leftCap = (AttachmentIconRenderer()..attachment = props.attachment)()
      ..rightCap = ((AttachmentActionRenderer()
        ..store = props.store
        ..actions = props.actions
        ..actionProvider = props.actionProvider
        ..attachment = props.attachment
        ..isHovered = props.isHovered
        ..isSelected = props.isSelected
        ..renderAsCardHeaderActions = true
        ..addedClassName = 'attachment-card__header__menu-item')()))(!props.store.enableLabelEdit
        ? _labelText
        : (AttachmentFileLabel()
          ..actions = props.actions
          ..attachment = props.attachment
          ..isCardExpanded = props.isSelected
          ..store = props.store)());
  }
}
