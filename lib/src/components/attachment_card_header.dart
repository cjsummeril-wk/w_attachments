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
      ..add('attachment-card-header')
      ..add('is-clickable')
      ..add('not-editing')
      ..add('selected', props.isSelected);

    return (CardHeader()
      ..className = headerClasses.toClassName()
      ..leftCap = (AttachmentIconRenderer()..attachment = props.attachment)()
      ..rightCap = (
        (AttachmentActionRenderer()
          ..store = props.store
          ..actions = props.actions
          ..actionProvider = props.actionProvider
          ..attachment = props.attachment
          ..isHovered = props.isHovered
          ..isSelected = props.isSelected
          ..renderAsCardHeaderActions = true
          ..className = 'node-menu-item'
        )()
      )
    )(
      !props.store.enableLabelEdit ? _labelText :
      (AttachmentFileLabel()
        ..actions = props.actions
        ..attachment = props.attachment
        ..labelText = _labelText
        ..store = props.store
      )()
    );
  }
}
