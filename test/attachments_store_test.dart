library w_attachments_client.test.attachments_store_test;

import 'dart:async';

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';

import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_payloads.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/action_payloads.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/w_attachments_client.dart';

import './mocks/mocks_library.dart';
import 'attachment_test_constants.dart';
import 'test_utils.dart' as test_utils;

void main() {
  group('AttachmentsStore', () {
    // Mocks
    AnnotationsApiMock _annotationsApiMock;

    // Subject
    AttachmentsStore _store;

    // Other
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    AttachmentsApi _api;
    ExtensionContextMock _extensionContext;

    String validWurl = 'wurl://docs.v1/doc:962DD25A85142FBBD7AC5AC84BAE9BD6';
    String testUsername = 'Ron Swanson';
    String veryGoodResourceId = 'very good resource id';
    String veryGoodSectionId = 'very good section id';

    group('constructor', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _annotationsApiMock = new AnnotationsApiMock();
      });

      tearDown(() {
        _extensionContext.dispose();
        _store.dispose();
      });

      test('should have proper default values', () {
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                annotationsApi: _annotationsApiMock,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: [],
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage')));
        _api = _store.api;
      });

      test('should have default true enableDraggable, and can be set to false', () {
        expect(_store.enableDraggable, isTrue);
        expect(_store.enableUploadDropzones, isTrue);
        expect(_store.enableClickToSelect, isTrue);
        expect(_api.primarySelection, isNull);
        expect(_store.actionProvider, isNotNull);
      });

      test('should have enableDraggableset to false when specified', () {
        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: [],
            moduleConfig: new AttachmentsConfig(enableDraggable: false, label: 'AttachmentPackage'));

        expect(_store.enableDraggable, isFalse);
      });

      test('should have enableUploadDropzones set to false when specified', () {
        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: new AttachmentsConfig(enableUploadDropzones: false, label: 'AttachmentPackage'),
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

        expect(_store.enableUploadDropzones, isFalse);
      });

      test('should have enableClickToSelect set to false when specified', () {
        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: new AttachmentsConfig(enableClickToSelect: false, label: 'AttachmentPackage'),
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

        expect(_store.enableClickToSelect, isFalse);
      });

      test('should set a primarySelection when it is provided', () {
        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: [],
            moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage', primarySelection: validWurl));
        _api = _store.api;

        expect(_api.primarySelection, isNotNull);
        expect(_api.primarySelection, validWurl);
      });

      test('should have a non-null StandardActionProvider when an actionProvider is not specified', () {
        _store = new AttachmentsStore(
            actionProviderFactory: null,
            moduleConfig: new AttachmentsConfig(enableDraggable: false, label: 'AttachmentPackage'),
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

        expect(_store.actionProvider, isNotNull);
      });
    });

    group('setGroups', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _annotationsApiMock = new AnnotationsApiMock();
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                annotationsApi: _annotationsApiMock,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: []));
        _api = _store.api;
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
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));
        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments, isNotEmpty);
        expect(_api.groups[0].attachments.any((attach) => attach == attachment), isTrue);
      });
    });

