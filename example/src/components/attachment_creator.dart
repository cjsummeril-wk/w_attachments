import 'package:react/react.dart' as react;
import 'package:uuid/uuid.dart';

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:web_skin_dart/ui_components.dart';
import 'package:web_skin_dart/ui_core.dart';

import '../example_content_extension_framework.dart';
import '../utils.dart' show ExampleDocumentId;

// TODO: [ATEAM-2883] remove these imports and fix the component
import 'package:w_attachments_client/src/action_payloads.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

import 'package:w_attachments_client/src/service_models.dart';

@Factory()
UiFactory<AttachmentCreatorProps> AttachmentCreator;

@Props()
class AttachmentCreatorProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  AttachmentsModule module;
  ExampleAttachmentsExtensionContext context;
  MouseEventCallback onAddAttachmentClick;
  KeyboardEventCallback onAttachmentFileNameChange;
  KeyboardEventCallback onAttachmentAuthorChange;
  FormEventCallback onUploadStatusChange;
}

@State()
class AttachmentCreatorState extends UiState {
  String attachmentFileName;
  String attachmentAuthor;
  bool isUpdating;
  bool hasSelectedRegion;
  Status uploadStatus;
}

@Component()
class AttachmentCreatorComponent extends FluxUiStatefulComponent<AttachmentCreatorProps, AttachmentCreatorState> {
  @override
  getInitialState() => (newState()
    ..isUpdating = false
    ..attachmentFileName = 'evidence.xlsx'
    ..attachmentAuthor = 'John Smith'
    ..hasSelectedRegion = _selectedRegionExists
    ..uploadStatus = Status.Complete);

  ToggleButtonGroupComponent _toggleButtonGroupRef;

  Set<String> _currentlySelected = new Set<String>();

  @override
  componentDidMount() {
    listenToStream(props.context.observedRegionApi.didChangeVisibleRegions, _handleRegionsDidChange);
    listenToStream(props.context.observedRegionApi.didChangeVisibleRegions, _handleRegionsDidChange);
    listenToStream(props.context.selectionApi.didChangeSelections, _handleSelectionDidChange);
    listenToStream(props.module.events.attachmentSelected, _handleSelectAttachment);
    listenToStream(props.module.events.attachmentDeselected, _handleUnselectAttachment);
  }

  @override
  render() {
    var attachmentFileNameInput = (TextInput()
      ..helpTooltip = 'The filename of the attachment'
      ..type = TextInputType.TEXT
      ..label = 'Attachment File Name'
      ..value = state.attachmentFileName
      ..onChange = _handleAttachmentFileNameChange
      ..isDisabled = _areInputsDisabled())();
    var attachmentAuthorInput = (TextInput()
      ..helpTooltip = 'The author of the attachment'
      ..type = TextInputType.TEXT
      ..label = 'Attachment Author'
      ..value = state.attachmentAuthor
      ..onChange = _handleAttachmentAuthorChange
      ..isDisabled = _areInputsDisabled())();
    var uploadStatusInput = (ToggleButtonGroup()
          ..groupLabel = 'Upload Status'
          ..ref = (ToggleButtonGroupComponent ref) {
            _toggleButtonGroupRef = ref;
          }
          ..isDisabled = _areInputsDisabled())(
        (RadioButton()
          ..size = ButtonSize.XSMALL
          ..onChange = _handleUploadStatusChange
          ..value = Status.Complete
          ..checked = state.uploadStatus == Status.Complete)('Complete'),
        (RadioButton()
          ..size = ButtonSize.XSMALL
          ..onChange = _handleUploadStatusChange
          ..value = Status.Failed
          ..checked = state.uploadStatus == Status.Failed)('Failed'),
        (RadioButton()
          ..size = ButtonSize.XSMALL
          ..onChange = _handleUploadStatusChange
          ..value = Status.Pending
          ..checked = state.uploadStatus == Status.Pending)('Pending'),
        (RadioButton()
          ..size = ButtonSize.XSMALL
          ..onChange = _handleUploadStatusChange
          ..value = Status.Progress
          ..checked = state.uploadStatus == Status.Progress)('Progress'),
        (RadioButton()
          ..size = ButtonSize.XSMALL
          ..onChange = _handleUploadStatusChange
          ..value = Status.Started
          ..checked = state.uploadStatus == Status.Started)('Started'));
    var addAttachmentButton = (Block()((Button()
      ..onClick = _handleAddAttachment
      ..isDisabled = _areInputsDisabled())(state.isUpdating ? 'Update Attachment' : 'Add Attachment')));

    var attachmentsCardBlock =
        (CardBlock()(Form()(attachmentFileNameInput, attachmentAuthorInput, uploadStatusInput, addAttachmentButton)));

    return (Card()
      ..className = 'add-attachment-card'
      ..actsAs = CardActsAs.WELL)(attachmentsCardBlock);
  }

