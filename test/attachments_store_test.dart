library w_attachments_client.test.attachments_store_test;

import 'dart:async';
import 'dart:html' hide Client, Selection;

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/action_payloads.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

import './mocks.dart';

void main() {
  group('AttachmentsStore', () {
    AttachmentsStore _store;
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    AttachmentsApi _api;
    cef.ExtensionContext _extensionContext;
    AttachmentsService _attachmentsService;
    Window mockWindow;

    String validWurl = 'wurl://docs.v1/doc:962DD25A85142FBBD7AC5AC84BAE9BD6';
    String testUsername = 'Ron Swanson';
    String veryGoodResourceId = 'very good resource id';
    String veryGoodSectionId = 'very good section id';

    group('constructor', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                attachmentsService: _attachmentsService,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: [],
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage')));
        _api = _store.api;
        mockWindow = spy(new WindowMock(), window);
        _attachmentsService.serviceWindow = mockWindow;
      });

      tearDown(() {
        _attachmentsService.dispose();
      });

      test('should have default true enableDraggable, and can be set to false', () {
        expect(_store.enableDraggable, isTrue);

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: [],
            moduleConfig: new AttachmentsConfig(enableDraggable: false, label: 'AttachmentPackage'));

        expect(_store.enableDraggable, isFalse);
      });

      test('should have default true enableUploadDropzones, and can be set to false', () {
        expect(_store.enableUploadDropzones, isTrue);

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: new AttachmentsConfig(enableUploadDropzones: false, label: 'AttachmentPackage'),
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

        expect(_store.enableUploadDropzones, isFalse);
      });

      test('should have default true enableClickToSelect, and can be set to false', () {
        expect(_store.enableClickToSelect, isTrue);

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: new AttachmentsConfig(enableClickToSelect: false, label: 'AttachmentPackage'),
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

        expect(_store.enableClickToSelect, isFalse);
      });

      test('should set a primarySelection when it is provided', () {
        expect(_api.primarySelection, isNull);

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: [],
            moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage', primarySelection: validWurl));
        _api = _store.api;

        expect(_api.primarySelection, isNotNull);
        expect(_api.primarySelection, validWurl);
      });

      test('should have default StandardActionProvider when an actionProvider is not specified', () {
        expect(_store.actionProvider, isNotNull);

        _store = new AttachmentsStore(
            actionProviderFactory: null,
            moduleConfig: new AttachmentsConfig(enableDraggable: false, label: 'AttachmentPackage'),
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
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
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                attachmentsService: _attachmentsService,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: []));
        _api = _store.api;
        mockWindow = spy(new WindowMock(), window);
        _attachmentsService.serviceWindow = mockWindow;
      });

      tearDown(() {
        _attachmentsService.dispose();
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
          ..id = new Uuid().v4()
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
//        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
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
//        String someKey = new Uuid().v4();
//        Attachment toAdd = new Attachment()
//          ..id = new Uuid().v4()
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
//        expect(rootGreatGrandchildren[0].content.id, someKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, someKey);
//      });
//
//      test('should generate nested tree nodes, context as parent to context and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[1].content.id, firstKey);
//        expect(rootGrandchildren[1].content.selection.id, firstKey);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to context and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[1].content.id, firstKey);
//        expect(rootGrandchildren[1].content.selection.id, firstKey);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to predicate and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
//          ..filename = 'very_good_file.docx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondAttachment));
//
//        PredicateGroup veryGoodGroup = new PredicateGroup(
//            predicate: ((Attachment attachment) => attachment.id == secondKey), name: 'veryGoodGroup');
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
//        expect(rootGrandchildren[1].content.id, firstKey);
//        expect(rootGrandchildren[1].content.selection.id, firstKey);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to predicate and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[1].content.id, firstKey);
//        expect(rootGrandchildren[1].content.selection.id, firstKey);
//        expect(rootGrandchildren[1].content.runtimeType, Attachment);
//
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to predicate, context and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[2].content.selection.id, firstKey);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to predicate, predicate and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[2].content.id, firstKey);
//        expect(rootGrandchildren[2].content.selection.id, firstKey);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, context as parent to context, context and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[2].content.id, firstKey);
//        expect(rootGrandchildren[2].content.selection.id, firstKey);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to predicate, predicate and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[2].content.id, firstKey);
//        expect(rootGrandchildren[2].content.selection.id, firstKey);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to predicate, context and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[2].content.id, firstKey);
//        expect(rootGrandchildren[2].content.selection.id, firstKey);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//
//      test('should generate nested tree nodes, predicate as parent to context, context and attachment', () async {
//        String firstKey = new Uuid().v4();
//        Attachment firstAttachment = new Attachment()
//          ..id = firstKey
//          ..filename = 'some_other_doc_name.xlsx'
//          ..userName = testUsername;
//        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstAttachment));
//
//        String secondKey = new Uuid().v4();
//        Attachment secondAttachment = new Attachment()
//          ..id = secondKey
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
//        expect(rootGrandchildren[2].content.id, firstKey);
//        expect(rootGrandchildren[2].content.selection.id, firstKey);
//        expect(rootGrandchildren[2].content.runtimeType, Attachment);
//
//        // check one branch for the bundle
//        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//
//        // then check the other branch for the same bundle
//        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
//        expect(rootGreatGrandchildren[0].content.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
//        expect(rootGreatGrandchildren[0].content.runtimeType, Attachment);
//      });
//    });

    group('loadAttachments', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                attachmentsService: _attachmentsService,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: []));
        _api = _store.api;
        mockWindow = spy(new WindowMock(), window);
        _attachmentsService.serviceWindow = mockWindow;
      });

      tearDown(() {
        _attachmentsService.dispose();
      });

      test('default with 12 items', () async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        expect(_api.attachments.length, 0);
        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);
        expect(_api.attachments.length, 12);
      });

      test('with maintainAttachments true', () async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        expect(_api.attachments.length, 0);
        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 12);

        var newSelectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));
        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 24);
      });

