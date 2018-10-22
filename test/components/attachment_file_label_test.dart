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
import 'package:w_session/mock.dart';
import 'package:w_session/w_session.dart';

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/components/components.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';

import '../mocks/mocks_library.dart';
import '../test_utils.dart' as test_utils;
import 'package:web_skin_dart/ui_components.dart';

void main() {
  group('AttachmentFileLabel /', () {
    AttachmentsModule _module;
    Session _session;
    ExtensionContextMock _extensionContext;
    AnnotationsApiMock _annotationsApiMock;
    MockMessagingClient _msgClient;
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    AttachmentsStore _attachmentsStore;

    Object renderedCard;
    Object renderedAttachmentLabel;
    ClickToEditInputComponent labelInputComponent;

    String configLabel = 'AttachmentPackage';

    setUp(() async {
      MockSession.install();

      _session = new Session();
      _extensionContext = new ExtensionContextMock();
      _msgClient = new MockMessagingClient();
      _annotationsApiMock = new AnnotationsApiMock();
      _attachmentsActions = new AttachmentsActions();
      _attachmentsEvents = new AttachmentsEvents();
      _extensionContext = new ExtensionContextMock();
      _attachmentsStore = new AttachmentsStore(
          actionProviderFactory: StandardActionProvider.actionProviderFactory,
          attachmentsActions: _attachmentsActions,
          attachmentsEvents: _attachmentsEvents,
          annotationsApi: _annotationsApiMock,
          extensionContext: _extensionContext,
          dispatchKey: attachmentsModuleDispatchKey,
          attachments: [AttachmentTestConstants.mockAttachment],
          groups: []);

      _module = new AttachmentsModule(
          config: new AttachmentsConfig(label: configLabel),
          session: _session,
          messagingClient: _msgClient,
          extensionContext: _extensionContext,
          annotationsApi: _annotationsApiMock,
          store: spy(new AttachmentsStoreMock(), _attachmentsStore),
          actionProviderFactory: StandardActionProvider.actionProviderFactory);

      await _module.load();

      // Mount the attachment card, which contains the card header + label
      renderedCard = render(AttachmentCard()
        ..attachment = AttachmentTestConstants.mockAttachment
        ..store = _module.store
        ..actionProvider = _module.actionProvider);

      expect(renderedCard, isNotNull);
    });

    tearDown(() async {
      await _session.dispose();
      await _extensionContext.dispose();
      await _annotationsApiMock.dispose();
      await _module.unload();
      await _msgClient.dispose();

      MockSession.uninstall();
    });

    group('UI Features /', () {
      test('should render an attachment label', () {
        // Check that the attachment card header exists
        test_utils.expectTestIdWasFound(renderedCard, AttachmentCardIds.attachmentCardHeaderId);
        // Check that the label exists
        test_utils.expectTestIdWasFound(renderedCard, AttachmentCardIds.attachmentFileLabelId);
      });

      test('should be uneditable ("alwaysReadOnly") if card is collapsed', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _module.attachmentsActions
          ..attachment = _module.store.attachments[0]
          ..isCardExpanded = false
          ..store = _module.store);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);
        expect(labelInputComponent.props.alwaysReadOnly, isTrue);
      });

      test('should be editable if card is expanded', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _module.attachmentsActions
          ..attachment = _module.store.attachments[0]
          ..isCardExpanded = true
          ..store = _module.store);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);
        expect(labelInputComponent.props.alwaysReadOnly, isFalse);
      });

      test('CTEInput should be a multiline input if field is active', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _module.attachmentsActions
          ..attachment = _module.store.attachments[0]
          ..isCardExpanded = true
          ..store = _module.store);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);

        labelInputComponent.enterEditable();
        expect(labelInputComponent.state.isEditable, isTrue);
        expect(labelInputComponent.props.isMultiline, isTrue);
      });

      test('CTEInput should not be a multiline input if field is not active', () {
        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _module.attachmentsActions
          ..attachment = _module.store.attachments[0]
          ..isCardExpanded = true
          ..store = _module.store);
        expect(renderedAttachmentLabel, isNotNull);

        labelInputComponent = getComponentByTestId(renderedAttachmentLabel, AttachmentCardIds.attachmentFileLabelId);
        expect(labelInputComponent, isNotNull);
        expect(labelInputComponent.state.isEditable, isFalse);
        expect(labelInputComponent.props.isMultiline, isFalse);
      });
    });

    group('Action triggers /', () {
      test('updateAttachmentLabel should fire when label is changed and field exits editable state', () async {
        Completer updateLabel = test_utils.hookinActionVerifier(_module.store.attachmentsActions.updateAttachmentLabel);

        renderedAttachmentLabel = render(AttachmentFileLabel()
          ..actions = _module.attachmentsActions
          ..attachment = _module.store.attachments[0]
          ..isCardExpanded = true
          ..store = _module.store);
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
