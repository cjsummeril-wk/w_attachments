part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentFileLabelProps> AttachmentFileLabel;

@Props()
class AttachmentFileLabelProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  Attachment attachment;
  bool isCardExpanded;
}

@State()
class AttachmentFileLabelState extends UiState {
  bool isLabelActive;
}

@Component()
class AttachmentFileLabelComponent extends FluxUiStatefulComponent<AttachmentFileLabelProps, AttachmentFileLabelState> {
  ClickToEditInputComponent _labelRef;
  @override
  getInitialState() => newState()..isLabelActive = false;

  @override
  render() {
    return (ClickToEditInput()
      ..addTestId(test_id.AttachmentCardIds.attachmentFileLabelId)
      ..formGroupProps = (domProps()
        ..onClick = (SyntheticMouseEvent event) {
          // Prevent the card from collapsing by stopping the event before it makes it to the card header
          // that this CTE is rendered within.
          event.stopPropagation();
        })
      ..alwaysReadOnly = !props.isCardExpanded
      ..className = (state.isLabelActive) ? 'attachment-card__header__label--active' : 'attachment-card__header__label'
      ..defaultValue = props.attachment.label
      ..hideLabel = true
      ..label = 'Label'
      ..onCommit = _onCommit
      // If user is editing field, allow expanded input field.
      ..isMultiline = state.isLabelActive
      ..onDidEnterEditable = () {
        setState(newState()..isLabelActive = true);
        if (props.store.showFilenameAsLabel) {
          _onDidEnterEditable();
        }
      }
      ..onDidExitEditable = () {
        setState(newState()..isLabelActive = false);
      }
      ..placeholder = props.attachment.filename ??= 'Enter a label'
      ..ref = (ref) => _labelRef = ref)();
  }

  void _onCommit(String oldValue, String newValue, SyntheticFormEvent event) {
    props.store.attachmentsActions
        .updateAttachmentLabel(new UpdateAttachmentLabelPayload(idToUpdate: props.attachment.id, newLabel: newValue));
  }

  void _onDidEnterEditable() {
    var labelInputNode = _labelRef?.getInputDomNode();
    if (labelInputNode != null && _labelRef.getValue().isNotEmpty && props.store.showFilenameAsLabel) {
      utils.stripExtensionFromFilename(_labelRef.getValue()).length;
    }
  }
}
