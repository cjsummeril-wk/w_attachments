library w_attachments_client.test.attachments_store_test;

import 'dart:async';
import 'dart:mirrors';

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/models/models.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_attachments_client/src/payloads/module_actions.dart';

import './mocks/mocks_library.dart';
import 'attachment_test_constants.dart';
import 'test_utils.dart' as test_utils;

Matcher attachmentsAreSelected(AttachmentsStore store, Iterable expected) =>
    new _AttachmentsAreSelected(store, expected);

class _AttachmentsAreSelected extends Matcher {
  // Given a store and an expected list of ID's, match whether the store ONLY has the given
  // ID's currently selected.
  final List _expectedValues;
  final AttachmentsStore _store;
  _AttachmentsAreSelected(AttachmentsStore store, Iterable expected)
      : _expectedValues = expected.toList(),
        _store = store;
  @override
  Description describe(Description description) => description
      .add('The store "')
      .addDescriptionOf(_store)
      .add('" has the correct selected items IDs as given by "')
      .addDescriptionOf(_expectedValues)
      .add('"');
  @override
  bool matches(item, Map matchState) {
    for (int id in _expectedValues) {
      if (!_store.attachmentIsSelected(id)) {
        return false;
      }
    }
    if (_store.currentlySelectedAttachments.length == _expectedValues.length) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Description describeMismatch(item, Description failDescription, Map matchState, bool verbose) => failDescription
      .add('Store does not have the correct elements selected. Expected:"')
      .addDescriptionOf(_expectedValues)
      .add('" But got:"')
      .addDescriptionOf(_store.currentlySelectedAttachments)
      .add('"');
}

AttachmentsStore generateDefaultStore({bool spyMode: false, AnnotationsApiMock annotationsApiMock: null, ExtensionContextMock extensionContextMock: null, AttachmentsConfig config: null}) {
  // Generate an Attachments Store with basic values.
  AttachmentsActions actions = new AttachmentsActions();
  AttachmentsEvents events = new AttachmentsEvents();
  annotationsApiMock ??= new AnnotationsApiMock();
  extensionContextMock ??= new ExtensionContextMock();
  AttachmentsStore default_store = new AttachmentsStore(
    actionProviderFactory: StandardActionProvider.actionProviderFactory,
    attachmentsActions: actions,
    attachmentsEvents: events,
    annotationsApi: annotationsApiMock,
    extensionContext: extensionContextMock,
    dispatchKey: attachmentsModuleDispatchKey,
    attachments: [],
    groups: [],
    moduleConfig: config
  );
  if (spyMode) {
    return spy(new AttachmentsStoreMock(),
      default_store);
  } else {
    return default_store;
  }
}

List<Attachment> defaultAttachments = [
  AttachmentTestConstants.mockAttachment,
  AttachmentTestConstants.mockChangedAttachment
];

List<DeclarationMirror> getStoreConstructorMirror() {
  ClassMirror mirror = reflectClass(AttachmentsStore);
  return new List.from(mirror.declarations.values.where((member) {
    return member is MethodMirror && member.isConstructor;
  }));
}

void main() {
  group('<<Constructor Group>>', () {

    String validWurl = 'wurl://docs.v1/doc:962DD25A85142FBBD7AC5AC84BAE9BD6';
    String testUsername = 'Ron Swanson';
    String veryGoodResourceId = 'very good resource id';
    String veryGoodSectionId = 'very good section id';

    final String configLabel = 'AttachmentPackage';

    group('Ensure only one constructor of attachments store.', () {
      test('AttachmentsStore should have 1 constructor', () {
        List<DeclarationMirror> constructors = getStoreConstructorMirror();
        expect(constructors, hasLength(1));
      });

      test('Constructor should contain correct parameter names.', () {
        // This test does not test the order of the parameter names.
        // It only tests that all of the paramters are present.
        // Arrange
        List<String> expectedParameterNames = [
          'actionProviderFactory',
          'attachmentsActions',
          'annotationsApi',
          'attachmentsEvents',
          'dispatchKey',
          'extensionContext',
          'moduleConfig',
          'attachments',
          'groups',
          'initialFilters'
        ];
        List<String> actualParameterNames = [];
        MethodMirror constructor = getStoreConstructorMirror()[0];
        List<ParameterMirror> parameters = constructor.parameters;

        // Act
        for (ParameterMirror parameter in parameters) {
          Symbol symbolName = parameter.simpleName;
          String actualName = MirrorSystem.getName(symbolName);
          actualParameterNames.add(actualName);
        }

        // Assert
        expect(expectedParameterNames, unorderedEquals(actualParameterNames));
      });

      test('Test the default values of the constructor.', () {
        // Arrange and Act
        AttachmentsStore test_store = generateDefaultStore();

        // Assert.
        expect(test_store.enableDraggable, isTrue);
        expect(test_store.enableUploadDropzones, isTrue);
        expect(test_store.enableClickToSelect, isTrue);
        expect(test_store.api.primarySelection, isNull);
        expect(test_store.actionProvider.runtimeType, equals(StandardActionProvider));
        expect(test_store.enableDraggable, isTrue);
        expect(test_store.enableUploadDropzones, isTrue);
        expect(test_store.enableClickToSelect, isTrue);
      });

      test('Test that parameters set by the constructor actually get set.', () {
        // Arrange
        AttachmentsConfig nonDefaultConfig = new AttachmentsConfig(
            enableDraggable: false,
            enableUploadDropzones: false,
            enableClickToSelect: false,
            primarySelection: validWurl,
            label: configLabel);
        ExtensionContextMock _extensionContext = new ExtensionContextMock();
        AttachmentsActions _actions = new AttachmentsActions();
        AttachmentsEvents _events = new AttachmentsEvents();
        AnnotationsApiMock _annotationsApiMock = new AnnotationsApiMock();

        // Act
        AttachmentsStore test_store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _actions,
            attachmentsEvents: _events,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: [],
            moduleConfig: nonDefaultConfig);

        // Assert
        expect(test_store.enableDraggable, isFalse);
        expect(test_store.enableUploadDropzones, isFalse);
        expect(test_store.enableClickToSelect, isFalse);
        expect(test_store.api.primarySelection, isNotNull);
        expect(test_store.api.primarySelection, equals(validWurl));
      });
    });

    group('setGroups', () {
      AttachmentsStore _store;
      AttachmentsApi _api;
      AttachmentsActions _actions;
      setUp(() {
        _store = generateDefaultStore();
        _api = _store.api;
        _actions = _store.attachmentsActions;
      });

      test('should not require a group in the groups list', () async {
        // test that no groups exist if an empty list is passed on initializing the store
        expect(_store.groups, []);
        // test that setGroups with an empty list works as expected
        await _api.setGroups(groups: [new ContextGroup(name: 'some group')]);
        expect(_store.groups.length, 1);
        await _api.setGroups(groups: []);
        expect(_store.groups, allOf(isList, isEmpty));
      });

      test('should set panel view mode to headerless when a single group is specified as headerless', () async {
        ContextGroup headerlessGroup = new ContextGroup(name: 'headerless', displayAsHeaderless: true);
        await _api.setGroups(groups: [headerlessGroup]);

        expect(_api.showingHeaderlessGroup, isTrue);
        expect(_api.currentlyDisplayedSingle, headerlessGroup);
      });

      test('should filter attachments based on ALL type group pivot', () async {
        Attachment attachment = new Attachment()
          ..id = 1
          ..filename = 'very_good_file.docx'
          ..userName = testUsername;
        _actions.addAttachment(new AddAttachmentPayload(toAdd: attachment));
        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments, isNotEmpty);
        expect(_api.groups[0].attachments.any((attach) => attach == attachment), isTrue);
      });
    });

    group('loadAttachments', () {
      List<Attachment> happyPathAttachments;
      List<AttachmentUsage> happyPathUsages;
      List<Anchor> happyPathAnchors;

      setUp(() {
        // Subject

        // Responses
        happyPathAttachments = [
          new Attachment()
            ..id = 1
            ..filename = 'firstdoc.docx',
          new Attachment()
            ..id = 2
            ..filename = 'seconddoc.xlsx',
          new Attachment()
            ..id = 3
            ..filename = 'thirddoc.pptx'
        ];
        happyPathUsages = [
          new AttachmentUsage()
            ..id = 4
            ..attachmentId = 1
            ..anchorId = 7,
          new AttachmentUsage()
            ..id = 5
            ..attachmentId = 2
            ..anchorId = 8,
          new AttachmentUsage()
            ..id = 6
            ..attachmentId = 3
            ..anchorId = 9
        ];
        happyPathAnchors = [
          new Anchor()
            ..id = 7
            ..producerWurl =
                'wurl://sheets.v0/0:sheets_26858afc0f1541d88598db63c757f66c/1:sheets_26858af6858afc0f1541d88598db63c757f66c_3a92c44fb39b46ce9d138fd88dcc8af7_0-0-1-1-1',
          new Anchor()
            ..id = 8
            ..producerWurl =
                'wurl://sheets.v0/0:sheets_26858afc0f1541d88598db63c757f66c/1:sheets_26858af6858afc0f1541d88598db63c757f66c_3a92c44fb39b46ce9d138fd88dcc8af7_10-4-1-1-3',
          new Anchor()
            ..id = 9
            ..producerWurl =
                'wurl://sheets.v0/0:sheets_26858afc0f1541d88598db63c757f66c/1:sheets_26858af6858afc0f1541d88598db63c757f66c_3a92c44fb39b46ce9d138fd88dcc8af7_6-3-1-1-2'
        ];
      });

      group('Attachment store handles getAttachmentsByIds', () {
        AttachmentsStore _store;
        AnnotationsApiMock _annotationsApiMock;
        AttachmentsActions _actions;
        // Attachments that have no correlating usage (in happy path)
        List<Attachment> noMatchAttachments;
        // Attachments that have some correlating usage (in happy path)
        List<Attachment> twoMatchAttachments;

        setUp(() {
          _annotationsApiMock = new AnnotationsApiMock();
          _store = generateDefaultStore(spyMode: true, annotationsApiMock: _annotationsApiMock);
          _actions = _store.attachmentsActions;
          noMatchAttachments = [
            new Attachment()
              ..id = 99
              ..filename = 'wut.jpg',
            new Attachment()
              ..id = 98
              ..filename = 'idgaf.docx',
            new Attachment()
              ..id = 97
              ..filename = 'ihop.xlsx'
          ];

          twoMatchAttachments = [
            new Attachment()
              ..id = 1
              ..filename = 'who.pdf',
            new Attachment()
              ..id = 2
              ..filename = 'let_the.gif',
            new Attachment()
              ..id = 97
              ..filename = 'dogs_out.png'
          ];
        });

        tearDown(() {
          _store.dispose();
          _annotationsApiMock.dispose();
        });

        test('(happy path)', () async {
          // Arrange
          List<int> getIds = [1, 2, 3];
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: getIds)).thenReturn(happyPathAttachments);

          // Act
          await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: getIds));

          // Assert
          expect(_store.attachments.length, equals(3));
        });

        test('overwrites the results that match correlating usage referencing attachment id', () async {
          // Arrange
          List<int> getIds = [1, 2, 97];
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: getIds)).thenReturn(twoMatchAttachments);

          // Act
          await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: getIds));

          // Assert
          expect(_store.attachments.length, equals(2));
        });

        test('does not insert attachments without correlating usage referencing attachment id', () async {
          // Arrange
          List<int> getIds = [97, 98, 99];
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: getIds)).thenReturn(noMatchAttachments);

          // Act
          await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: getIds));

          // Assert
          expect(_store.attachments.length, equals(0));
        });

        test('does not perform any action if the payload is empty or null', () async {
          // Arrange
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds).thenReturn(happyPathAttachments);

          // Act (1/2)
          await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: null));
          // Assert (1/2)
          verifyNever(_annotationsApiMock.getAttachmentsByIds);

          // Act (2/2)
          await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: []));
          // Assert (2/2)
          verifyNever(_annotationsApiMock.getAttachmentsByIds);
        });

        // TODO RAM-732 App Intelligence
        // test('store logs when it receives attachments out of scope', () async {

      });
    });

    group('AttachmentsStore attachment actions', () {
        AttachmentsStore _store;
        AttachmentsActions _actions;
      setUp(() {
        _store = generateDefaultStore(spyMode: true);
        _actions = _store.attachmentsActions;
        _store.attachmentUsages = [AttachmentTestConstants.mockAttachmentUsage];
        _store.attachments = [AttachmentTestConstants.mockAttachment];
      });

      tearDown(() async {
        // eliminate all attachments in the store cache, cancelUpload handles all cases that loadAttachments doesn't
        _store.dispose();
        _actions.dispose();
      });

      test('addAttachment should add an attachment to the stored list of attachments', () async {
        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _actions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_store.attachments, [AttachmentTestConstants.mockAttachment, attachment]);
      });

      test('addAttachment should should not add an attachment already in the attachments list', () async {
        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _actions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        // adding the same attachment again should not modify the list
        await _actions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_store.attachments, [AttachmentTestConstants.mockAttachment, attachment]);
      });