//      test('with 3 pending/progress uploads', () async {
//        var uuid = new Uuid();
//        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));
//
//        expect(_api.attachments.length, 0);
//        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);
//        expect(_api.attachments.length, 12);
//
//        _api.attachments[0].uploadStatus = Status.Pending;
//        _api.attachments[2].uploadStatus = Status.Progress;
//        _api.attachments[4].uploadStatus = Status.Started;
//
//        var newSelectionKeys = new List.generate(7, (int index) => uuid.v4().toString().substring(0, 22));
//        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys);
//        expect(_api.attachments.length, 10);
//      });

//      test('with 3 pending/progress uploads and maintainAttachments true', () async {
//        var uuid = new Uuid();
//        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));
//
//        expect(_api.attachments.length, 0);
//        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys, maintainAttachments: true);
//        expect(_api.attachments.length, 12);
//
//        _api.attachments[0].uploadStatus = Status.Pending;
//        _api.attachments[2].uploadStatus = Status.Progress;
//        _api.attachments[4].uploadStatus = Status.Started;
//
//        var newSelectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));
//        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys, maintainAttachments: true);
//        expect(_api.attachments.length, 24);
//      });

      test('12 initial list, with maintainAttachments true, 9 new keys, and 3 duplicate keys', () async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        expect(_api.attachments.length, 0);
        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 12);

        var newSelectionKeys = new List.generate(9, (int index) => uuid.v4().toString().substring(0, 22));
        newSelectionKeys.addAll(selectionKeys.getRange(0, 3));

        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 21);
      });