//    group('_generateTreeNodes', () {
//      setUp(() {
//        _attachmentsActions = new AttachmentsActions();
//        _attachmentsEvents = new AttachmentsEvents();
//        _extensionContext = new ExtensionContextMock();
//        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsService(messagingClient: natsMsgClientMock, fClient: annoServiceClientMock));
//        _store = spy(
//            new AttachmentsStoreMock(),
//            new AttachmentsStore(
//                actionProviderFactory: StandardActionProvider.actionProviderFactory,
//                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
//                attachmentsActions: _attachmentsActions,
//                attachmentsEvents: _attachmentsEvents,
//                attachmentsService: _attachmentsService,
//                extensionContext: _extensionContext,
//                dispatchKey: attachmentsModuleDispatchKey,
//                attachments: [],
//                groups: []));
//        _api = _store.api;
//        mockWindow = spy(new WindowMock(), window);
//        _attachmentsService.serviceWindow = mockWindow;
//      });
//
//      tearDown(() {
//        _attachmentsService.dispose();
//      });
//
//      test('should generate nested tree nodes when given a nested directory structure', () async {
//        Attachment toAdd = new Attachment()
//          ..id = 1
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));
//
//        ContextGroup veryGoodGroup = new ContextGroup(
//            name: 'veryGoodGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, ContextGroup);
//        expect(rootChildren[0].children.length, 1);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//        expect(rootGreatGrandchildren[0].content.id, 1);
//      });
//
//      test('should generate nested tree nodes, context as parent to context and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        ContextGroup veryGoodGroup = new ContextGroup(
//            name: 'veryGoodGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup parentGroup = new ContextGroup(
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup],
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodSectionId, selection: validWurl)]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, ContextGroup);
//        expect(rootChildren[0].children.length, 2);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[1].content.id, 1);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to context and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        ContextGroup veryGoodGroup = new ContextGroup(
//            name: 'veryGoodGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        PredicateGroup parentGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => true), name: 'parentGroup', childGroups: [veryGoodGroup]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, PredicateGroup);
//        expect(rootChildren[0].children.length, 2);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[1].content.id, 1);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to predicate and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        PredicateGroup veryGoodGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.id == 2), name: 'veryGoodGroup');
//
//        PredicateGroup parentGroup = new PredicateGroup(
//            name: 'parentGroup', childGroups: [veryGoodGroup], predicate: ((Attachment attachment) => true));
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, PredicateGroup);
//        expect(rootChildren[0].children.length, 2);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[1].content.id, 1);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to predicate and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        PredicateGroup veryGoodGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
//            name: 'veryGoodGroup');
//
//        ContextGroup parentGroup = new ContextGroup(
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup],
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodSectionId, selection: validWurl)]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, ContextGroup);
//        expect(rootChildren[0].children.length, 2);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[1].content.id, 1);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to predicate, context and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        PredicateGroup veryGoodGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
//            name: 'veryGoodGroup');
//
//        ContextGroup secondGroup = new ContextGroup(
//            name: 'secondGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup parentGroup = new ContextGroup(
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup, secondGroup],
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodSectionId, selection: validWurl)]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, ContextGroup);
//        expect(rootChildren[0].children.length, 3);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[1].content.name, 'secondGroup');
//        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[2].content.id, 1);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to predicate, predicate and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        PredicateGroup veryGoodGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
//            name: 'veryGoodGroup');
//
//        PredicateGroup secondGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'), name: 'secondGroup');
//
//        ContextGroup parentGroup = new ContextGroup(
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup, secondGroup],
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodSectionId, selection: validWurl)]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, ContextGroup);
//        expect(rootChildren[0].children.length, 3);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[1].content.name, 'secondGroup');
//        expect(rootGrandchildren[1].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[2].content.id, 1);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to context, context and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        ContextGroup veryGoodGroup = new ContextGroup(
//            name: 'veryGoodGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup secondGroup = new ContextGroup(
//            name: 'secondGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup parentGroup = new ContextGroup(
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup, secondGroup],
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodSectionId, selection: validWurl)]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, ContextGroup);
//        expect(rootChildren[0].children.length, 3);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[1].content.name, 'secondGroup');
//        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[2].content.id, 1);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to predicate, predicate and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        PredicateGroup veryGoodGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
//            name: 'veryGoodGroup');
//
//        PredicateGroup secondGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'), name: 'secondGroup');
//
//        PredicateGroup parentGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.userName == testUsername),
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup, secondGroup]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, PredicateGroup);
//        expect(rootChildren[0].children.length, 3);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[1].content.name, 'secondGroup');
//        expect(rootGrandchildren[1].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[2].content.id, 1);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to predicate, context and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        PredicateGroup veryGoodGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
//            name: 'veryGoodGroup');
//
//        ContextGroup secondGroup = new ContextGroup(
//            name: 'secondGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.RESOURCE, id: veryGoodResourceId, selection: validWurl)]);
//
//        PredicateGroup parentGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.userName == testUsername),
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup, secondGroup]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, PredicateGroup);
//        expect(rootChildren[0].children.length, 3);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
//        expect(rootGrandchildren[1].content.name, 'secondGroup');
//        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[2].content.id, 1);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to context, context and attachment', () async {
//        Attachment firstAttachment = new Attachment()
//          ..id = 1
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        Attachment secondAttachment = new Attachment()
//          ..id = 2
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        ContextGroup veryGoodGroup = new ContextGroup(
//            name: 'veryGoodGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup secondGroup = new ContextGroup(
//            name: 'secondGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        PredicateGroup parentGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.userName == testUsername),
//            name: 'parentGroup',
//            childGroups: [veryGoodGroup, secondGroup]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.rootNode.children.length, 1);
//
//        List rootChildren = _store.rootNode.children.toList();
//        expect(rootChildren[0].content.name, 'parentGroup');
//        expect(rootChildren[0].content.runtimeType, PredicateGroup);
//        expect(rootChildren[0].children.length, 3);
//
//        List rootGrandchildren = rootChildren[0].children.toList();
//        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
//        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[1].content.name, 'secondGroup');
//        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
//        expect(rootGrandchildren[2].content.id, 1);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, 2);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//    });

    group('loadAttachments', () {
      List<Attachment> happyPathAttachments;
      List<AttachmentUsage> happyPathUsages;
      List<Anchor> happyPathAnchors;

      setUp(() {
        // Mocks
        _annotationsApiMock = new AnnotationsApiMock();

        // Client
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();

        // Subject
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                annotationsApi: _annotationsApiMock,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: []));

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
        // Attachments that have no correlating usage (in happy path)
        List<Attachment> noMatchAttachments;

        // Attachments that have some correlating usage (in happy path)
        List<Attachment> twoMatchAttachments;

        setUp(() {
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

        test('(happy path)', () async {
          // Arrange
          List<int> getIds = [1, 2, 3];
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: getIds)).thenReturn(happyPathAttachments);

          // Act
          await _attachmentsActions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: getIds));

          // Assert
          expect(_store.attachments.length, equals(3));
        });

        test('overwrites the results that match correlating usage referencing attachment id', () async {
          // Arrange
          List<int> getIds = [1, 2, 97];
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: getIds)).thenReturn(twoMatchAttachments);

          // Act
          await _attachmentsActions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: getIds));

          // Assert
          expect(_store.attachments.length, equals(2));
        });

        test('does not insert attachments without correlating usage referencing attachment id', () async {
          // Arrange
          List<int> getIds = [97, 98, 99];
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds(idsToLoad: getIds)).thenReturn(noMatchAttachments);

          // Act
          await _attachmentsActions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: getIds));

          // Assert
          expect(_store.attachments.length, equals(0));
        });

        test('does not perform any action if the payload is empty or null', () async {
          // Arrange
          _store.attachmentUsages = happyPathUsages;
          when(_annotationsApiMock.getAttachmentsByIds).thenReturn(happyPathAttachments);

          // Act (1/2)
          await _attachmentsActions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: null));
          // Assert (1/2)
          verifyNever(_annotationsApiMock.getAttachmentsByIds);

          // Act (2/2)
          await _attachmentsActions.getAttachmentsByIds(new GetAttachmentsByIdsPayload(attachmentIds: []));
          // Assert (2/2)
          verifyNever(_annotationsApiMock.getAttachmentsByIds);
        });

        // TODO RAM-732 App Intelligence
