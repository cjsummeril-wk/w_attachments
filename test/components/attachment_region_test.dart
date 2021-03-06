import '../attachment_test_constants.dart';
import 'dart:async';
import 'package:over_react_test/over_react_test.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/mirrors.dart';
import 'package:w_session/mock.dart';
import 'package:web_skin_dart/ui_components.dart';

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/components/component_test_ids.dart';
import 'package:w_attachments_client/src/components/components.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';

import '../mocks/mocks_library.dart';
import '../test_utils.dart' as test_utils;

void main() {
  group('Components / Attachment Region /', () {
    ExtensionContextMock _extensionContext;
    AnnotationsApiMock _annotationsApiMock;
    AttachmentsStore _store;

    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;

    var rendered;

    setUp(() async {
      MockSession.install();
      _extensionContext = new ExtensionContextMock();
      _annotationsApiMock = new AnnotationsApiMock();
      _attachmentsActions = new AttachmentsActions();
      _attachmentsEvents = new AttachmentsEvents();
      _extensionContext = new ExtensionContextMock();
      _annotationsApiMock = new AnnotationsApiMock();
      _store = spy(
          new AttachmentsStoreMock(),
          new AttachmentsStore(
              actionProviderFactory: StandardActionProvider.actionProviderFactory,
              attachmentsActions: _attachmentsActions,
              attachmentsEvents: _attachmentsEvents,
              annotationsApi: _annotationsApiMock,
              extensionContext: _extensionContext,
              dispatchKey: attachmentsModuleDispatchKey,
              attachments: [AttachmentTestConstants.defaultAttachment],
              groups: [],
              moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage')));

      _store.attachments = [AttachmentTestConstants.defaultAttachment];
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage];

      rendered = render((AttachmentRegion()
        ..actions = _attachmentsActions
        ..store = _store
        ..attachment = AttachmentTestConstants.defaultAttachment
        ..currentSelection = _store.currentSelection
        ..references = _store.usagesByAttachmentId(AttachmentTestConstants.defaultAttachment.id)
        ..attachmentCounter = 1
        ..targetKey = AttachmentTestConstants.defaultAttachment.id));
    });

    test('Attachment Region holds a reference and has basic structure', () {
      test_utils.expectTestIdWasFound(rendered, '${ReferenceViewTestIds.rvReference}-1');
      test_utils.expectTestIdWasFound(rendered, ReferenceViewTestIds.referenceButtons);
      test_utils.expectTestIdWasFound(rendered, ReferenceViewTestIds.referenceText);
    });

    test('Attachment Region can create a new Reference within', () {
      Completer addReference = test_utils.hookinActionVerifier(_store.attachmentsActions.createAttachmentUsage);
      test_utils.expectTestIdWasFound(rendered, '${ReferenceViewTestIds.rvAttachment}-1');

      when(_store.isValidSelection).thenReturn(true);

      click(getByTestId(getByTestId(rendered, '${ReferenceViewTestIds.rvAttachment}-1'), 'wsd.hitarea'));

      ButtonComponent addReferenceButtonComponent =
          getDartComponent(getByTestId(rendered, ReferenceViewTestIds.addReferenceButton));
      var addReferenceButton = getComponentRootDomByTestId(rendered, ReferenceViewTestIds.addReferenceButton);
      expect(addReferenceButtonComponent, isNotNull);
      expect(addReferenceButtonComponent.props.isDisabled, isFalse);
      click(addReferenceButton);
      expect(addReference.future, completes);

      when(_annotationsApiMock.createAttachmentUsage(producerWurl: any, attachmentId: 1234)).thenAnswer((_) =>
          new Future.value(new CreateAttachmentUsageResponse(
              anchor: AttachmentTestConstants.mockAnchor,
              attachmentUsage: AttachmentTestConstants.addedUsage,
              attachment: AttachmentTestConstants.defaultAttachment)));

      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.addedUsage];

      rendered = render((AttachmentRegion()
        ..actions = _attachmentsActions
        ..store = _store
        ..attachment = AttachmentTestConstants.defaultAttachment
        ..currentSelection = _store.currentSelection
        ..references = _store.usagesByAttachmentId(AttachmentTestConstants.defaultAttachment.id)
        ..attachmentCounter = 0
        ..targetKey = AttachmentTestConstants.defaultAttachment.id));

      expect(_store.attachmentUsages.length, 2);
      expect(_store.usagesByAttachmentId(AttachmentTestConstants.defaultAttachment.id).length, 2);
    });
  });
}