//      test('12 initial list, with 3 pending/progress uploads, 4 new keys, and 3 duplicate keys', () async {
//        var uuid = new Uuid();
//        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));
//
//        expect(_api.attachments.length, 0);
//        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);
//        expect(_api.attachments.length, 12);
//
//        _api.attachments[0].uploadStatus = Status.Pending;
//        _api.attachments[2].uploadStatus = Status.Progress;
//        _api.attachments[4].uploadStatus = Status.Started;
//
//        var newSelectionKeys = new List.generate(4, (int index) => uuid.v4().toString().substring(0, 22));
//        newSelectionKeys.addAll(selectionKeys.getRange(4, 8));
//        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys);
//        expect(_api.attachments.length, 10);
//      });

      test(
          '12 initial list, with 3 pending/progress uploads, maintainAttachments true, 9 new keys, and 3 duplicate keys',
          () async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        expect(_api.attachments.length, 0);
        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 12);

        _api.attachments[0].uploadStatus = Status.Pending;
        _api.attachments[2].uploadStatus = Status.Progress;
        _api.attachments[4].uploadStatus = Status.Started;

        var newSelectionKeys = new List.generate(9, (int index) => uuid.v4().toString().substring(0, 22));
        newSelectionKeys.addAll(selectionKeys.getRange(5, 9));
        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 21);
      });
    });

    group('AttachmentsStore attachment actions', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
                attachmentsActions: _attachmentsActions,
                attachmentsEvents: _attachmentsEvents,
                attachmentsService: _attachmentsService,
                extensionContext: _extensionContext,
                dispatchKey: attachmentsModuleDispatchKey,
                attachments: [],
                groups: []));
        _api = _store.api;
        mockWindow = spy(new WindowMock(), window);
        _attachmentsService.serviceWindow = mockWindow;
      });

      tearDown(() async {
        // eliminate all attachments in the store cache, cancelUpload handles all cases that loadAttachments doesn't
        await _api.getAttachmentsByProducers(producerWurlsToLoad: []);
        _attachmentsActions.dispose();
        _attachmentsEvents.dispose();
        _extensionContext.dispose();
        _attachmentsService.dispose();
        _store.dispose();
        _api = null;
      });

      test('addAttachment should add an attachment to the stored list of attachments', () async {
        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = new Uuid().v4()
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
          ..id = new Uuid().v4()
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
//          ..id = new Uuid().v4()
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
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _attachmentsActions.selectAttachments(
            new SelectAttachmentsPayload(selectionKeys: [attachment.id.toString()], maintainSelections: false));
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment.id.toString());
        expect(_api.currentlySelectedAttachments, contains(attachment.id.toString()));
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
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(attachmentIds: [attachment.id.toString()], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment.id.toString());
        expect(_api.currentlySelectedAttachments, contains(attachment.id.toString()));
      });

      test('should be able to select multiple bundles by selectionKeys through api in single call', () async {
        Attachment attachment1 = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Attachment attachment2 = new Attachment()
          ..filename = 'very_good_file.pptx'
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(
            attachmentIds: [attachment1.id.toString(), attachment2.id.toString()], maintainSelections: false);

        expect(_api.currentlySelectedAttachments.length, 2);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id.toString()));
        expect(_api.currentlySelectedAttachments, contains(attachment2.id.toString()));
      });

      test('should be able to select multiple bundles by selectionKey through api one at a time maintaining selections',
          () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Attachment attachment1 = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Attachment attachment2 = new Attachment()
          ..filename = 'very_good_file.pptx'
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(attachmentIds: [attachment1.id.toString()], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment1.id.toString());
        expect(_api.currentlySelectedAttachments, isNotEmpty);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id.toString()));

        completer = new Completer();
        await _api.selectAttachmentsByIds(attachmentIds: [attachment2.id.toString()], maintainSelections: true);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment2.id.toString());
        expect(_api.currentlySelectedAttachments.length, 2);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id.toString()));
        expect(_api.currentlySelectedAttachments, contains(attachment2.id.toString()));
      });

      test('should be able to select a bundle by selectionKey through api and clear the list', () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Attachment attachment1 = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Attachment attachment2 = new Attachment()
          ..filename = 'very_good_file.pptx'
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api.selectAttachmentsByIds(attachmentIds: [attachment1.id.toString()], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment1.id.toString());
        expect(_api.currentlySelectedAttachments, isNotEmpty);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id.toString()));

        completer = new Completer();
        await _api.selectAttachmentsByIds(attachmentIds: [attachment2.id.toString()], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment2.id.toString());
        expect(_api.currentlySelectedAttachments.length, 1);
        expect(_api.currentlySelectedAttachments, contains(attachment2.id.toString()));
      });

      test('should be able to deselect a bundle by selectionKey through api', () async {
        Completer eventCompleter = new Completer();
        AttachmentDeselectedEventPayload deselectEventResult;
        _attachmentsEvents.attachmentDeselected.listen((selectEvent) {
          deselectEventResult = selectEvent;
          eventCompleter.complete();
        });

        Attachment attachment = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = new Uuid().v4()
          ..userName = testUsername;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _attachmentsActions.selectAttachments(
            new SelectAttachmentsPayload(selectionKeys: [attachment.id.toString()], maintainSelections: false));
        expect(_api.currentlySelectedAttachments, contains(attachment.id.toString()));

        await _api.deselectAttachmentsByIds(attachmentIds: [attachment.id.toString()]);
        await eventCompleter.future;

        expect(deselectEventResult.deselectedAttachmentKey, attachment.id.toString());
        expect(_api.currentlySelectedAttachments, isEmpty);
      });

      test('hoverOverAttachmentNodes should set a specified AttachmentTreeNode as hovered', () async {
        String someKey = new Uuid().v4();
        Attachment toAdd = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = someKey
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
//        String someKey = new Uuid().v4();
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
//        String someKey = new Uuid().v4();
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
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());

        mockWindow = spy(new WindowMock(), window);
        _attachmentsService.serviceWindow = mockWindow;
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
            attachmentsService: _attachmentsService,
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
            attachmentsService: _attachmentsService,
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
  });
}
