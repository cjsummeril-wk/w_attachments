library w_attachments_client.test.components.attachment_label_file_test;

import '../attachment_test_constants.dart';
import 'dart:async';
import 'package:mockito/mirrors.dart';
import 'package:over_react_test/over_react_test.dart';
import 'package:test/test.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/components/component_test_ids.dart';

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/components/components.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';

import '../mocks/mocks_library.dart';
import '../test_utils.dart' as test_utils;
import 'package:web_skin_dart/ui_components.dart';

void main() {
  group('AttachmentFileLabel /', () {
    ExtensionContextMock _extensionContext;
    AnnotationsApiMock _annotationsApiMock;
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    AttachmentsStore _attachmentsStore;

    Object renderedCard;
    Object renderedAttachmentLabel;
    ClickToEditInputComponent labelInputComponent;

    setUp(() async {
      _extensionContext = new ExtensionContextMock();
      _annotationsApiMock = new AnnotationsApiMock();
      _attachmentsActions = new AttachmentsActions();
      _attachmentsEvents = new AttachmentsEvents();
      _extensionContext = new ExtensionContextMock();
      _attachmentsStore = spy(
          new AttachmentsStoreMock(),
          new AttachmentsStore(
              actionProviderFactory: StandardActionProvider.actionProviderFactory,
              attachmentsActions: _attachmentsActions,
              attachmentsEvents: _attachmentsEvents,
              annotationsApi: _annotationsApiMock,
              extensionContext: _extensionContext,
              dispatchKey: attachmentsModuleDispatchKey,
              attachments: [AttachmentTestConstants.mockAttachment],
              groups: []));
    });

    tearDown(() async {
      await _annotationsApiMock.dispose();
      await _extensionContext.dispose();
    });

    group('UI Features /', () {
      test('should render an attachment label when rendering an AttachmentCard', () {
        // Mount the attachment card, which contains the card header + label
        renderedCard = render(AttachmentCard()
          ..attachment = AttachmentTestConstants.mockAttachment
          ..store = _attachmentsStore
          ..actionProvider = _attachmentsStore.actionProvider);
        expect(renderedCard, isNotNull);
        // Check that the attachment card header exists
        test_utils.expectTestIdWasFound(renderedCard, AttachmentCardIds.attachmentCardHeaderId);
        // Check that the label exists
        test_utils.expectTestIdWasFound(renderedCard, AttachmentCardIds.attachmentFileLabelId);
      });

      test('should be uneditable ("alwaysReadOnly") if card is collapsed', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _attachmentsStore.attachmentsActions
          ..attachment = _attachmentsStore.attachments[0]
          ..isCardExpanded = false
          ..store = _attachmentsStore);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);
        expect(labelInputComponent.props.alwaysReadOnly, isTrue);
      });

      test('should be editable if card is expanded', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _attachmentsStore.attachmentsActions
          ..attachment = _attachmentsStore.attachments[0]
          ..isCardExpanded = true
          ..store = _attachmentsStore);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);
        expect(labelInputComponent.props.alwaysReadOnly, isFalse);
      });

      test('CTEInput should be a multiline input if field is active', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _attachmentsStore.attachmentsActions
          ..attachment = _attachmentsStore.attachments[0]
          ..isCardExpanded = true
          ..store = _attachmentsStore);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);

        labelInputComponent.enterEditable();
        expect(labelInputComponent.state.isEditable, isTrue);
        expect(labelInputComponent.props.isMultiline, isTrue);
      });

      test('CTEInput should not be a multiline input if field is not active', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _attachmentsStore.attachmentsActions
          ..attachment = _attachmentsStore.attachments[0]
          ..isCardExpanded = true
          ..store = _attachmentsStore);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);
        expect(labelInputComponent.state.isEditable, isFalse);
        expect(labelInputComponent.props.isMultiline, isFalse);
      });
    });

    group('Action triggers /', () {
      test('updateAttachmentLabel should fire when label is changed and field exits editable state', () async {
        Completer updateLabel =
            test_utils.hookinActionVerifier(_attachmentsStore.attachmentsActions.updateAttachmentLabel);

        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _attachmentsStore.attachmentsActions
          ..attachment = _attachmentsStore.attachments[0]
          ..isCardExpanded = true
          ..store = _attachmentsStore);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);

        labelInputComponent.enterEditable();
        labelInputComponent.setValue(AttachmentTestConstants.label);
        labelInputComponent.exitEditable();

        expect(updateLabel.future, completes);
      });
    });
  });
}
