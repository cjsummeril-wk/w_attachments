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
import 'package:web_skin_dart/ui_components.dart';

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

AttachmentsStore generateDefaultStore(
    {bool spyMode: false,
    AnnotationsApiMock annotationsApiMock: null,
    ExtensionContextMock extensionContextMock: null,
    AttachmentsConfig config: null}) {
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
      moduleConfig: config);
  if (spyMode) {
    return spy(new AttachmentsStoreMock(), default_store);
  } else {
    return default_store;
  }
}

List<Attachment> defaultAttachments = [
  AttachmentTestConstants.defaultAttachment,
  AttachmentTestConstants.changedAttachment
];

List<DeclarationMirror> getConstructorMirrors(Type classToMirror) {
  // Get a list of the constructors on an object.
  ClassMirror mirror = reflectClass(classToMirror);
  return new List.from(mirror.declarations.values.where((member) {
    return member is MethodMirror && member.isConstructor;
  }));
}

List<String> getStringParameterNames(MethodMirror methodMirror) {
  List<ParameterMirror> parameters = methodMirror.parameters;
  List<String> parameterNames = [];
  for (ParameterMirror parameter in parameters) {
    Symbol symbolName = parameter.simpleName;
    String actualName = MirrorSystem.getName(symbolName);
    parameterNames.add(actualName);
  }
  return parameterNames;
}

const String validWurl = 'wurl://docs.v1/doc:962DD25A85142FBBD7AC5AC84BAE9BD6';
const String testUsername = 'Ron Swanson';
const String veryGoodResourceId = 'very good resource id';
const String configLabel = 'AttachmentPackage';