//        test('store logs when it receives attachments out of scope', () async {
//
//        });
      });
    });

    group('AttachmentsStore attachment actions', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _annotationsApiMock = new AnnotationsApiMock();
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                annotationsApi: _annotationsApiMock,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: []));
        _api = _store.api;
      });

      tearDown(() async {
        // eliminate all attachments in the store cache, cancelUpload handles all cases that loadAttachments doesn't
        _attachmentsActions.dispose();
        _attachmentsEvents.dispose();
        _extensionContext.dispose();
        _store.dispose();
        _api = null;
      });

      test('addAttachment should add an attachment to the stored list of attachments', () async {
        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_store.attachments, [attachment]);

        // adding the same attachment again should not modify the list
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_store.attachments, [attachment]);
      });

      test('updateAttachment should modify an existent attachment in the list', () async {
        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        attachment.userName = 'Harvey Birdman';

        await _attachmentsActions.updateAttachment(new UpdateAttachmentPayload(toUpdate: attachment));

        expect(_store.attachments, [attachment]);
        expect(_store.attachments[0].userName, 'Harvey Birdman');
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

      test('selectAttachment should set the store\'s currentlySelected with the passed in arg', () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _attachmentsActions
            .selectAttachments(new SelectAttachmentsPayload(attachmentIds: [attachment.id], maintainSelections: false));
        await completer.future;

        expect(selectEventResult.selectedAttachmentId, attachment.id);
        expect(_api.currentlySelectedAttachments, contains(attachment.id));
      });

      test('should be able to select a bundle by selectionKey through api', () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(attachmentIds: [attachment.id], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentId, attachment.id);
        expect(_api.currentlySelectedAttachments, contains(attachment.id));
      });

      test('should be able to select multiple attachments by selectionKeys through api in single call', () async {
        Attachment attachment1 = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Attachment attachment2 = new Attachment()
          ..filename = 'very_good_file.pptx'
          ..id = 2
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(attachmentIds: [attachment1.id, attachment2.id], maintainSelections: false);

        expect(_api.currentlySelectedAttachments.length, 2);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id));
        expect(_api.currentlySelectedAttachments, contains(attachment2.id));
      });

      test(
          'should be able to select multiple attachments by selectionKey through api one at a time maintaining selections',
          () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Attachment attachment1 = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Attachment attachment2 = new Attachment()
          ..filename = 'very_good_file.pptx'
          ..id = 2
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(attachmentIds: [attachment1.id], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentId, attachment1.id);
        expect(_api.currentlySelectedAttachments, isNotEmpty);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id));

        completer = new Completer();
        await _api.selectAttachmentsByIds(attachmentIds: [attachment2.id], maintainSelections: true);
        await completer.future;

        expect(selectEventResult.selectedAttachmentId, attachment2.id);
        expect(_api.currentlySelectedAttachments.length, 2);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id));
        expect(_api.currentlySelectedAttachments, contains(attachment2.id));
      });

      test('should be able to select an attachment by selectionKey through api and clear the list', () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Attachment attachment1 = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Attachment attachment2 = new Attachment()
          ..filename = 'very_good_file.pptx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(attachmentIds: [attachment1.id], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentId, attachment1.id);
        expect(_api.currentlySelectedAttachments, isNotEmpty);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id));

        completer = new Completer();
        await _api.selectAttachmentsByIds(attachmentIds: [attachment2.id], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentId, attachment2.id);
        expect(_api.currentlySelectedAttachments.length, 1);
        expect(_api.currentlySelectedAttachments, contains(attachment2.id));
      });

      test('should be able to deselect an attachment by id through api', () async {
        Completer eventCompleter = new Completer();
        AttachmentDeselectedEventPayload deselectEventResult;
        _attachmentsEvents.attachmentDeselected.listen((selectEvent) {
          deselectEventResult = selectEvent;
          eventCompleter.complete();
        });

        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _attachmentsActions
            .selectAttachments(new SelectAttachmentsPayload(attachmentIds: [attachment.id], maintainSelections: false));
        expect(_api.currentlySelectedAttachments, contains(attachment.id));

        await _api.deselectAttachmentsByIds(attachmentIds: [attachment.id]);
        await eventCompleter.future;

        expect(deselectEventResult.deselectedAttachmentId, attachment.id);
        expect(_api.currentlySelectedAttachments, isEmpty);
      });

      test('hoverOverAttachmentNodes should set a specified AttachmentTreeNode as hovered', () async {
        Attachment toAdd = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = testUsername;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.hoveredNode, isNull);

        AttachmentTreeNode hovered = _store.treeNodes[toAdd.id].first;
        await _attachmentsActions.hoverOverAttachmentNode(new HoverOverNodePayload(hovered: hovered));
        expect(_store.hoveredNode, allOf(isNotNull, new isInstanceOf<AttachmentTreeNode>(), hovered));
        expect(_store.hoveredNode.key, toAdd.id);
      });