//      test('upsertAttachment should update if bundle exists, add if doesn\'t exist', () async {
//        Attachment attachment = new Attachment()
//          ..filename = 'very_good_file.docx'
//          ..id = 1
//          ..userName = testUsername;
//        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));
//
//        expect(_store.attachments, isEmpty);
//
//        _attachmentsActions.upsertAttachment(new UpsertAttachmentPayload(toUpsert: attachment));
//        await new Future.delayed(Duration.ZERO);
//        expect(_store.attachments, [attachment]);
//        expect(_store.attachments[0].userName, 'Ron Swanson');
//
//        attachment.userName = 'Harvey Birdman';
//
//        _attachmentsActions.upsertAttachment(new UpsertAttachmentPayload(toUpsert: attachment));
//        await new Future.delayed(Duration.ZERO);
//        expect(_store.attachments, [attachment]);
//        expect(_store.attachments[0].userName, 'Harvey Birdman');
//      });

      test('default state of selected/hovered data - assert setup method', () {
        expect(_store.currentlySelectedAnchors, isEmpty);
        expect(_store.currentlySelectedAttachmentUsages, isEmpty);
        expect(_store.currentlySelectedAttachments, isEmpty);
        expect(_store.currentlyHoveredAttachmentId, isNull);
      });

      test('selectAttachment should set the store\'s currentlySelectedAttachments/Anchors with the passed in arg',
          () async {
        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockAttachment.id], maintainSelections: false));

        expect(_store.attachmentIsSelected(AttachmentTestConstants.mockAttachment.id), isTrue);
        expect(_store.currentlySelectedAnchors, allOf(hasLength(1), contains(AttachmentTestConstants.anchorIdOne)));
      });

      test('selectAttachment sets currentlySelectedAttachment, but not Anchor when usage is not present', () async {
        // simulates an attachment with no usages
        _store.attachmentUsages = [];

        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockAttachment.id], maintainSelections: false));

        expect(_store.attachmentIsSelected(AttachmentTestConstants.mockAttachment.id), isTrue);
        expect(_store.currentlySelectedAnchors, isEmpty);
      });

      test('should be able to select multiple attachments by IDs in single call', () async {
        // Arrange
        _store.attachmentUsages = [
          AttachmentTestConstants.mockAttachmentUsage,
          AttachmentTestConstants.mockChangedAttachmentUsage
        ];
        _store.attachments = defaultAttachments;
        List<int> expectedAttachmentIds = [
          AttachmentTestConstants.mockAttachment.id,
          AttachmentTestConstants.mockChangedAttachment.id
        ];
        List<int> expectedAnchorIds = [AttachmentTestConstants.anchorIdOne, AttachmentTestConstants.anchorIdTwo];

        // Act
        await _actions.selectAttachments(
            new SelectAttachmentsPayload(attachmentIds: expectedAttachmentIds, maintainSelections: false));

        // Assert
        expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedAttachmentIds));
        expect(_store.currentlySelectedAnchors, unorderedEquals(expectedAnchorIds));
      });

      test('should be able to select multiple attachments by ID one at a time maintaining selections', () async {
        // Arrange
        _store.attachmentUsages = [
          AttachmentTestConstants.mockAttachmentUsage,
          AttachmentTestConstants.mockChangedAttachmentUsage
        ];
        _store.attachments = defaultAttachments;
        List<int> expectedAttachmentIds = [
          AttachmentTestConstants.mockAttachment.id,
          AttachmentTestConstants.mockChangedAttachment.id
        ];
        List<int> expectedAnchorIds = [AttachmentTestConstants.anchorIdOne, AttachmentTestConstants.anchorIdTwo];

        // Act
        await _actions.selectAttachments(
            new SelectAttachmentsPayload(attachmentIds: [expectedAttachmentIds[0]], maintainSelections: false));
        await _actions.selectAttachments(
            new SelectAttachmentsPayload(attachmentIds: [expectedAttachmentIds[1]], maintainSelections: true));

        // Assert
        expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedAttachmentIds));
        expect(_store.currentlySelectedAnchors, unorderedEquals(expectedAnchorIds));
      });

      test('should be able to select an attachment by ID and clear the list', () async {
        // Arrange
        _store.attachmentUsages = [
          AttachmentTestConstants.mockAttachmentUsage,
          AttachmentTestConstants.mockChangedAttachmentUsage
        ];
        _store.attachments = defaultAttachments;
        // A single item list is needed here for the matchers.
        List<int> expectedAttachmentId = [AttachmentTestConstants.mockChangedAttachment.id];
        List<int> expectedAnchorId = [AttachmentTestConstants.anchorIdTwo];

        // Act
        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockAttachment.id], maintainSelections: false));
        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockChangedAttachment.id], maintainSelections: false));

        // Assert
        expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedAttachmentId));
        expect(_store.currentlySelectedAnchors, unorderedEquals(expectedAnchorId));
      });

      test('The attachment store can add a single attached item.', () async {
        // Arrange
        List<int> expectedSelection = [AttachmentTestConstants.mockAttachment.id];

        // Act
        await _actions.selectAttachments(
            new SelectAttachmentsPayload(attachmentIds: expectedSelection, maintainSelections: true));

        // Assert
        expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedSelection));
      });

      test('deselectAttachments should be able to deselect an attachment by id', () async {
        // Arrange
        List<String> expectedSelection = [];

        // Act
        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockAttachment.id], maintainSelections: true));
        await _actions.deselectAttachments(
            new DeselectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.mockAttachment.id]));

        // Assert
        expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedSelection));
        expect(_store.currentlySelectedAnchors, isEmpty);
      });

      test('deselectAttachments should be able to deselect an attachment by id', () async {
        // Arrange
        List<String> expectedSelection = [];

        // Act
        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockAttachment.id], maintainSelections: true));
        await _actions.deselectAttachments(
            new DeselectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.mockAttachment.id]));

        // Assert
        expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedSelection));
        expect(_store.currentlySelectedAnchors, isEmpty);
      });
      // This test is duplicated!!!!!!!
      test('should be able to select multiple attachments by ID one at a time maintaining selections', () async {
        _store.attachments = defaultAttachments;

        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockAttachment.id], maintainSelections: false));

        await _actions.selectAttachments(new SelectAttachmentsPayload(
            attachmentIds: [AttachmentTestConstants.mockChangedAttachment.id], maintainSelections: true));
        expect(_store.currentlySelectedAttachments.length, 2);
        expect(_store.attachmentIsSelected(AttachmentTestConstants.mockAttachment.id), isTrue);
        expect(_store.attachmentIsSelected(AttachmentTestConstants.mockChangedAttachment.id), isTrue);
      });

      test('selectAttachment should make no selections when no IDs are provided', () async {
        await _actions.selectAttachments(new SelectAttachmentsPayload());

        expect(_store.currentlySelectedAttachments, isEmpty);
        expect(_store.currentlySelectedAttachmentUsages, isEmpty);
        expect(_store.currentlySelectedAnchors, isEmpty);
      });

      // The maintainSelections parameter does not seem to change any internal state.
      test('deselectAttachmentUsage should remove no selections when no IDs are provided', () async {
        await _actions.selectAttachments(
            new SelectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.mockAttachment.id]));
        await _actions.deselectAttachments(new DeselectAttachmentsPayload(attachmentIds: []));

        expect(_store.currentlySelectedAttachments, isNotEmpty);
        expect(_store.currentlySelectedAnchors, isNotEmpty);
      });

      test('selectAttachmentUsages should set the store\'s currentlySelectedAttachmentUsages with the passed in arg',
          () async {
        _store.attachmentUsages = [
          AttachmentTestConstants.mockAttachmentUsage,
          AttachmentTestConstants.mockChangedAttachmentUsage
        ];

        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(usageIds: [
          AttachmentTestConstants.mockAttachmentUsage.id,
          AttachmentTestConstants.mockChangedAttachmentUsage.id
        ], maintainSelections: false));

        expect(_store.attachmentIsSelected(AttachmentTestConstants.mockAttachment.id), isFalse);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockAttachmentUsage.id), isTrue);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockChangedAttachmentUsage.id), isTrue);
        expect(_store.currentlySelectedAnchors,
            allOf(contains(AttachmentTestConstants.anchorIdTwo), contains(AttachmentTestConstants.anchorIdOne)));
      });

      test('deselectAttachmentUsages should be able to deselect an attachment usage by id', () async {
        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
            usageIds: [AttachmentTestConstants.mockAttachmentUsage.id], maintainSelections: false));

        await _actions.deselectAttachmentUsages(
            new DeselectAttachmentUsagesPayload(usageIds: [AttachmentTestConstants.mockAttachmentUsage.id]));

        expect(_store.currentlySelectedAttachments, isEmpty);
        expect(_store.currentlySelectedAnchors, isEmpty);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockAttachmentUsage.id), isFalse);
      });

      test("selectAttachmentUsages should only set the store's currentlySelectedAttachmentUsages where specified",
          () async {
        _store.attachmentUsages = [
          AttachmentTestConstants.mockAttachmentUsage,
          AttachmentTestConstants.mockChangedAttachmentUsage
        ];

        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
            usageIds: [AttachmentTestConstants.mockChangedAttachmentUsage.id], maintainSelections: false));

        expect(_store.attachmentIsSelected(AttachmentTestConstants.mockAttachment.id), isFalse);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockAttachmentUsage.id), isFalse);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockChangedAttachmentUsage.id), isTrue);
        expect(_store.currentlySelectedAnchors, contains(AttachmentTestConstants.anchorIdTwo));
      });

      test('should be able to select multiple attachment usages by IDs in single call', () async {
        _store.attachmentUsages = [
          AttachmentTestConstants.mockAttachmentUsage,
          AttachmentTestConstants.mockChangedAttachmentUsage
        ];

        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(usageIds: [
          AttachmentTestConstants.mockAttachmentUsage.id,
          AttachmentTestConstants.mockChangedAttachmentUsage.id
        ], maintainSelections: false));

        expect(_store.currentlySelectedAttachmentUsages.length, 2);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockAttachmentUsage.id), isTrue);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockChangedAttachmentUsage.id), isTrue);
        expect(
            _store.currentlySelectedAnchors,
            allOf(hasLength(2), contains(AttachmentTestConstants.anchorIdOne),
                contains(AttachmentTestConstants.anchorIdTwo)));
      });

      test('should be able to select multiple attachment usages by ID one at a time maintaining selections', () async {
        _store.attachmentUsages = [
          AttachmentTestConstants.mockAttachmentUsage,
          AttachmentTestConstants.mockChangedAttachmentUsage
        ];

        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
            usageIds: [AttachmentTestConstants.mockAttachmentUsage.id], maintainSelections: false));

        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
            usageIds: [AttachmentTestConstants.mockChangedAttachmentUsage.id], maintainSelections: true));

        expect(_store.currentlySelectedAttachmentUsages.length, 2);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockAttachmentUsage.id), isTrue);
        expect(_store.usageIsSelected(AttachmentTestConstants.mockChangedAttachmentUsage.id), isTrue);
      });

      test('selectAttachmentUsage should make no selections when no IDs are provided', () async {
        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(usageIds: []));

        expect(_store.currentlySelectedAttachmentUsages, isEmpty);
        expect(_store.currentlySelectedAnchors, isEmpty);
      });

      test('deselectAttachmentUsage should remove no selections when no IDs are provided', () async {
        await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
            usageIds: [AttachmentTestConstants.mockAttachmentUsage.id], maintainSelections: false));
        await _actions.deselectAttachmentUsages(new DeselectAttachmentUsagesPayload(usageIds: []));

        expect(_store.currentlySelectedAttachmentUsages, isNotEmpty);
        expect(_store.currentlySelectedAnchors, isNotEmpty);
      });

      test('hoverAttachment changes currentlyHovered to provided next id from null', () async {
        await _actions.hoverAttachment(new HoverAttachmentPayload(
            previousAttachmentId: null, nextAttachmentId: AttachmentTestConstants.attachmentIdOne));

        expect(_store.currentlyHoveredAttachmentId, AttachmentTestConstants.attachmentIdOne);
      });

      test('hoverAttachment changes currentlyHovered from previous id to next id', () async {
        await _actions.hoverAttachment(new HoverAttachmentPayload(
            previousAttachmentId: null, nextAttachmentId: AttachmentTestConstants.attachmentIdOne));

        await _actions.hoverAttachment(new HoverAttachmentPayload(
            previousAttachmentId: AttachmentTestConstants.attachmentIdOne,
            nextAttachmentId: AttachmentTestConstants.attachmentIdTwo));

        expect(_store.currentlyHoveredAttachmentId, AttachmentTestConstants.attachmentIdTwo);
      });

      test('hoverAttachment changes currentlyHovered from previous id to null', () async {
        await _actions.hoverAttachment(new HoverAttachmentPayload(
            previousAttachmentId: null, nextAttachmentId: AttachmentTestConstants.attachmentIdOne));

        await _actions.hoverAttachment(new HoverAttachmentPayload(
            previousAttachmentId: AttachmentTestConstants.attachmentIdOne, nextAttachmentId: null));

        expect(_store.currentlyHoveredAttachmentId, null);
      });
    });

    group('config', () {
      AttachmentsStore _store;
      setUp(() {
        _store = generateDefaultStore();
      });

      tearDown(() {
        _store.dispose();
      });
      // This test does not take into account the default configuration values.
      // If the default values match the expected values, then there is no proof
      // that setting those values was done by the default or by the test.
      test('properties from config are exposed properly', () {
        AttachmentsConfig config = new AttachmentsConfig(
            enableClickToSelect: true,
            enableDraggable: true,
            enableLabelEdit: true,
            enableUploadDropzones: true,
            label: 'Config Label',
            primarySelection: validWurl,
            showFilenameAsLabel: true);

        _store = generateDefaultStore(config: config);

        expect(_store.enableDraggable, config.enableDraggable);
        expect(_store.enableLabelEdit, config.enableLabelEdit);
        expect(_store.enableUploadDropzones, config.enableUploadDropzones);
        expect(_store.enableClickToSelect, config.enableClickToSelect);
        expect(_store.showFilenameAsLabel, config.showFilenameAsLabel);
        expect(_store.label, config.label);
        expect(_store.primarySelection, config.primarySelection);
      });

      test('properties are updated when config is updated', () async {
        AttachmentsConfig config = new AttachmentsConfig(
            enableClickToSelect: true,
            enableDraggable: true,
            enableLabelEdit: true,
            enableUploadDropzones: true,
            label: 'Config Label',
            primarySelection: validWurl,
            showFilenameAsLabel: true,
            zipSelection: validWurl);

        _store = generateDefaultStore(config: config);

        expect(_store.enableDraggable, config.enableDraggable);
        expect(_store.enableLabelEdit, config.enableLabelEdit);
        expect(_store.enableUploadDropzones, config.enableUploadDropzones);
        expect(_store.enableClickToSelect, config.enableClickToSelect);
        expect(_store.showFilenameAsLabel, config.showFilenameAsLabel);
        expect(_store.label, config.label);
        expect(_store.primarySelection, config.primarySelection);

        config = new AttachmentsConfig(
            enableClickToSelect: !config.enableClickToSelect,
            enableDraggable: !config.enableDraggable,
            enableLabelEdit: !config.enableLabelEdit,
            enableUploadDropzones: !config.enableUploadDropzones,
            label: 'Config 2',
            primarySelection: validWurl,
            showFilenameAsLabel: !config.showFilenameAsLabel);

        await _store.api.updateAttachmentsConfig(config);

        expect(_store.enableDraggable, config.enableDraggable);
        expect(_store.enableLabelEdit, config.enableLabelEdit);
        expect(_store.enableUploadDropzones, config.enableUploadDropzones);
        expect(_store.enableClickToSelect, config.enableClickToSelect);
        expect(_store.showFilenameAsLabel, config.showFilenameAsLabel);
        expect(_store.label, config.label);
        expect(_store.primarySelection, config.primarySelection);
      });
    });

    group('handles onDidChangeSelection -', () {
      AttachmentsStore _store;
      ExtensionContextMock _extensionContext;
      setUp(() {
        _extensionContext = new ExtensionContextMock();
        _store = generateDefaultStore(spyMode: true, extensionContextMock: _extensionContext);
      });

      tearDown(() {
        _extensionContext.dispose();
        _store.dispose();
      });

      test('updates isValidSelection and triggers correctly', () async {
        // store should only trigger once.
        // if it triggers twice completer raises an exception.
        final onChange = new Completer();
        _store.listen(onChange.complete);
        // defaults to false
        expect(_store.isValidSelection, false);
        _extensionContext.selectionApi.didChangeSelectionsController.add([]);
        await new Future(() {});
        expect(_store.isValidSelection, false);
        _extensionContext.selectionApi.didChangeSelectionsController
            .add([new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope)]);
        await onChange.future;
        expect(_store.isValidSelection, true);
      });
    });

    group('createAttachmentUsage -', () {
      AttachmentsStore _store;
      AnnotationsApiMock _annotationsApiMock;
      AttachmentsActions _actions;
      ExtensionContextMock _extensionContext;
      setUp(() {
        _annotationsApiMock = new AnnotationsApiMock();
        _extensionContext = new ExtensionContextMock();
        _store = generateDefaultStore(spyMode: true, annotationsApiMock: _annotationsApiMock, extensionContextMock: _extensionContext);
        _actions = _store.attachmentsActions;
      });

      tearDown(() async {
        await _actions.dispose();
        await _extensionContext.dispose();
        await _store.dispose();
      });

      test('does nothing if isValidSelection is false', () async {
        // Arrange
        CreateAttachmentUsagePayload payload = new CreateAttachmentUsagePayload(
            producerSelection:
                new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope));

        // Act
        await _actions.createAttachmentUsage(payload);

        // Assert
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any, attachmentId: any));
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any));
      });

      test('does nothing if isValidSelection is false due to discontiguous selections', () async {
        // Arrange
        final contiguousSelection =
            new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope);
        final aSecondContiguousSelection =
            new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope);
        // make sure isValidSelection is false by discontiguity
        _extensionContext.selectionApi.didChangeSelectionsController
            .add([contiguousSelection, aSecondContiguousSelection]);
        CreateAttachmentUsagePayload payload = new CreateAttachmentUsagePayload(
            producerSelection:
                new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope));

        // Act
        await _actions.createAttachmentUsage(payload);

        // Assert
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any, attachmentId: any));
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any));
      });

      test('calls createAttachmentUsage with valid selection, adds new Anchor, AttachmentUsage and Attachment to store',
          () async {
        // Arrange
        final testSelection =
            new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope);
        // make sure isValidSelection is true
        _extensionContext.selectionApi.didChangeSelectionsController.add([testSelection]);
        when(_extensionContext.selectionApi.getCurrentSelections()).thenReturn([testSelection]);
        when(_extensionContext.observedRegionApi.create(selection: testSelection)).thenReturn(
            new cef.ObservedRegion(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope));
        _extensionContext.selectionApi.didChangeSelectionsController.add([testSelection]);
        when(_annotationsApiMock.createAttachmentUsage(producerWurl: any, attachmentId: any)).thenAnswer((_) =>
            new Future.value(new CreateAttachmentUsageResponse(
                anchor: AttachmentTestConstants.mockAnchor,
                attachmentUsage: AttachmentTestConstants.mockAttachmentUsage,
                attachment: AttachmentTestConstants.mockAttachment)));

        // Act
        await _actions.createAttachmentUsage(new CreateAttachmentUsagePayload(
            producerSelection: testSelection, attachmentId: AttachmentTestConstants.attachmentIdOne));

        // Assert
        verify(_annotationsApiMock.createAttachmentUsage(
            producerWurl: AttachmentTestConstants.testWurl, attachmentId: AttachmentTestConstants.attachmentIdOne));
        expect(_store.anchors.length, 1);
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl).length, 1);
        expect(_store.attachmentUsages.length, 1);
        expect(_store.attachments.length, 1);
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockAnchor.id)));
        expect(_store.attachmentUsages,
            anyElement(predicate((AttachmentUsage u) => u.id == AttachmentTestConstants.mockAttachmentUsage.id)));
        expect(_store.attachments,
            anyElement(predicate((Attachment a) => a.id == AttachmentTestConstants.mockAttachment.id)));
      });

      test(
          'calls createAttachmentUsage with valid selection, adds new Anchor, AttachmentUsage and replaces existing Attachment to store',
          () async {
        // Arrange
        final testSelection =
            new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope);
        // make sure isValidSelection is true
        _extensionContext.selectionApi.didChangeSelectionsController.add([testSelection]);
        when(_extensionContext.selectionApi.getCurrentSelections()).thenReturn([testSelection]);
        when(_extensionContext.observedRegionApi.create(selection: testSelection)).thenReturn(
            new cef.ObservedRegion(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope));
        _extensionContext.selectionApi.didChangeSelectionsController.add([testSelection]);
        when(_annotationsApiMock.createAttachmentUsage(producerWurl: any, attachmentId: any)).thenAnswer((_) =>
            new Future.value(new CreateAttachmentUsageResponse(
                anchor: AttachmentTestConstants.mockAnchor,
                attachmentUsage: AttachmentTestConstants.mockAttachmentUsage,
                attachment: AttachmentTestConstants.mockAttachment)));
        _store.attachments = [AttachmentTestConstants.mockAttachment];
        expect(_store.attachments.length, 1);

        // Act
        await _actions.createAttachmentUsage(new CreateAttachmentUsagePayload(
            producerSelection: testSelection, attachmentId: AttachmentTestConstants.attachmentIdOne));

        // Assert
        verify(_annotationsApiMock.createAttachmentUsage(
            producerWurl: AttachmentTestConstants.testWurl, attachmentId: AttachmentTestConstants.attachmentIdOne));
        expect(_store.anchors.length, 1);
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl).length, 1);
        expect(_store.attachmentUsages.length, 1);
        expect(_store.attachments.length, 1);
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockAnchor.id)));
        expect(_store.attachmentUsages,
            anyElement(predicate((AttachmentUsage u) => u.id == AttachmentTestConstants.mockAttachmentUsage.id)));
        expect(_store.attachments,
            anyElement(predicate((Attachment a) => a.id == AttachmentTestConstants.mockAttachment.id)));
      });

      test('does nothing if service call returns null', () async {
        // Arrange
        test_utils.mockServiceMethod(() => _annotationsApiMock.createAttachmentUsage, null);
        final testSelection =
            new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope);
        // make sure isValidSelection is true
        _extensionContext.selectionApi.didChangeSelectionsController.add([testSelection]);

        // Act
        await _actions.createAttachmentUsage(new CreateAttachmentUsagePayload(
            producerSelection:
                new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope)));

        // Assert
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any, attachmentId: any));
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any));
        expect(_store.anchors, isEmpty);
        expect(_store.attachmentUsages, isEmpty);
        expect(_store.attachments, isEmpty);
      });
    });

    group('getAttachmentUsagesById -', () {
      AttachmentsStore _store;
      AnnotationsApiMock _annotationsApiMock;
      AttachmentsActions _actions;
      setUp(() {
        _annotationsApiMock = new AnnotationsApiMock();
        _store = generateDefaultStore(spyMode: true, annotationsApiMock: _annotationsApiMock);
        _actions = _store.attachmentsActions;
      });

      tearDown(() async {
        await _actions.dispose();
        await _store.dispose();
      });

      test('should convert FAttachmentUsage to AttachmentUsage, should add an AttachmentUsage to the list in the store',
          () async {
        List<int> usageIds = [5678];

        Completer getAttachmentUsagesByIdsCompleter =
            test_utils.hookinActionVerifier(_store.attachmentsActions.getAttachmentUsagesByIds);

        when(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: any))
            .thenReturn(AttachmentTestConstants.mockAttachmentUsageList);

        GetAttachmentUsagesByIdsPayload payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

        await _actions.getAttachmentUsagesByIds(payload);

        expect(getAttachmentUsagesByIdsCompleter.future, completes,
            reason: "getAttachmentUsagesByIds did not complete");
        verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);
        expect(_store.attachmentUsages, isNotEmpty);
        expect(
            _store.attachmentUsages,
            anyElement(
                predicate((AttachmentUsage u) => u.id == AttachmentTestConstants.mockChangedAttachmentUsage.id)));
      });

      test('when IDs are null, no changes will be made to the attachmentUsages list in the store', () async {
        List<int> usageIds = [null];
        _store.attachmentUsages = [];

        Completer getAttachmentUsagesByIdsCompleter =
            test_utils.hookinActionVerifier(_store.attachmentsActions.getAttachmentUsagesByIds);

        GetAttachmentUsagesByIdsPayload payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

        await _actions.getAttachmentUsagesByIds(payload);

        expect(getAttachmentUsagesByIdsCompleter.future, completes,
            reason: "getAttachmentUsagesByIds did not complete");
        verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);

        expect(_store.attachmentUsages, isEmpty);
      });

      test('when IDs match a current ID in the list of usages, the usage should be updated.', () async {
        List<int> usageIds = [5678];
        _store.attachmentUsages = [AttachmentTestConstants.mockAttachmentUsage];

        Completer getAttachmentUsagesByIdsCompleter =
            test_utils.hookinActionVerifier(_store.attachmentsActions.getAttachmentUsagesByIds);

        when(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: any))
            .thenReturn(AttachmentTestConstants.mockAttachmentUsageList);

        GetAttachmentUsagesByIdsPayload payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

        expect(
            _store.attachmentUsages,
            anyElement(predicate((AttachmentUsage u) =>
                u.label == AttachmentTestConstants.mockAttachmentUsage.label &&
                u.accountResourceId == AttachmentTestConstants.mockAttachmentUsage.accountResourceId)));

        await _actions.getAttachmentUsagesByIds(payload);

        expect(getAttachmentUsagesByIdsCompleter.future, completes,
            reason: "getAttachmentUsagesByIds did not complete");
        verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);

        expect(
            _store.attachmentUsages,
            anyElement(predicate((AttachmentUsage u) =>
                u.label == AttachmentTestConstants.mockChangedAttachmentUsage.label &&
                u.accountResourceId == AttachmentTestConstants.mockChangedAttachmentUsage.accountResourceId)));
      });

    group('getAttachmentsByProducers -', () {

      GetAttachmentsByProducersResponse getAttachmentsByProducersHappyResponse = new GetAttachmentsByProducersResponse(
          anchors: AttachmentTestConstants.mockAnchorList,
          attachmentUsages: AttachmentTestConstants.mockAttachmentUsageList,
          attachments: AttachmentTestConstants.mockAttachmentList);
      AttachmentsStore _store;
      AnnotationsApiMock _annotationsApiMock;
      AttachmentsActions _actions;

      setUp(() {
        _annotationsApiMock = new AnnotationsApiMock();
        _store = generateDefaultStore(spyMode: true, annotationsApiMock: _annotationsApiMock);
        _store.anchors = [AttachmentTestConstants.mockExistingAnchor, AttachmentTestConstants.mockAnchor];
        _actions = _store.attachmentsActions;
      });

      tearDown(() async {
        await _actions.dispose();
        await _store.dispose();
      });

      test('graceful null return', () async {
        List<String> producerWurls = [AttachmentTestConstants.testWurl];

        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls)).thenReturn(null);

        List<Anchor> _previous = new List<Anchor>.from(_store.anchors);

        await _actions.getAttachmentsByProducers(
            new GetAttachmentsByProducersPayload(producerWurls: producerWurls, maintainAttachments: true));
        expect(_previous, equals(_store.anchors));
      });

      test('calls getAttachmentsByProducers preserving', () async {
        List<String> producerWurls = [AttachmentTestConstants.testWurl];

        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls))
            .thenReturn(getAttachmentsByProducersHappyResponse);

        await _actions.getAttachmentsByProducers(
            new GetAttachmentsByProducersPayload(producerWurls: producerWurls, maintainAttachments: true));
        expect(_store.anchorsByWurl(AttachmentTestConstants.existingWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockExistingAnchor.id)));
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockAnchor.id)));
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockChangedAnchor.id)));
      });

      test('calls getAttachmentsByProducers overriding', () async {
        List<String> producerWurls = [AttachmentTestConstants.testWurl];

        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls))
            .thenReturn(getAttachmentsByProducersHappyResponse);

        await _actions.getAttachmentsByProducers(new GetAttachmentsByProducersPayload(producerWurls: producerWurls));
        expect(_store.anchorsByWurl(AttachmentTestConstants.existingWurl), isEmpty);
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            everyElement(predicate((Anchor a) => a.id != AttachmentTestConstants.mockAnchor.id)));
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockChangedAnchor.id)));
      });
    });

    group('updateAttachmentLabel -', () {
      AttachmentsStore _store;
      AnnotationsApiMock _annotationsApiMock;
      AttachmentsActions _actions;
      setUp(() {
        _annotationsApiMock = new AnnotationsApiMock();
        _store = generateDefaultStore(spyMode: true, annotationsApiMock: _annotationsApiMock);
        _actions = _store.attachmentsActions;
      });

      test('calls to the api to update attachment label', () async {
        when(_annotationsApiMock.updateAttachmentLabel(attachmentId: any, attachmentLabel: any))
            .thenReturn(AttachmentTestConstants.mockAttachment);

        Completer updateAttachmentLabelCompleter =
            test_utils.hookinActionVerifier(_store.attachmentsActions.updateAttachmentLabel);

        UpdateAttachmentLabelPayload payload = new UpdateAttachmentLabelPayload(
            idToUpdate: AttachmentTestConstants.attachmentIdOne, newLabel: AttachmentTestConstants.label);

        await _actions.updateAttachmentLabel(payload);

        verify(_annotationsApiMock.updateAttachmentLabel(attachmentId: any, attachmentLabel: any)).called(1);
        expect(updateAttachmentLabelCompleter.future, completes);
      });
      tearDown(() async {
        await _actions.dispose();
        await _store.dispose();
      });
    });
  });
});
}