void main() {
  group('Ensure only one constructor of attachments store.', () {
    test('AttachmentsStore should have 1 constructor', () {
      List<DeclarationMirror> constructors = getConstructorMirrors(AttachmentsStore);
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

      // Act
      MethodMirror constructor = getConstructorMirrors(AttachmentsStore)[0];
      actualParameterNames = getStringParameterNames(constructor);

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
      expect(test_store.groups, equals([]));
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
      List<ContextGroup> testGroup = [new ContextGroup(name: 'some group')];

      // Act
      AttachmentsStore test_store = new AttachmentsStore(
          actionProviderFactory: StandardActionProvider.actionProviderFactory,
          attachmentsActions: _actions,
          attachmentsEvents: _events,
          annotationsApi: _annotationsApiMock,
          extensionContext: _extensionContext,
          dispatchKey: attachmentsModuleDispatchKey,
          attachments: [],
          groups: testGroup,
          moduleConfig: nonDefaultConfig);

      // Assert
      expect(test_store.enableDraggable, isFalse);
      expect(test_store.enableUploadDropzones, isFalse);
      expect(test_store.enableClickToSelect, isFalse);
      expect(test_store.api.primarySelection, isNotNull);
      expect(test_store.api.primarySelection, equals(validWurl));
      expect(test_store.groups, equals(testGroup));
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

    test('Test api setGroups() method actually sets groups.', () async {
      // The default value of groups in the store is already asserted.
      // test that setGroups with an empty list does not error.
      List emptyList = [];
      try {
        await _api.setGroups(groups: emptyList);
      } catch (e) {
        fail('The following error was raised when setting an empty group: $e');
      }
    });

    test('Test that api setGroups() actually sets the groups in the store.', () async {
      List<ContextGroup> expectedGroup = [new ContextGroup(name: 'Zeppelin Groupies')];
      await _api.setGroups(groups: expectedGroup);
      expect(expectedGroup, equals(_store.groups));
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
    List<String> fileNames = ['wut.jpg', 'idgaf.docx', 'ihop.xlsx', 'who.pdf', 'let_the.gif', 'dogs_out.png'];
    AttachmentsStore _store;
    AnnotationsApiMock _annotationsApiMock;
    AttachmentsActions _actions;

    List<Attachment> genAttachmentList(int size) {
      // Generate a default attachments list.
      List<Attachment> attachments = [];
      // A zero ID attachment does not get generated so skip ID 0.
      for (int i = 1; i <= size; i++) {
        String currentFileName = fileNames[(i - 1) % fileNames.length];
        attachments.add(new Attachment()
          ..id = i
          ..filename = currentFileName);
      }
      return attachments;
    }

    List<AttachmentUsage> genUsageList(int size) {
      // Generate a list of AttachmentUsage objects with default parameters.
      List<AttachmentUsage> usages = [];
      for (int i = 1; i <= size * 3; i++) {
        usages.add(new AttachmentUsage()
          // Note that the usage's attachmentId must equal its corresponding attachment.
          ..attachmentId = i
          ..id = i + 1
          ..anchorId = i + 2);
      }
      return usages;
    }

    setUp(() {
      _annotationsApiMock = new AnnotationsApiMock();
      _store = generateDefaultStore(spyMode: true, annotationsApiMock: _annotationsApiMock);
      _actions = _store.attachmentsActions;
    });

    tearDown(() {
      _store.dispose();
      _annotationsApiMock.dispose();
    });

    test('Test genAttachmentList helper method.', () {
      // Arrange, listSize is SAFE TO MODIFY
      int listSize = 7;
      // Dynamically generate expected data in case larger attachment lists are desired.
      List<int> expectedIds = new List<int>.generate(listSize, (i) => i + 1);
      List<String> expectedFileNames = new List<String>.generate(listSize, (i) => fileNames[i % fileNames.length]);

      // Act
      List<Attachment> actualAttachments = genAttachmentList(listSize);
      List<int> actualIds = actualAttachments.map((attachment) => attachment.id).toList();
      List<String> actualFileNames = actualAttachments.map((attachment) => attachment.filename).toList();

      // Assert
      expect(expectedIds, equals(actualIds));
      expect(actualFileNames, equals(expectedFileNames));
    });

    test('Attachments usages that get added to the store are stored.', () async {
      // Arrange
      List<int> testIds = [1, 2, 3];
      List<Attachment> expectedAttachments = genAttachmentList(3);
      _store.attachmentUsages = genUsageList(3);
      when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: testIds)).thenReturn(expectedAttachments);

      // Act
      await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: testIds));

      // Assert
      expect(_store.attachments, unorderedEquals(expectedAttachments));
    });

    // This name does not effectively describe what is happening.
    test('Ids that have no attachment return no attachment.', () async {
      // Arrange
      List<int> testIds = [1, 2, 97];
      List<Attachment> expectedAttachments = genAttachmentList(2);
      _store.attachmentUsages = genUsageList(3);
      when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: testIds)).thenReturn(expectedAttachments);

      // Act
      await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: testIds));

      // Assert
      expect(_store.attachments, unorderedEquals(expectedAttachments));
    });

    test('Store not insert attachments unless a corresponding usage exists.', () async {
      // This test asserts that when there are some attachments, but non are correctly referenced
      // nothing is found.
      // Arrange
      List<int> testIds = [1, 2, 3];
      List<Attachment> expectedAttachments = [];
      // Note the absence of adding attachment usages to the store.
      when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: testIds)).thenReturn(genAttachmentList(3));

      // Act
      await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: testIds));

      // Assert
      expect(_store.attachments, equals(expectedAttachments));
    });

    test('does not perform any action if the payload is empty an empty list.', () async {
      // Arrange
      _store.attachmentUsages = genUsageList(3);
      when(_annotationsApiMock.getAttachmentsByIds).thenReturn(genAttachmentList(3));

      // Act
      await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: []));

      // Assert
      verifyNever(_annotationsApiMock.getAttachmentsByIds);
    });

    test('No action is performed if the payload is null', () async {
      // Arrange
      _store.attachmentUsages = genUsageList(3);
      when(_annotationsApiMock.getAttachmentsByIds).thenReturn(genAttachmentList(3));

      // Act
      await _actions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: null));

      // Assert
      verifyNever(_annotationsApiMock.getAttachmentsByIds);
    });
    // TODO RAM-732 App Intelligence
    // test('store logs when it receives attachments out of scope', () async {
  });

  group('Test Attachments Store actions', () {
    AttachmentsStore _store;
    AttachmentsActions _actions;
    setUp(() {
      _store = generateDefaultStore(spyMode: true);
      _actions = _store.attachmentsActions;
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage];
      _store.attachments = [AttachmentTestConstants.defaultAttachment];
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

      expect(_store.attachments, [AttachmentTestConstants.defaultAttachment, attachment]);
    });

    test('addAttachment should should not add an attachment already in the attachments list', () async {
      Attachment attachment = new Attachment()
        ..filename = 'very_good_file.docx'
        ..id = 1
        ..userName = testUsername;
      await _actions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

      // adding the same attachment again should not modify the list
      await _actions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

      expect(_store.attachments, [AttachmentTestConstants.defaultAttachment, attachment]);
    });

    test('default state of selected/hovered data - assert setup method', () {
      expect(_store.currentlySelectedAnchors, isEmpty);
      expect(_store.currentlySelectedAttachmentUsages, isEmpty);
      expect(_store.currentlySelectedAttachments, isEmpty);
      expect(_store.currentlyHoveredAttachmentId, isNull);
    });

    test('selectAttachment should set the store\'s currentlySelectedAttachments/Anchors with the passed in arg',
        () async {
      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.defaultAttachment.id], maintainSelections: false));

      expect(_store.attachmentIsSelected(AttachmentTestConstants.defaultAttachment.id), isTrue);
      expect(_store.currentlySelectedAnchors, allOf(hasLength(1), contains(AttachmentTestConstants.anchorIdOne)));
    });

    test('selectAttachment sets currentlySelectedAttachment, but not Anchor when usage is not present', () async {
      // simulates an attachment with no usages
      _store.attachmentUsages = [];

      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.defaultAttachment.id], maintainSelections: false));

      expect(_store.attachmentIsSelected(AttachmentTestConstants.defaultAttachment.id), isTrue);
      expect(_store.currentlySelectedAnchors, isEmpty);
    });

    test('should be able to select multiple attachments by IDs in single call', () async {
      // Arrange
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.changedUsage];
      _store.attachments = defaultAttachments;
      List<int> expectedAttachmentIds = [
        AttachmentTestConstants.defaultAttachment.id,
        AttachmentTestConstants.changedAttachment.id
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
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.changedUsage];
      _store.attachments = defaultAttachments;
      List<int> expectedAttachmentIds = [
        AttachmentTestConstants.defaultAttachment.id,
        AttachmentTestConstants.changedAttachment.id
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
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.changedUsage];
      _store.attachments = defaultAttachments;
      // A single item list is needed here for the matchers.
      List<int> expectedAttachmentId = [AttachmentTestConstants.changedAttachment.id];
      List<int> expectedAnchorId = [AttachmentTestConstants.anchorIdTwo];

      // Act
      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.defaultAttachment.id], maintainSelections: false));
      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.changedAttachment.id], maintainSelections: false));

      // Assert
      expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedAttachmentId));
      expect(_store.currentlySelectedAnchors, unorderedEquals(expectedAnchorId));
    });

    test('The attachment store can add a single attached item.', () async {
      // Arrange
      List<int> expectedSelection = [AttachmentTestConstants.defaultAttachment.id];

      // Act
      await _actions
          .selectAttachments(new SelectAttachmentsPayload(attachmentIds: expectedSelection, maintainSelections: true));

      // Assert
      expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedSelection));
    });

    test('deselectAttachments should be able to deselect an attachment by id', () async {
      // Arrange
      List<String> expectedSelection = [];

      // Act
      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.defaultAttachment.id], maintainSelections: true));
      await _actions.deselectAttachments(
          new DeselectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.defaultAttachment.id]));

      // Assert
      expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedSelection));
      expect(_store.currentlySelectedAnchors, isEmpty);
    });

    test('deselectAttachments should be able to deselect an attachment by id', () async {
      // Arrange
      List<String> expectedSelection = [];

      // Act
      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.defaultAttachment.id], maintainSelections: true));
      await _actions.deselectAttachments(
          new DeselectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.defaultAttachment.id]));

      // Assert
      expect(_store.currentlySelectedAttachments, attachmentsAreSelected(_store, expectedSelection));
      expect(_store.currentlySelectedAnchors, isEmpty);
    });
    // This test is duplicated!!!!!!!
    test('should be able to select multiple attachments by ID one at a time maintaining selections', () async {
      _store.attachments = defaultAttachments;

      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.defaultAttachment.id], maintainSelections: false));

      await _actions.selectAttachments(new SelectAttachmentsPayload(
          attachmentIds: [AttachmentTestConstants.changedAttachment.id], maintainSelections: true));
      expect(_store.currentlySelectedAttachments.length, 2);
      expect(_store.attachmentIsSelected(AttachmentTestConstants.defaultAttachment.id), isTrue);
      expect(_store.attachmentIsSelected(AttachmentTestConstants.changedAttachment.id), isTrue);
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
          new SelectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.defaultAttachment.id]));
      await _actions.deselectAttachments(new DeselectAttachmentsPayload(attachmentIds: []));

      expect(_store.currentlySelectedAttachments, isNotEmpty);
      expect(_store.currentlySelectedAnchors, isNotEmpty);
    });

    test('selectAttachmentUsages should set the store\'s currentlySelectedAttachmentUsages with the passed in arg',
        () async {
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.changedUsage];

      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
          usageIds: [AttachmentTestConstants.defaultUsage.id, AttachmentTestConstants.changedUsage.id],
          maintainSelections: false));

      expect(_store.attachmentIsSelected(AttachmentTestConstants.defaultAttachment.id), isFalse);
      expect(_store.usageIsSelected(AttachmentTestConstants.defaultUsage.id), isTrue);
      expect(_store.usageIsSelected(AttachmentTestConstants.changedUsage.id), isTrue);
      expect(_store.currentlySelectedAnchors,
          allOf(contains(AttachmentTestConstants.anchorIdTwo), contains(AttachmentTestConstants.anchorIdOne)));
    });

    test('deselectAttachmentUsages should be able to deselect an attachment usage by id', () async {
      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
          usageIds: [AttachmentTestConstants.defaultUsage.id], maintainSelections: false));

      await _actions.deselectAttachmentUsages(
          new DeselectAttachmentUsagesPayload(usageIds: [AttachmentTestConstants.defaultUsage.id]));

      expect(_store.currentlySelectedAttachments, isEmpty);
      expect(_store.currentlySelectedAnchors, isEmpty);
      expect(_store.usageIsSelected(AttachmentTestConstants.defaultUsage.id), isFalse);
    });

    test("selectAttachmentUsages should only set the store's currentlySelectedAttachmentUsages where specified",
        () async {
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.changedUsage];

      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
          usageIds: [AttachmentTestConstants.changedUsage.id], maintainSelections: false));

      expect(_store.attachmentIsSelected(AttachmentTestConstants.defaultAttachment.id), isFalse);
      expect(_store.usageIsSelected(AttachmentTestConstants.defaultUsage.id), isFalse);
      expect(_store.usageIsSelected(AttachmentTestConstants.changedUsage.id), isTrue);
      expect(_store.currentlySelectedAnchors, contains(AttachmentTestConstants.anchorIdTwo));
    });

    test('should be able to select multiple attachment usages by IDs in single call', () async {
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.changedUsage];

      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
          usageIds: [AttachmentTestConstants.defaultUsage.id, AttachmentTestConstants.changedUsage.id],
          maintainSelections: false));

      expect(_store.currentlySelectedAttachmentUsages.length, 2);
      expect(_store.usageIsSelected(AttachmentTestConstants.defaultUsage.id), isTrue);
      expect(_store.usageIsSelected(AttachmentTestConstants.changedUsage.id), isTrue);
      expect(
          _store.currentlySelectedAnchors,
          allOf(hasLength(2), contains(AttachmentTestConstants.anchorIdOne),
              contains(AttachmentTestConstants.anchorIdTwo)));
    });

    test('should be able to select multiple attachment usages by ID one at a time maintaining selections', () async {
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.changedUsage];

      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
          usageIds: [AttachmentTestConstants.defaultUsage.id], maintainSelections: false));
      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
          usageIds: [AttachmentTestConstants.changedUsage.id], maintainSelections: true));

      expect(_store.currentlySelectedAttachmentUsages.length, 2);
      expect(_store.usageIsSelected(AttachmentTestConstants.defaultUsage.id), isTrue);
      expect(_store.usageIsSelected(AttachmentTestConstants.changedUsage.id), isTrue);
    });

    test('selectAttachmentUsage should make no selections when no IDs are provided', () async {
      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(usageIds: []));

      expect(_store.currentlySelectedAttachmentUsages, isEmpty);
      expect(_store.currentlySelectedAnchors, isEmpty);
    });

    test('deselectAttachmentUsage should remove no selections when no IDs are provided', () async {
      await _actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(
          usageIds: [AttachmentTestConstants.defaultUsage.id], maintainSelections: false));
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

  group('Test Attachments Store configuration.', () {
    AttachmentsStore _store;
    setUp(() {
      _store = generateDefaultStore();
    });

    tearDown(() {
      _store.dispose();
    });

    test('Test config constructor parameters', () {
      // It only tests that parameter names are present.
      // Arrange
      List<String> expectedParameterNames = [
        'emptyViewIcon',
        'emptyViewText',
        'enableClickToSelect',
        'enableDraggable',
        'enableLabelEdit',
        'enableUploadDropzones',
        'label',
        'primarySelection',
        'showFilenameAsLabel',
        'zipSelection',
        'viewModeSetting'
      ];
      List<String> actualParameterNames = [];

      // Act
      MethodMirror constructor = getConstructorMirrors(AttachmentsConfig)[0];
      actualParameterNames = getStringParameterNames(constructor);

      // Assert
      expect(actualParameterNames, unorderedEquals(expectedParameterNames));
    });

    test('Test AttachmentsConfig defaults.', () {
      // Arrange
      AttachmentsConfig testConfig;

      // Act
      testConfig = new AttachmentsConfig();

      // Assert
      expect(testConfig.emptyViewIcon, equals(IconGlyph.FOLDER_ATTACHMENTS_G2));
      expect(testConfig.emptyViewText, equals('No Attachments Found'));
      expect(testConfig.enableClickToSelect, isTrue);
      expect(testConfig.enableDraggable, isTrue);
      expect(testConfig.enableLabelEdit, isTrue);
      expect(testConfig.enableUploadDropzones, isTrue);
      expect(testConfig.label, equals('AttachmentPackage'));
      expect(testConfig.primarySelection, isNull);
      expect(testConfig.showFilenameAsLabel, isFalse);
      expect(testConfig.zipSelection, isNull);
      expect(testConfig.viewModeSetting, equals(ViewModeSettings.Groups));
    });

    test('Verify properties from config are exposed properly.', () {
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

    test('Verify properties are updated when config is updated', () async {
      // Arrange
      AttachmentsConfig defaultConfig = new AttachmentsConfig();
      AttachmentsConfig expectedConfig = new AttachmentsConfig(
          enableClickToSelect: !defaultConfig.enableClickToSelect,
          enableDraggable: !defaultConfig.enableDraggable,
          enableLabelEdit: !defaultConfig.enableLabelEdit,
          enableUploadDropzones: !defaultConfig.enableUploadDropzones,
          label: 'Config 2',
          primarySelection: validWurl,
          showFilenameAsLabel: !defaultConfig.showFilenameAsLabel);

      // Act
      _store = generateDefaultStore(config: defaultConfig);
      await _store.api.updateAttachmentsConfig(expectedConfig);

      // Assert
      expect(_store.enableDraggable, expectedConfig.enableDraggable);
      expect(_store.enableLabelEdit, expectedConfig.enableLabelEdit);
      expect(_store.enableUploadDropzones, expectedConfig.enableUploadDropzones);
      expect(_store.enableClickToSelect, expectedConfig.enableClickToSelect);
      expect(_store.showFilenameAsLabel, expectedConfig.showFilenameAsLabel);
      expect(_store.label, expectedConfig.label);
      expect(_store.primarySelection, expectedConfig.primarySelection);
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
      _store = generateDefaultStore(
          spyMode: true, annotationsApiMock: _annotationsApiMock, extensionContextMock: _extensionContext);
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
              attachmentUsage: AttachmentTestConstants.defaultUsage,
              attachment: AttachmentTestConstants.defaultAttachment)));

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
          anyElement(predicate((AttachmentUsage u) => u.id == AttachmentTestConstants.defaultUsage.id)));
      expect(_store.attachments,
          anyElement(predicate((Attachment a) => a.id == AttachmentTestConstants.defaultAttachment.id)));
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
              attachmentUsage: AttachmentTestConstants.defaultUsage,
              attachment: AttachmentTestConstants.defaultAttachment)));
      _store.attachments = [AttachmentTestConstants.defaultAttachment];
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
          anyElement(predicate((AttachmentUsage u) => u.id == AttachmentTestConstants.defaultUsage.id)));
      expect(_store.attachments,
          anyElement(predicate((Attachment a) => a.id == AttachmentTestConstants.defaultAttachment.id)));
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
    Completer getAttachmentUsagesByIdsCompleter;
    GetAttachmentUsagesByIdsPayload payload;
    setUp(() {
      // The setup for these tests involves creating a completer and payload for the method under test.
      _annotationsApiMock = new AnnotationsApiMock();
      _store = generateDefaultStore(spyMode: true, annotationsApiMock: _annotationsApiMock);
      _actions = _store.attachmentsActions;
      getAttachmentUsagesByIdsCompleter =
          test_utils.hookinActionVerifier(_store.attachmentsActions.getAttachmentUsagesByIds);
    });

    tearDown(() async {
      await _actions.dispose();
      await _store.dispose();
      getAttachmentUsagesByIdsCompleter = null;
      payload = null;
    });

    test('Verify that helper method of GetAttachmentUsagesByIds completes', () async {
      payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: null);
      await _actions.getAttachmentUsagesByIds(payload);
      expect(getAttachmentUsagesByIdsCompleter.future, completes, reason: "getAttachmentUsagesByIds did not complete");
    });

    test('Ensure a default usage is stored when passed.', () async {
      // Arrange
      List<int> usageIds = [5578];
      when(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: any))
          .thenReturn(AttachmentTestConstants.mockAttachmentUsageList);
      List<AttachmentUsage> expectedUsage = [AttachmentTestConstants.defaultUsage];
  
      // Act
      _store.attachmentUsages = [AttachmentTestConstants.defaultUsage];
      payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

      // Assert
      expect(_store.attachmentUsages, equals(expectedUsage));
    });

    test('should convert FAttachmentUsage to AttachmentUsage, should add an AttachmentUsage to the list in the store',
        () async {
      // Arrange
      List<int> usageIds = [5678];
      when(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: any))
          .thenReturn(AttachmentTestConstants.mockAttachmentUsageList);
      payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

      // Act
      await _actions.getAttachmentUsagesByIds(payload);

      // Assert
      verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);
      expect(_store.attachmentUsages, isNotEmpty);
      expect(_store.attachmentUsages,
          anyElement(predicate((AttachmentUsage u) => u.id == AttachmentTestConstants.changedUsage.id)));
    });

    test('when IDs are null, no changes will be made to the attachmentUsages list in the store', () async {
      // Arrange
      List<int> usageIds = [null];
      payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

      // Act
      _store.attachmentUsages = [];
      await _actions.getAttachmentUsagesByIds(payload);

      // Assert
      verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);
      expect(_store.attachmentUsages, isEmpty);
    });

    test('when IDs match a current ID in the list of usages, the usage should be updated.', () async {
      // Arrange
      List<int> usageIds = [5678];
      when(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: any))
          .thenReturn(AttachmentTestConstants.mockAttachmentUsageList);
      List<AttachmentUsage> testUsage = [AttachmentTestConstants.defaultUsage];
      AttachmentUsage expectedUsage = AttachmentTestConstants.changedUsage;

      // Act
      _store.attachmentUsages = testUsage;
      payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);
      await _actions.getAttachmentUsagesByIds(payload);

      // Assert
      verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);
      expect( _store.attachmentUsages, contains(expectedUsage));
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
        // Arrange
        List<String> producerWurls = [AttachmentTestConstants.testWurl];
        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls)).thenReturn(null);

        // Act
        List<Anchor> _previous = new List<Anchor>.from(_store.anchors);
        await _actions.getAttachmentsByProducers(
            new GetAttachmentsByProducersPayload(producerWurls: producerWurls, maintainAttachments: true));

        // Assert
        expect(_previous, equals(_store.anchors));
      });

      test('calls getAttachmentsByProducers preserving', () async {
        // Arrange
        List<String> producerWurls = [AttachmentTestConstants.testWurl];
        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls))
            .thenReturn(getAttachmentsByProducersHappyResponse);

        // Act
        await _actions.getAttachmentsByProducers(
            new GetAttachmentsByProducersPayload(producerWurls: producerWurls, maintainAttachments: true));

        // Assert
        expect(_store.anchorsByWurl(AttachmentTestConstants.existingWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockExistingAnchor.id)));
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockAnchor.id)));
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockChangedAnchor.id)));
      });

      test('calls getAttachmentsByProducers overriding', () async {
        // Arrange
        List<String> producerWurls = [AttachmentTestConstants.testWurl];

        // Act
        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls))
            .thenReturn(getAttachmentsByProducersHappyResponse);
        await _actions.getAttachmentsByProducers(new GetAttachmentsByProducersPayload(producerWurls: producerWurls));

        // Assert
        expect(_store.anchorsByWurl(AttachmentTestConstants.existingWurl), isEmpty);
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            everyElement(predicate((Anchor a) => a.id != AttachmentTestConstants.mockAnchor.id)));
        expect(_store.anchorsByWurl(AttachmentTestConstants.testWurl),
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockChangedAnchor.id)));
      });

      test('calls to the api to update attachment label', () async {
        // Arrange
        when(_annotationsApiMock.updateAttachmentLabel(attachmentId: any, attachmentLabel: any))
            .thenReturn(AttachmentTestConstants.defaultAttachment);

        // Act
        Completer updateAttachmentLabelCompleter =
            test_utils.hookinActionVerifier(_store.attachmentsActions.updateAttachmentLabel);
        UpdateAttachmentLabelPayload payload = new UpdateAttachmentLabelPayload(
            idToUpdate: AttachmentTestConstants.attachmentIdOne, newLabel: AttachmentTestConstants.label);
        await _actions.updateAttachmentLabel(payload);

        // Asssert
        verify(_annotationsApiMock.updateAttachmentLabel(attachmentId: any, attachmentLabel: any)).called(1);
        expect(updateAttachmentLabelCompleter.future, completes);
      });
    });
  });
}