  Status _statusFromString(List<String> status) {
    if (status?.isNotEmpty == true) {
      switch (status[0]) {
        case 'Status.Complete':
          return Status.Complete;
        case 'Status.Failed':
          return Status.Failed;
        case 'Status.Pending':
          return Status.Pending;
        case 'Status.Progress':
          return Status.Progress;
        case 'Status.Started':
          return Status.Started;
      }
    }
    return Status.Complete;
  }

  Status _findUploadStatus(Attachment attachment) {
    if (attachment.uploadStatus != null) {
      return attachment.uploadStatus;
    } else if (attachment.isUploadFailed) {
      return Status.Failed;
    }
    return Status.Complete;
  }

  _handleAddAttachment(react.SyntheticEvent event) {
//    if (props.onAddAttachmentClick != null &&
//        props.onAddAttachmentClick(event) == false) {
//      return;
//    }
//
//    String currentWuri = props.context.selectionApi.getCurrentSelections()?.first?.wuri;
//    if (!state.isUpdating && _selectedRegionExists) {
//      Bundle toAdd = new Bundle()
//        ..uploadStatus = Status.Complete;
//      toAdd.annotation
//        ..filename = state.attachmentFileName
//        ..author = state.attachmentAuthor;
//      toAdd.selection
//        ..key = new Uuid().v4()
//        ..resourceId = currentWuri
//        ..documentId = ExampleDocumentId
//        ..sectionId = new Uuid().v1()
//        ..regionId = currentWuri;
//
//      // TODO: [ATEAM-2883] refactor this to use the module.api somehow rather than actions
//      props.module.attachmentsActions.addAttachment(
//        new AddAttachmentPayload(toAdd: toAdd)
//      );
//    } else {
//      if (_currentlySelected.isNotEmpty) {
//        _currentlySelected.forEach((String key) {
//          Attachment toUpdate = props.store.attachments.firstWhere((Attachment attachment) => attachment.id == key);
//          toUpdate.uploadStatus = state.uploadStatus;
//          toUpdate
//          ..filename = state.attachmentFileName
//          ..userName = state.attachmentAuthor;
//
//          // TODO: [ATEAM-2883] refactor this to use the module.api somehow rather than actions
//          props.module.attachmentsActions.updateAttachment(
//            new UpdateAttachmentPayload(toUpdate: toUpdate)
//          );
//        });
//      }
//    }
  }

  _areInputsDisabled() {
    return !state.hasSelectedRegion && _currentlySelected.isEmpty;
  }

  _handleAttachmentFileNameChange(react.SyntheticEvent event) {
    if (props.onAttachmentFileNameChange != null && props.onAttachmentFileNameChange(event) == false) {
      return;
    }

    setState(newState()..attachmentFileName = event.target.value);
  }

  _handleAttachmentAuthorChange(react.SyntheticEvent event) {
    if (props.onAttachmentAuthorChange != null && props.onAttachmentAuthorChange(event) == false) {
      return;
    }

    setState(newState()..attachmentAuthor = event.target.value);
  }

  _handleSelectAttachment(AttachmentSelectedEventPayload result) {
//    if (result.selectedAttachmentKey != null) {
//      Bundle bundle = props.store.attachments.firstWhere((Attachment attachment) => attachment.id == result.selectedAttachmentKey);
//      _currentlySelected.add(result.selectedAttachmentKey);
//      setState(newState()
//        ..isUpdating = true
//        ..attachmentFileName = bundle.annotation.filename
//        ..attachmentAuthor = bundle.annotation.author
//        ..uploadStatus = _findUploadStatus(bundle)
//      );
//    } else {
//      setState(newState()
//        ..isUpdating = false
//      );
//    }
  }

  _handleUnselectAttachment(AttachmentDeselectedEventPayload result) {
    _currentlySelected.remove(result.deselectedAttachmentKey);
    setState(newState()..isUpdating = false);
    if (_areInputsDisabled()) {
      setState(getInitialState());
    }
  }

  _handleUploadStatusChange(react.SyntheticEvent event) {
    if (props.onUploadStatusChange != null && props.onUploadStatusChange(event) == false) {
      return;
    }

    setState(newState()..uploadStatus = _statusFromString(_toggleButtonGroupRef.getValue()));
  }

  bool get _selectedRegionExists {
    props.context.selectionApi.getCurrentSelections()?.isNotEmpty == true;
  }

  _handleRegionsDidChange(List<String> values) => redraw();

  _handleSelectionDidChange(_) {
    _currentlySelected = new Set<String>();
    setState(newState()..hasSelectedRegion = _selectedRegionExists);
  }
}