//      test('hoverOverAttachmentNodes should set a specified GroupTreeNode as hovered', () async {
//        String someKey = 1;
//        Attachment toAdd = new Attachment()
//          ..filename = 'very_good_file.docx'
//          ..id = someKey
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));
//
//        ContextGroup veryGoodGroup = new ContextGroup(
//            name: 'veryGoodGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.RESOURCE, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        expect(_store.hoveredNode, isNull);
//
//        GroupTreeNode hovered = _store.treeNodes[veryGoodGroup.key].first;
//        await _attachmentsActions.hoverOverAttachmentNode(new HoverOverNodePayload(hovered: hovered));
//        expect(_store.hoveredNode, allOf(isNotNull, new isInstanceOf<GroupTreeNode>(), hovered));
//        expect(_store.hoveredNode.key, veryGoodGroup.key);
//      });

//      test('hoverOutAttachmentNodes should set a specified AttachmentsTreeNode as not hovered', () async {
//        String someKey = 1;
//        Attachment toAdd = new Attachment()
//          ..filename = 'very_good_file.docx'
//          ..id = someKey
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));
//
//        ContextGroup veryGoodGroup = new ContextGroup(
//            name: 'veryGoodGroup',
//            pivots: [new GroupPivot(type: GroupPivotType.ALL, id: veryGoodResourceId, selection: validWurl)]);
//
//        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
//        await _api.setGroups(groups: [parentGroup]);
//
//        GroupTreeNode hovered = _store.treeNodes[veryGoodGroup.key].first;
//        await _attachmentsActions.hoverOverAttachmentNode(new HoverOverNodePayload(hovered: hovered));
//        expect(_store.hoveredNode, allOf(isNotNull, new isInstanceOf<GroupTreeNode>(), hovered));
//        expect(_store.hoveredNode.key, veryGoodGroup.key);
//
//        await _attachmentsActions.hoverOutAttachmentNode(new HoverOutNodePayload(unhovered: hovered));
//        expect(_store.hoveredNode, isNull);
//      });
    });

    group('config', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _annotationsApiMock = new AnnotationsApiMock();
      });

      test('properties from config are exposed properly', () {
        AttachmentsConfig config = new AttachmentsConfig(
            enableClickToSelect: true,
            enableDraggable: true,
            enableLabelEdit: true,
            enableUploadDropzones: true,
            label: 'Config Label',
            primarySelection: validWurl,
            showFilenameAsLabel: true);

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: config,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

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

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: config,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            annotationsApi: _annotationsApiMock,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

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
      setUp(() {
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
                attachments: [],
                groups: [],
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage')));
        _api = _store.api;
      });

      tearDown(() async {
        await _extensionContext.dispose();
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
      setUp(() {
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
                attachments: [],
                groups: [],
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage')));
        _api = _store.api;
      });

      tearDown(() async {
        await _attachmentsActions.dispose();
        await _attachmentsEvents.dispose();
        await _extensionContext.dispose();
        await _store.dispose();
        _api = null;
      });

      test('does nothing if isValidSelection is false', () async {
        // Arrange
        CreateAttachmentUsagePayload payload = new CreateAttachmentUsagePayload(
            producerSelection:
                new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope));

        // Act
        await _attachmentsActions.createAttachmentUsage(payload);

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
        await _attachmentsActions.createAttachmentUsage(payload);

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
        when(_annotationsApiMock.createAttachmentUsage(producerWurl: any)).thenAnswer((_) => new Future.value(
            new CreateAttachmentUsageResponse(
                anchor: AttachmentTestConstants.mockAnchor,
                attachmentUsage: AttachmentTestConstants.mockAttachmentUsage,
                attachment: AttachmentTestConstants.mockAttachment)));

        // Act
        await _attachmentsActions
            .createAttachmentUsage(new CreateAttachmentUsagePayload(producerSelection: testSelection));

        // Assert
        verify(_annotationsApiMock.createAttachmentUsage(producerWurl: AttachmentTestConstants.testWurl));
        expect(_store.anchorsByWurls.keys.length, 1);
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
        when(_annotationsApiMock.createAttachmentUsage(producerWurl: any)).thenAnswer((_) => new Future.value(
            new CreateAttachmentUsageResponse(
                anchor: AttachmentTestConstants.mockAnchor,
                attachmentUsage: AttachmentTestConstants.mockAttachmentUsage,
                attachment: AttachmentTestConstants.mockAttachment)));
        _store.attachments = [AttachmentTestConstants.mockAttachment];
        expect(_store.attachments.length, 1);

        // Act
        await _attachmentsActions
            .createAttachmentUsage(new CreateAttachmentUsagePayload(producerSelection: testSelection));

        // Assert
        verify(_annotationsApiMock.createAttachmentUsage(producerWurl: AttachmentTestConstants.testWurl));
        expect(_store.anchorsByWurls.keys.length, 1);
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
        await _attachmentsActions.createAttachmentUsage(new CreateAttachmentUsagePayload(
            producerSelection:
                new cef.Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope)));

        // Assert
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any, attachmentId: any));
        verifyNever(_annotationsApiMock.createAttachmentUsage(producerWurl: any));
        expect(_store.anchorsByWurls, isEmpty);
        expect(_store.attachmentUsages, isEmpty);
        expect(_store.attachments, isEmpty);
      });
    });

    group('getAttachmentUsageById -', () {
      setUp(() {
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
                attachments: [],
                groups: [],
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage')));
        _api = _store.api;
      });

      tearDown(() async {
        await _attachmentsActions.dispose();
        await _attachmentsEvents.dispose();
        await _extensionContext.dispose();
        await _store.dispose();
        _api = null;
      });

      test(
          '_getAttachmentUsagesById should convert FAttachmentUsage to AttachmentUsage, should add an AttachmentUsage to the list in the store',
          () async {
        List<int> usageIds = [5678];

        Completer getAttachmentUsagesByIdsCompleter =
            test_utils.hookinActionVerifier(_store.attachmentsActions.getAttachmentUsagesByIds);

        when(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: any))
            .thenReturn(AttachmentTestConstants.mockAttachmentUsageList);

        GetAttachmentUsagesByIdsPayload payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

        await _attachmentsActions.getAttachmentUsagesByIds(payload);

        expect(getAttachmentUsagesByIdsCompleter.future, completes,
            reason: "getAttachmentUsagesByIds did not complete");
        verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);
        expect(_store.attachmentUsages, isNotEmpty);
        expect(
            _store.attachmentUsages,
            anyElement(
                predicate((AttachmentUsage u) => u.id == AttachmentTestConstants.mockChangedAttachmentUsage.id)));
      });

      test(
          '_getAttachmentsUsageByIds when IDs are null, no changes will be made to the attachmentUsages list in the store',
          () async {
        List<int> usageIds = [null];
        _store.attachmentUsages = [];

        Completer getAttachmentUsagesByIdsCompleter =
            test_utils.hookinActionVerifier(_store.attachmentsActions.getAttachmentUsagesByIds);

        GetAttachmentUsagesByIdsPayload payload = new GetAttachmentUsagesByIdsPayload(attachmentUsageIds: usageIds);

        await _attachmentsActions.getAttachmentUsagesByIds(payload);

        expect(getAttachmentUsagesByIdsCompleter.future, completes,
            reason: "getAttachmentUsagesByIds did not complete");
        verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);

        expect(_store.attachmentUsages, isEmpty);
      });

      test('_getAttachmentsUsageByIds when IDs match a current ID in the list of usages, the usage should be updated.',
          () async {
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

        await _attachmentsActions.getAttachmentUsagesByIds(payload);

        expect(getAttachmentUsagesByIdsCompleter.future, completes,
            reason: "getAttachmentUsagesByIds did not complete");
        verify(_annotationsApiMock.getAttachmentUsagesByIds(usageIdsToLoad: usageIds)).called(1);

        expect(
            _store.attachmentUsages,
            anyElement(predicate((AttachmentUsage u) =>
                u.label == AttachmentTestConstants.mockChangedAttachmentUsage.label &&
                u.accountResourceId == AttachmentTestConstants.mockChangedAttachmentUsage.accountResourceId)));
      });
    });

    group('getAttachmentsByProducers-', () {
      GetAttachmentsByProducersResponse getAttachmentsByProducersHappyResponse = new GetAttachmentsByProducersResponse(
          anchors: AttachmentTestConstants.mockAnchorList,
          attachmentUsages: AttachmentTestConstants.mockAttachmentUsageList,
          attachments: AttachmentTestConstants.mockAttachmentList);

      setUp(() {
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
                attachments: [],
                groups: [],
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage')));
        _api = _store.api;

        _store.anchorsByWurls = {
          AttachmentTestConstants.existingWurl: [AttachmentTestConstants.mockAnchor],
          AttachmentTestConstants.testWurl: [AttachmentTestConstants.mockAnchor]
        };
      });

      tearDown(() async {
        await _attachmentsActions.dispose();
        await _attachmentsEvents.dispose();
        await _extensionContext.dispose();
        await _store.dispose();
        _api = null;
      });

      test('gracefull null return', () async {
        List<String> producerWurls = [AttachmentTestConstants.testWurl];

        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls)).thenReturn(null);

        Map<String, List<Anchor>> _previous = new Map<String, List<Anchor>>.from(_store.anchorsByWurls);

        await _attachmentsActions.getAttachmentsByProducers(
            new GetAttachmentsByProducersPayload(producerWurls: producerWurls, maintainAttachments: true));
        expect(_previous, equals(_store.anchorsByWurls));
      });

      test('calls getAttachmentsByProducers preserving', () async {
        List<String> producerWurls = [AttachmentTestConstants.testWurl];

        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls))
            .thenReturn(getAttachmentsByProducersHappyResponse);

        await _attachmentsActions.getAttachmentsByProducers(
            new GetAttachmentsByProducersPayload(producerWurls: producerWurls, maintainAttachments: true));
        expect(_store.anchorsByWurls[AttachmentTestConstants.existingWurl],
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockAnchor.id)));
        expect(_store.anchorsByWurls[AttachmentTestConstants.testWurl],
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockAnchor.id)));
        expect(_store.anchorsByWurls[AttachmentTestConstants.testWurl],
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockChangedAnchor.id)));
      });

      test('calls getAttachmentsByProducers overriding', () async {
        List<String> producerWurls = [AttachmentTestConstants.testWurl];

        when(_annotationsApiMock.getAttachmentsByProducers(producerWurls: producerWurls))
            .thenReturn(getAttachmentsByProducersHappyResponse);

        await _attachmentsActions
            .getAttachmentsByProducers(new GetAttachmentsByProducersPayload(producerWurls: producerWurls));
        expect(_store.anchorsByWurls[AttachmentTestConstants.existingWurl], isNull);
        expect(_store.anchorsByWurls[AttachmentTestConstants.testWurl],
            everyElement(predicate((Anchor a) => a.id != AttachmentTestConstants.mockAnchor.id)));
        expect(_store.anchorsByWurls[AttachmentTestConstants.testWurl],
            anyElement(predicate((Anchor a) => a.id == AttachmentTestConstants.mockChangedAnchor.id)));
      });
    });
  });
}
