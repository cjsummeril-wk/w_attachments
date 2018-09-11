part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentFileLabelProps> AttachmentFileLabel;

@Props()
class AttachmentFileLabelProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  Attachment attachment;
  String labelText;
}

@Component()
class AttachmentFileLabelComponent extends FluxUiComponent<AttachmentFileLabelProps> {
  ClickToEditInputComponent _labelRef;

  @override
  componentWillReceiveProps(Map nextProps) {
    super.componentWillReceiveProps(nextProps);

    AttachmentFileLabelProps tNextProps = typedPropsFactory(nextProps);
    if (_labelRef != null && tNextProps != null) {
      String labelText = tNextProps.attachment.label;
      if (props.store.showFilenameAsLabel) {
        labelText = tNextProps.attachment.filename;
      }
      _labelRef.setValue(labelText);
    }
  }

  @override
  render() {
    String placeholderText = (props.store.showFilenameAsLabel) ? 'filename' : 'label';

    return (
      (ClickToEditInput()
          ..alwaysReadOnly = !props.store.enableLabelEdit
          ..className = 'attachment-label'
          ..defaultValue = props.labelText
          ..formGroupTitle = ''
          ..hideLabel = true
          ..label = 'Label'
          ..onCommit = _onCommit
          ..onDidEnterEditable = _onDidEnterEditable
          ..placeholder = 'Enter a ${placeholderText}'
          ..ref = ((ref) => _labelRef = ref)
          ..selectedFormGroupTitle = ''
      )()
    );
  }

  _onCommit(String oldValue, String newValue, SyntheticFormEvent event) {
    if (props.store.showFilenameAsLabel) {
      if (newValue.isEmpty == true) { return false; }
      String fileName = utils.fixFilenameExtension(oldValue, newValue);
//      if (fileName?.isNotEmpty == true) {
//        props.store.attachmentsActions.updateFilename(new UpdateFilenamePayload(keyToUpdate: props.attachment.id, newFilename: fileName));
//      } else {
//        return false;
//      }
    } else {
      props.store.attachmentsActions.updateLabel(new UpdateLabelPayload(keyToUpdate: props.attachment.id, newLabel: newValue));
    }
  }

  _onDidEnterEditable() {
    html.TextInputElement inputNode = _labelRef?.getInputDomNode();
    if (inputNode != null && inputNode.value.isNotEmpty) {
      int textLength = inputNode.value.length;
      if (props.store.showFilenameAsLabel) {
        textLength = utils.stripExtensionFromFilename(inputNode.value).length;
      }
      setSelectionRange(inputNode, 0, textLength);
    }
  }
}
