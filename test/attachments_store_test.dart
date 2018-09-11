library w_attachments_client.test.attachments_store_test;

import 'dart:async';
import 'dart:html' hide Client, Selection;

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:w_attachments_client/mocks.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/attachments_store.dart';

import './test_utils.dart' as test_utils;

void main() {
  group('AttachmentsStore', () {
    AttachmentsStore _store;
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    AttachmentsApi _api;
    cef.ExtensionContext _extensionContext;
    AttachmentsService _attachmentsService;
    Window mockWindow;

    String testUsername = 'Ron Swanson';
    String veryGoodResourceId = 'very good resource id';
    String veryGoodDocumentId = 'very good document id';
    String veryGoodSectionId = 'very good section id';
    String veryGoodRegionId = 'very good region id';
    String veryGoodEdgeName = 'very good edge name';
    String otherResourceId = 'resource id';
    String otherDocumentId = 'document id';
    String otherSectionId = 'section id';
    String otherRegionId = 'region id';
    String otherEdgeName = 'edge name';

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
                moduleConfig: new AttachmentsConfig(
                    label: 'AttachmentPackage', zipSelection: new Selection(resourceId: veryGoodResourceId))));
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
            moduleConfig: new AttachmentsConfig(
                enableDraggable: false,
                label: 'AttachmentPackage',
                zipSelection: new Selection(resourceId: veryGoodResourceId)));

        expect(_store.enableDraggable, isFalse);
      });

      test('should have default true enableUploadDropzones, and can be set to false', () {
        expect(_store.enableUploadDropzones, isTrue);

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: new AttachmentsConfig(
                enableUploadDropzones: false,
                label: 'AttachmentPackage',
                zipSelection: new Selection(resourceId: veryGoodResourceId)),
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
            moduleConfig: new AttachmentsConfig(
                enableClickToSelect: false,
                label: 'AttachmentPackage',
                zipSelection: new Selection(resourceId: veryGoodResourceId)),
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
        Selection testSelection = new Selection(resourceId: 'Wyld Stallynz!');

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: [],
            moduleConfig: new AttachmentsConfig(
                label: 'AttachmentPackage',
                primarySelection: testSelection,
                zipSelection: new Selection(resourceId: veryGoodResourceId)));
        _api = _store.api;

        expect(_api.primarySelection, isNotNull);
        expect(_api.primarySelection.resourceId, 'Wyld Stallynz!');
      });

      test('should have default StandardActionProvider when an actionProvider is not specified', () {
        expect(_store.actionProvider, isNotNull);

        _store = new AttachmentsStore(
            actionProviderFactory: null,
            moduleConfig: new AttachmentsConfig(
                enableDraggable: false,
                label: 'AttachmentPackage',
                zipSelection: new Selection(resourceId: veryGoodResourceId)),
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
                moduleConfig: new AttachmentsConfig(
                    label: 'AttachmentPackage', zipSelection: new Selection(resourceId: veryGoodResourceId)),
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

      test('should filter attachments based on resource type group pivot', () async {
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.RESOURCE,
                  id: veryGoodResourceId,
                  selection: new Selection(resourceId: veryGoodResourceId))
            ],
            uploadSelection: new Selection(resourceId: veryGoodResourceId));
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments.length, 1);
        expect(_api.groups[0].attachments[0], toAdd);

        ContextGroup otherGroup = new ContextGroup(
            name: 'group',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.RESOURCE,
                  id: otherResourceId,
                  selection: new Selection(resourceId: otherResourceId))
            ],
            uploadSelection: new Selection(resourceId: otherResourceId));
        await _api.setGroups(groups: [otherGroup]);
        expect(_api.groups[0].attachments.length, 0);
      });

      test('should filter attachments based on document type group pivot', () async {
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..key = new Uuid().v4()
          ..documentId = veryGoodDocumentId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.DOCUMENT,
                  id: veryGoodDocumentId,
                  selection: new Selection(documentId: veryGoodDocumentId))
            ],
            uploadSelection: new Selection(documentId: veryGoodDocumentId));
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments.length, 1);
        expect(_api.groups[0].attachments[0], toAdd);

        ContextGroup otherGroup = new ContextGroup(
            name: 'group',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.DOCUMENT,
                  id: otherDocumentId,
                  selection: new Selection(documentId: otherDocumentId))
            ],
            uploadSelection: new Selection(documentId: otherDocumentId));
        await _api.setGroups(groups: [otherGroup]);
        expect(_api.groups[0].attachments.length, 0);
      });

      test('should filter attachments based on section type group pivot', () async {
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..key = new Uuid().v4()
          ..sectionId = veryGoodSectionId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.SECTION,
                  id: veryGoodSectionId,
                  selection: new Selection(sectionId: veryGoodSectionId))
            ],
            uploadSelection: new Selection(sectionId: veryGoodSectionId));
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments.length, 1);
        expect(_api.groups[0].attachments[0], toAdd);

        ContextGroup otherGroup = new ContextGroup(
            name: 'group',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.SECTION, id: otherSectionId, selection: new Selection(sectionId: otherSectionId))
            ],
            uploadSelection: new Selection(sectionId: otherSectionId));
        await _api.setGroups(groups: [otherGroup]);
        expect(_api.groups[0].attachments.length, 0);
      });

      test('should filter attachments based on region type group pivot', () async {
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..key = new Uuid().v4()
          ..regionId = veryGoodRegionId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.REGION,
                  id: veryGoodRegionId,
                  selection: new Selection(regionId: veryGoodRegionId))
            ],
            uploadSelection: new Selection(regionId: veryGoodRegionId));
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments.length, 1);
        expect(_api.groups[0].attachments[0], toAdd);

        ContextGroup otherGroup = new ContextGroup(
            name: 'group',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.REGION, id: otherRegionId, selection: new Selection(regionId: otherRegionId))
            ],
            uploadSelection: new Selection(regionId: otherRegionId));
        await _api.setGroups(groups: [otherGroup]);
        expect(_api.groups[0].attachments.length, 0);
      });

      test('should filter attachments based on graph vertex type group pivot', () async {
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId
          ..edgeName = veryGoodEdgeName;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [
              new GroupPivot(
                  type: GroupPivotType.GRAPH_VERTEX,
                  id: veryGoodResourceId,
                  selection: new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName))
            ],
            uploadSelection: new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName));
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments.length, 1);
        expect(_api.groups[0].attachments[0], toAdd);

        ContextGroup otherGroup = new ContextGroup(name: 'group', pivots: [
          new GroupPivot(
              type: GroupPivotType.GRAPH_VERTEX,
              id: otherResourceId,
              selection: new Selection(resourceId: otherResourceId, edgeName: otherEdgeName))
        ]);
        await _api.setGroups(groups: [otherGroup]);
        expect(_api.groups[0].attachments.length, 0);
      });

      test('should filter attachments based on ALL type group pivot', () async {
        Bundle documentType = new Bundle();
        documentType.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        documentType.selection
          ..key = new Uuid().v4()
          ..documentId = veryGoodDocumentId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: documentType));

        Bundle sectionType = new Bundle();
        sectionType.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        sectionType.selection
          ..key = new Uuid().v4()
          ..sectionId = veryGoodSectionId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: sectionType));

        Bundle regionType = new Bundle();
        regionType.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        regionType.selection
          ..key = new Uuid().v4()
          ..regionId = veryGoodRegionId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: regionType));

        Bundle resourceType = new Bundle();
        resourceType.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        resourceType.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: resourceType));

        Bundle graphVertexType = new Bundle();
        graphVertexType.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        graphVertexType.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId
          ..edgeName = veryGoodEdgeName;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: graphVertexType));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.ALL,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName))
        ]);
        await _api.setGroups(groups: [veryGoodGroup]);
        expect(_api.groups[0].attachments.length, 5);
        expect(_api.groups[0].attachments.any((bundle) => bundle == graphVertexType), isTrue);
        expect(_api.groups[0].attachments.any((bundle) => bundle == resourceType), isTrue);
        expect(_api.groups[0].attachments.any((bundle) => bundle == sectionType), isTrue);
        expect(_api.groups[0].attachments.any((bundle) => bundle == documentType), isTrue);
        expect(_api.groups[0].attachments.any((bundle) => bundle == regionType), isTrue);
      });
    });

    group('setFilters', () {
      Bundle pdfAttachment;
      Bundle docAttachment;
      ContextGroup someContextGroup;
      PredicateGroup pdfPredicate;
      PredicateGroup docPredicate;

      setUp(() async {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(
                    label: 'AttachmentPackage', zipSelection: new Selection(resourceId: veryGoodResourceId)),
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

        pdfAttachment = new Bundle();
        pdfAttachment.annotation
          ..filename = 'very_good_file.pdf'
          ..filemime = 'application/pdf'
          ..author = testUsername;
        pdfAttachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: pdfAttachment));

        docAttachment = new Bundle();
        docAttachment.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        docAttachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: docAttachment));

        someContextGroup = new ContextGroup(name: 'ContextGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        pdfPredicate = new PredicateGroup(
            name: 'pdf_pred',
            predicate: (Attachment attachment) {
              return attachment.filemime == 'application/pdf';
            });

        docPredicate = new PredicateGroup(
            name: 'doc_pred',
            predicate: (Attachment attachment) {
              return attachment.filemime ==
                  'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            });
      });

      tearDown(() {
        _attachmentsService.dispose();
      });

      test('should set filter with a new filter', () async {
        String filterName = someContextGroup.pivots.first.id;
        someContextGroup.filterName = filterName;
        Filter newFilter = new Filter(name: filterName, predicates: [pdfPredicate, docPredicate]);

        await _api.setFilters(filters: [newFilter]);
        expect(_api.filters, [newFilter]);
        expect(_api.filtersByName[filterName], newFilter);
      });
    });

    group('_generateTreeNodes', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(
                    label: 'AttachmentPackage', zipSelection: new Selection(resourceId: veryGoodResourceId)),
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

      test('should generate nested tree nodes when given a nested directory structure', () async {
        String someKey = new Uuid().v4();
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..resourceId = veryGoodResourceId
          ..key = someKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, ContextGroup);
        expect(rootChildren[0].children.length, 1);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);

        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
        expect(rootGreatGrandchildren[0].content.id, someKey);
        expect(rootGreatGrandchildren[0].content.selection.id, someKey);
      });

      test('should generate nested tree nodes, context as parent to context and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [
          veryGoodGroup
        ], pivots: [
          new GroupPivot(
              type: GroupPivotType.SECTION,
              id: veryGoodSectionId,
              selection: new Selection(sectionId: veryGoodSectionId))
        ]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, ContextGroup);
        expect(rootChildren[0].children.length, 2);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[1].content.id, firstKey);
        expect(rootGrandchildren[1].content.selection.id, firstKey);
        expect(rootGrandchildren[1].content.runtimeType, Bundle);

        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, predicate as parent to context and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        PredicateGroup parentGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => true), name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, PredicateGroup);
        expect(rootChildren[0].children.length, 2);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[1].content.id, firstKey);
        expect(rootGrandchildren[1].content.selection.id, firstKey);
        expect(rootGrandchildren[1].content.runtimeType, Bundle);

        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, predicate as parent to predicate and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..filesize = 1
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        PredicateGroup veryGoodGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filesize == 1), name: 'veryGoodGroup');

        PredicateGroup parentGroup = new PredicateGroup(
            name: 'parentGroup', childGroups: [veryGoodGroup], predicate: ((Attachment attachment) => true));
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, PredicateGroup);
        expect(rootChildren[0].children.length, 2);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[1].content.id, firstKey);
        expect(rootGrandchildren[1].content.selection.id, firstKey);
        expect(rootGrandchildren[1].content.runtimeType, Bundle);

        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, context as parent to predicate and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'some_other_doc_name.xlsx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        PredicateGroup veryGoodGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
            name: 'veryGoodGroup');

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [
          veryGoodGroup
        ], pivots: [
          new GroupPivot(
              type: GroupPivotType.SECTION,
              id: veryGoodSectionId,
              selection: new Selection(sectionId: veryGoodSectionId))
        ]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, ContextGroup);
        expect(rootChildren[0].children.length, 2);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[1].content.id, firstKey);
        expect(rootGrandchildren[1].content.selection.id, firstKey);
        expect(rootGrandchildren[1].content.runtimeType, Bundle);

        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, context as parent to predicate, context and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'some_other_doc_name.xlsx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        PredicateGroup veryGoodGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
            name: 'veryGoodGroup');

        ContextGroup secondGroup = new ContextGroup(name: 'secondGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [
          veryGoodGroup,
          secondGroup
        ], pivots: [
          new GroupPivot(
              type: GroupPivotType.SECTION,
              id: veryGoodSectionId,
              selection: new Selection(sectionId: veryGoodSectionId))
        ]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, ContextGroup);
        expect(rootChildren[0].children.length, 3);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[1].content.name, 'secondGroup');
        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[2].content.selection.id, firstKey);
        expect(rootGrandchildren[2].content.runtimeType, Bundle);

        // check one branch for the bundle
        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);

        // then check the other branch for the same bundle
        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, context as parent to predicate, predicate and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'some_other_doc_name.xlsx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        PredicateGroup veryGoodGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
            name: 'veryGoodGroup');

        PredicateGroup secondGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
            name: 'secondGroup');

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [
          veryGoodGroup,
          secondGroup
        ], pivots: [
          new GroupPivot(
              type: GroupPivotType.SECTION,
              id: veryGoodSectionId,
              selection: new Selection(sectionId: veryGoodSectionId))
        ]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, ContextGroup);
        expect(rootChildren[0].children.length, 3);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[1].content.name, 'secondGroup');
        expect(rootGrandchildren[1].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[2].content.id, firstKey);
        expect(rootGrandchildren[2].content.selection.id, firstKey);
        expect(rootGrandchildren[2].content.runtimeType, Bundle);

        // check one branch for the bundle
        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);

        // then check the other branch for the same bundle
        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, context as parent to context, context and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'some_other_doc_name.xlsx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup secondGroup = new ContextGroup(name: 'secondGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [
          veryGoodGroup,
          secondGroup
        ], pivots: [
          new GroupPivot(
              type: GroupPivotType.SECTION,
              id: veryGoodSectionId,
              selection: new Selection(sectionId: veryGoodSectionId))
        ]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, ContextGroup);
        expect(rootChildren[0].children.length, 3);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[1].content.name, 'secondGroup');
        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[2].content.id, firstKey);
        expect(rootGrandchildren[2].content.selection.id, firstKey);
        expect(rootGrandchildren[2].content.runtimeType, Bundle);

        // check one branch for the bundle
        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);

        // then check the other branch for the same bundle
        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, predicate as parent to predicate, predicate and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'some_other_doc_name.xlsx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        PredicateGroup veryGoodGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
            name: 'veryGoodGroup');

        PredicateGroup secondGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
            name: 'secondGroup');

        PredicateGroup parentGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.userName == testUsername),
            name: 'parentGroup',
            childGroups: [veryGoodGroup, secondGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, PredicateGroup);
        expect(rootChildren[0].children.length, 3);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[1].content.name, 'secondGroup');
        expect(rootGrandchildren[1].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[2].content.id, firstKey);
        expect(rootGrandchildren[2].content.selection.id, firstKey);
        expect(rootGrandchildren[2].content.runtimeType, Bundle);

        // check one branch for the bundle
        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);

        // then check the other branch for the same bundle
        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, predicate as parent to predicate, context and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'some_other_doc_name.xlsx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        PredicateGroup veryGoodGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.filename == 'very_good_file.docx'),
            name: 'veryGoodGroup');

        ContextGroup secondGroup = new ContextGroup(name: 'secondGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        PredicateGroup parentGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.userName == testUsername),
            name: 'parentGroup',
            childGroups: [veryGoodGroup, secondGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, PredicateGroup);
        expect(rootChildren[0].children.length, 3);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, PredicateGroup);
        expect(rootGrandchildren[1].content.name, 'secondGroup');
        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[2].content.id, firstKey);
        expect(rootGrandchildren[2].content.selection.id, firstKey);
        expect(rootGrandchildren[2].content.runtimeType, Bundle);

        // check one branch for the bundle
        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);

        // then check the other branch for the same bundle
        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });

      test('should generate nested tree nodes, predicate as parent to context, context and attachment', () async {
        String firstKey = new Uuid().v4();
        Bundle firstBundle = new Bundle();
        firstBundle.annotation
          ..filename = 'some_other_doc_name.xlsx'
          ..author = testUsername;
        firstBundle.selection
          ..sectionId = veryGoodSectionId
          ..key = firstKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: firstBundle));

        String secondKey = new Uuid().v4();
        Bundle secondBundle = new Bundle();
        secondBundle.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        secondBundle.selection
          ..sectionId = veryGoodSectionId
          ..resourceId = veryGoodResourceId
          ..key = secondKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: secondBundle));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup secondGroup = new ContextGroup(name: 'secondGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        PredicateGroup parentGroup = new PredicateGroup(
            predicate: ((Attachment attachment) => attachment.userName == testUsername),
            name: 'parentGroup',
            childGroups: [veryGoodGroup, secondGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.rootNode.children.length, 1);

        List rootChildren = _store.rootNode.children.toList();
        expect(rootChildren[0].content.name, 'parentGroup');
        expect(rootChildren[0].content.runtimeType, PredicateGroup);
        expect(rootChildren[0].children.length, 3);

        List rootGrandchildren = rootChildren[0].children.toList();
        expect(rootGrandchildren[0].content.name, 'veryGoodGroup');
        expect(rootGrandchildren[0].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[1].content.name, 'secondGroup');
        expect(rootGrandchildren[1].content.runtimeType, ContextGroup);
        expect(rootGrandchildren[2].content.id, firstKey);
        expect(rootGrandchildren[2].content.selection.id, firstKey);
        expect(rootGrandchildren[2].content.runtimeType, Bundle);

        // check one branch for the bundle
        List rootGreatGrandchildren = rootGrandchildren[0].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);

        // then check the other branch for the same bundle
        rootGreatGrandchildren = rootGrandchildren[1].children.toList();
        expect(rootGreatGrandchildren[0].content.id, secondKey);
        expect(rootGreatGrandchildren[0].content.selection.id, secondKey);
        expect(rootGreatGrandchildren[0].content.runtimeType, Bundle);
      });
    });

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
                moduleConfig: new AttachmentsConfig(
                    label: 'AttachmentPackage', zipSelection: new Selection(resourceId: veryGoodResourceId)),
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

      test('with 3 pending/progress uploads', () async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        expect(_api.attachments.length, 0);
        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);
        expect(_api.attachments.length, 12);

        _api.attachments[0].uploadStatus = Status.Pending;
        _api.attachments[2].uploadStatus = Status.Progress;
        _api.attachments[4].uploadStatus = Status.Started;

        var newSelectionKeys = new List.generate(7, (int index) => uuid.v4().toString().substring(0, 22));
        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys);
        expect(_api.attachments.length, 10);
      });

      test('with 3 pending/progress uploads and maintainAttachments true', () async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        expect(_api.attachments.length, 0);
        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 12);

        _api.attachments[0].uploadStatus = Status.Pending;
        _api.attachments[2].uploadStatus = Status.Progress;
        _api.attachments[4].uploadStatus = Status.Started;

        var newSelectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));
        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys, maintainAttachments: true);
        expect(_api.attachments.length, 24);
      });

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

      test('12 initial list, with 3 pending/progress uploads, 4 new keys, and 3 duplicate keys', () async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        expect(_api.attachments.length, 0);
        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);
        expect(_api.attachments.length, 12);

        _api.attachments[0].uploadStatus = Status.Pending;
        _api.attachments[2].uploadStatus = Status.Progress;
        _api.attachments[4].uploadStatus = Status.Started;

        var newSelectionKeys = new List.generate(4, (int index) => uuid.v4().toString().substring(0, 22));
        newSelectionKeys.addAll(selectionKeys.getRange(4, 8));
        await _api.getAttachmentsByProducers(producerWurlsToLoad: newSelectionKeys);
        expect(_api.attachments.length, 10);
      });

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

    group('downloadAllAttachmentsAsZip', () {
      setUp(() {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = spy(new AttachmentsServiceStub(), new AttachmentsTestService());
        _store = spy(
            new AttachmentsStoreMock(),
            new AttachmentsStore(
                actionProviderFactory: StandardActionProvider.actionProviderFactory,
                moduleConfig: new AttachmentsConfig(
                    label: 'AttachmentPackage', zipSelection: new Selection(resourceId: veryGoodResourceId)),
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

      test('default test', test_utils.swallowPrints(() async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);
        await _api.downloadAllAttachmentsAsZip(
            keys: _api.attachmentKeys, label: _api.label, zipSelection: _api.zipSelection);

        verify(_attachmentsService.downloadFilesAsZip(keys: selectionKeys, label: captureAny, zipSelection: captureAny))
            .called(1);
        verify(mockWindow.open('/test_download.txt', '_blank')).called(1);
      }));

      test('with custom selection', test_utils.swallowPrints(() async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));
        Selection customSelection = new Selection(documentId: veryGoodDocumentId, sectionId: veryGoodSectionId);

        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);
        await _api.downloadAllAttachmentsAsZip(
            keys: _api.attachmentKeys, label: _api.label, zipSelection: customSelection);

        verify(_attachmentsService.downloadFilesAsZip(
                keys: selectionKeys, label: captureAny, zipSelection: customSelection))
            .called(1);
        verify(mockWindow.open('/test_download.txt', '_blank')).called(1);
      }));

      test('with non-complete bundles', test_utils.swallowPrints(() async {
        var uuid = new Uuid();
        var selectionKeys = new List.generate(12, (int index) => uuid.v4().toString().substring(0, 22));

        await _api.getAttachmentsByProducers(producerWurlsToLoad: selectionKeys);

        _api.attachments[0].uploadStatus = Status.Failed;
        _api.attachments[1].uploadStatus = Status.Pending;
        _api.attachments[2].uploadStatus = Status.Progress;
        _api.attachments[3].uploadStatus = Status.Started;

        await _api.downloadAllAttachmentsAsZip(
            keys: _api.attachmentKeys, label: _api.label, zipSelection: _api.zipSelection);

        verify(_attachmentsService.downloadFilesAsZip(
                keys: selectionKeys.getRange(4, selectionKeys.length), label: captureAny, zipSelection: captureAny))
            .called(1);
        verify(mockWindow.open('/test_download.txt', '_blank')).called(1);
      }));
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
                moduleConfig: new AttachmentsConfig(
                    label: 'AttachmentPackage', zipSelection: new Selection(resourceId: veryGoodResourceId)),
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
        for (Bundle attachment in _store.attachments) {
          await _api.cancelUpload(keyToCancel: attachment.selection.key);
        }
        _attachmentsActions.dispose();
        _attachmentsEvents.dispose();
        _extensionContext.dispose();
        _attachmentsService.dispose();
        _store.dispose();
        _api = null;
      });

      test('addAttachment should add an attachment to the stored list of attachments', () async {
        Bundle attachment = new Bundle();
        attachment.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_store.attachments, [attachment]);

        // adding the same attachment again should not modify the list
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_store.attachments, [attachment]);
      });

      test('cancelUpload should call an upload task in the thread pool to be cancelled', () async {
        Completer completer = new Completer();
        Bundle toCancel;
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Progress) {
            toCancel = uploadStatus.attachment;
            completer.complete();
          }
        });
        // event is emitted for completed cancel
        StreamSubscription cancelStream = _attachmentsEvents.attachmentUploadCanceled.listen((cancelEvent) {
          expect(cancelEvent.canceledSelectionKeys, [toCancel.id]);
          expect(cancelEvent.cancelCompleted, isTrue);
        });

        File mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/pdf');
        when(mockFile.name).thenReturn('test_attachment.pdf');
        when(mockFile.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _api.uploadFiles(toUpload: selection);
        await completer.future;
        completer = new Completer();
        await _api.cancelUpload(keyToCancel: toCancel.selection.key);

        verify(_attachmentsService.selectFiles(allowMultiple: captureAny)).called(1);
        verify(_attachmentsService.uploadFiles(selection: selection, files: [mockFile])).called(1);
        verify(_attachmentsService.cancelUploads([toCancel])).called(1);
        await new Future.delayed(Duration.ZERO);
        expect(_store.attachments.length, 1);
        expect(_store.attachments.first.uploadStatus, Status.Cancelled);
        cancelStream.cancel();
      });

      test('cancelUpload should call a pending upload task in the thread pool to be cancelled', () async {
        Completer uploadCompleter = new Completer();
        Completer cancelCompleter = new Completer();
        int pendingCompleteCount = 0;
        StreamSubscription<UploadStatus> listener = _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Pending && ++pendingCompleteCount == 3) {
            if (!uploadCompleter.isCompleted) {
              uploadCompleter.complete();
            }
          } else if (uploadStatus.status == Status.Cancelled) {
            if (!cancelCompleter.isCompleted) {
              cancelCompleter.complete();
            }
          }
        });

        File mockFile1 = new FileMock();
        when(mockFile1.type).thenReturn('application/pdf');
        when(mockFile1.name).thenReturn('test_attachment1.pdf');
        when(mockFile1.size).thenReturn(10000000);

        File mockFile2 = new FileMock();
        when(mockFile2.type).thenReturn('application/pdf');
        when(mockFile2.name).thenReturn('test_attachment2.pdf');
        when(mockFile2.size).thenReturn(10000000);

        File mockFile3 = new FileMock();
        when(mockFile3.type).thenReturn('application/pdf');
        when(mockFile3.name).thenReturn('test_attachment3.pdf');
        when(mockFile3.size).thenReturn(10000000);

        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile1, mockFile2, mockFile3]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _api.uploadFiles(toUpload: selection);
        await uploadCompleter.future;

        Bundle toCancel = _store.attachments.firstWhere((bundle) => bundle.uploadStatus == Status.Pending);
        List bundlesByAttachmentId = _api.attachments
            .where((bundle) => bundle.annotation.attachmentId == toCancel.annotation.attachmentId)
            .toList();
        List bundleKeysByAttachmentId =
            new List<String>.from(bundlesByAttachmentId.map((attachment) => attachment?.id));

        // event is emitted for completed cancel
        StreamSubscription cancelStream = _attachmentsEvents.attachmentUploadCanceled.listen((cancelEvent) {
          expect(cancelEvent.canceledSelectionKeys, bundleKeysByAttachmentId);
          expect(cancelEvent.cancelCompleted, isTrue);
        });

        await _api.cancelUpload(keyToCancel: toCancel.selection.key);
        await cancelCompleter.future;

        listener.cancel();

        verify(_attachmentsService.cancelUploads(bundlesByAttachmentId)).called(1);
        await new Future.delayed(Duration.ZERO);
        expect(_store.attachments.length, 3);
        expect(_store.attachments.any((attachment) => attachment.uploadStatus == Status.Cancelled), isTrue);
        cancelStream.cancel();
      });

      test(
          'cancelUpload should call an in-progress upload task in the thread pool to be cancelled, and start a pending one',
          () async {
        File mockFile1 = new FileMock();
        when(mockFile1.type).thenReturn('application/pdf');
        when(mockFile1.name).thenReturn('test_attachment1.pdf');
        when(mockFile1.size).thenReturn(10000000);

        File mockFile2 = new FileMock();
        when(mockFile2.type).thenReturn('application/pdf');
        when(mockFile2.name).thenReturn('test_attachment2.pdf');
        when(mockFile2.size).thenReturn(10000000);

        File mockFile3 = new FileMock();
        when(mockFile3.type).thenReturn('application/pdf');
        when(mockFile3.name).thenReturn('test_attachment3.pdf');
        when(mockFile3.size).thenReturn(10000000);

        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile1, mockFile2, mockFile3]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _api.uploadFiles(toUpload: selection);
        await new Future.delayed(new Duration(milliseconds: 65));

        expect(_store.attachments.any((bundle) => bundle.uploadStatus == Status.Pending), isTrue);
        Bundle toCancel = _store.attachments.firstWhere((bundle) => bundle.uploadStatus == Status.Progress);
        await _api.cancelUpload(keyToCancel: toCancel.selection.key);

        List<Bundle> bundlesByAttachmentId = _api.attachments
            .where((bundle) => bundle.annotation.attachmentId == toCancel.annotation.attachmentId)
            .toList();
        verify(_attachmentsService.cancelUploads(bundlesByAttachmentId)).called(1);
        int _counter = 0;
        while (_store.attachments.any((bundle) => bundle.uploadStatus == Status.Pending) && _counter++ <= 5) {
          await new Future.delayed(new Duration(milliseconds: 50));
        }
        expect(_store.attachments.length, 3);
        for (Bundle attachment in _store.attachments) {
          expect(attachment.uploadStatus, anyOf(Status.Progress, Status.Cancelled));
        }
      });

      test('cancelUploads should call a list of upload tasks in the thread pool to be cancelled', () async {
        Completer completer = new Completer();
        List<Bundle> bundlesToCancel = [];
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Progress) {
            bundlesToCancel.add(uploadStatus.attachment);
            completer.complete();
          }
        });

        Selection selection = new Selection(resourceId: veryGoodResourceId);

        File mockFile1 = new FileMock();
        when(mockFile1.type).thenReturn('application/pdf');
        when(mockFile1.name).thenReturn('test_attachment.pdf');
        when(mockFile1.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile1]);
        await _api.uploadFiles(toUpload: selection);
        await completer.future;

        completer = new Completer();
        File mockFile2 = new FileMock();
        when(mockFile2.type).thenReturn('application/pdf');
        when(mockFile2.name).thenReturn('test_attachment.pdf');
        when(mockFile2.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile2]);
        await _api.uploadFiles(toUpload: selection);
        await completer.future;

        List<String> toCancel = [];
        for (Bundle bundle in bundlesToCancel) {
          toCancel.add(bundle.id);
        }

        // event is emitted for completed cancel
        StreamSubscription cancelStream = _attachmentsEvents.attachmentUploadCanceled.listen((cancelEvent) {
          for (String key in toCancel) {
            expect(cancelEvent.canceledSelectionKeys, contains(key));
          }
          expect(cancelEvent.cancelCompleted, isTrue);
        });
        await _api.cancelUploads(keysToCancel: toCancel);

        verify(_attachmentsService.selectFiles(allowMultiple: captureAny)).called(2);
        verify(_attachmentsService.uploadFiles(selection: selection, files: [mockFile1])).called(1);
        verify(_attachmentsService.uploadFiles(selection: selection, files: [mockFile2])).called(1);
        verify(_attachmentsService.cancelUploads(bundlesToCancel)).called(1);
        await new Future.delayed(Duration.ZERO);
        expect(_store.attachments.length, 2);
        expect(_store.attachments.every((bundle) => bundle.uploadStatus == Status.Cancelled), isTrue);
        cancelStream.cancel();
      });

      test('dropFiles should take a selection and list of files and add them to store cache', () async {
        List<Completer> completers = new List<Completer>();
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Complete) {
            for (int i = 0; i < completers.length; i++) {
              if (!completers[i].isCompleted) {
                completers[i].complete();
                break;
              }
            }
          }
        });

        File mockFile1 = new FileMock();
        when(mockFile1.type).thenReturn('application/pdf');
        when(mockFile1.name).thenReturn('test_attachment1.pdf');
        when(mockFile1.size).thenReturn(12345);

        File mockFile2 = new FileMock();
        when(mockFile2.type).thenReturn('application/pdf');
        when(mockFile2.name).thenReturn('test_attachment2.pdf');
        when(mockFile2.size).thenReturn(678910);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        List<File> files = new List<File>.from([mockFile1, mockFile2]);
        for (int i = 0; i < files.length; i++) {
          completers.add(new Completer());
        }

        await _attachmentsActions.dropFiles(new DropFilesPayload(selection: selection, files: files));
        for (int i = 0; i < completers.length; i++) {
          await completers[i].future;
        }

        verify(_attachmentsService.uploadFiles(selection: selection, files: files)).called(1);
        expect(_store.attachments.length, 2);

        expect(_store.attachments[0].annotation.filemime, 'application/pdf');
        expect(_store.attachments[0].annotation.filename, 'test_attachment1.pdf');
        expect(_store.attachments[0].annotation.filesize, 12345);

        expect(_store.attachments[1].annotation.filemime, 'application/pdf');
        expect(_store.attachments[1].annotation.filename, 'test_attachment2.pdf');
        expect(_store.attachments[1].annotation.filesize, 678910);
      });

      test('updateAttachment should modify an existent attachment in the list', () async {
        Bundle attachment = new Bundle();
        attachment.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        attachment.annotation.author = 'Harvey Birdman';

        await _attachmentsActions.updateAttachment(new UpdateAttachmentPayload(toUpdate: attachment));

        expect(_store.attachments, [attachment]);
        expect(_store.attachments[0].annotation.author, 'Harvey Birdman');
      });

      test('upsertAttachment should update if bundle exists, add if doesn\'t exist', () async {
        Bundle attachment = new Bundle();
        attachment.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;

        expect(_store.attachments, isEmpty);

        _attachmentsActions.upsertAttachment(new UpsertAttachmentPayload(toUpsert: attachment));
        await new Future.delayed(Duration.ZERO);
        expect(_store.attachments, [attachment]);
        expect(_store.attachments[0].annotation.author, 'Ron Swanson');

        attachment.annotation.author = 'Harvey Birdman';

        _attachmentsActions.upsertAttachment(new UpsertAttachmentPayload(toUpsert: attachment));
        await new Future.delayed(Duration.ZERO);
        expect(_store.attachments, [attachment]);
        expect(_store.attachments[0].annotation.author, 'Harvey Birdman');
      });

      test('removeAttachment should remove an attachment from store list', () async {
        Completer completer = new Completer();
        AttachmentRemovedEventPayload removeEventResult;
        _attachmentsEvents.attachmentRemoved.listen((removeEvent) {
          removeEventResult = removeEvent;
          completer.complete();
        });

        File mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/pdf');
        when(mockFile.name).thenReturn('test_attachment.pdf');
        when(mockFile.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _attachmentsActions.uploadFiles(new UploadAttachmentPayload(selection: selection));
        await new Future.delayed(Duration.ZERO);

        expect(_store.attachments.length, 1);
        Bundle attachment = _store.attachments[0];

        await _api.removeAttachment(keyToRemove: attachment.id);
        await completer.future;

        expect(removeEventResult.responseStatus, true);
        expect(_store.attachments, []);
      });

      test('uploadFiles should take a selection, call FileSelector and add to store cache', () async {
        Completer completer = new Completer();
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Complete) completer.complete();
        });

        File mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/pdf');
        when(mockFile.name).thenReturn('test_attachment.pdf');
        when(mockFile.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _api.uploadFiles(toUpload: selection);
        await completer.future;

        verify(_attachmentsService.selectFiles(allowMultiple: captureAny)).called(1);
        verify(_attachmentsService.uploadFiles(selection: selection, files: [mockFile])).called(1);
        expect(_store.attachments.length, 1);
        Bundle result = _store.attachments[0];
        expect(result.annotation.filemime, 'application/pdf');
        expect(result.annotation.filename, 'test_attachment.pdf');
        expect(result.annotation.filesize, 10000);
      });

      test('replaceAttachment should take a bundle, call FileSelector and add to store cache', () async {
        Completer completer = new Completer();
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Complete) completer.complete();
        });

        File mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/pdf');
        when(mockFile.name).thenReturn('test_attachment.pdf');
        when(mockFile.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _api.uploadFiles(toUpload: selection);
        await completer.future;
        completer = new Completer();

        verify(_attachmentsService.selectFiles(allowMultiple: true)).called(1);

        mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        when(mockFile.name).thenReturn('another_attachment.pdf');
        when(mockFile.size).thenReturn(9999);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);

        Bundle result = _store.attachments.first;
        await _api.replaceAttachment(keyToReplace: result.selection.key);
        await completer.future;

        verify(_attachmentsService.selectFiles(allowMultiple: false)).called(1);
        verify(_attachmentsService.replaceAttachment(toReplace: [result], replacement: mockFile)).called(1);
        expect(_store.attachments.length, 1);
        result = _store.attachments.first;
        expect(result.annotation.filemime, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        expect(result.annotation.filename, 'another_attachment.pdf');
        expect(result.annotation.filesize, 9999);
      });

      test('replaceAttachment should update all bundles matching the attachmentId of the specified bundle', () async {
        Completer completer1 = new Completer();
        Completer completer2 = new Completer();
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Complete) {
            if (!completer1.isCompleted) {
              completer1.complete();
            } else {
              completer2.complete();
            }
          }
        });

        File mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/pdf');
        when(mockFile.name).thenReturn('test_attachment.pdf');
        when(mockFile.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _api.uploadFiles(toUpload: selection);
        await completer1.future;
        completer1 = new Completer();

        verify(_attachmentsService.selectFiles(allowMultiple: true)).called(1);

        Selection secondSelection = new Selection(regionId: veryGoodRegionId);
        secondSelection.key = '12345';
        Annotation secondAnnotation = new Annotation.from(
            _api.attachments.firstWhere((bundle) => bundle.annotation.filename == 'test_attachment.pdf').annotation);
        secondAnnotation.key = '67890';
        secondSelection.annotationKey = '67890';
        await _store.attachmentsActions.upsertAttachment(new UpsertAttachmentPayload(
            toUpsert: new Bundle()
              ..selection = secondSelection
              ..annotation = secondAnnotation));

        mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        when(mockFile.name).thenReturn('another_attachment.pdf');
        when(mockFile.size).thenReturn(9999);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);

        List<Bundle> result = _store.attachments
            .where((bundle) => bundle.annotation.attachmentId == _store.attachments.first.annotation.attachmentId)
            .toList();
        await _api.replaceAttachment(keyToReplace: result.first.id);
        await completer1.future;
        await completer2.future;

        verify(_attachmentsService.selectFiles(allowMultiple: false)).called(1);
        verify(_attachmentsService.replaceAttachment(toReplace: result, replacement: mockFile)).called(1);
        expect(_store.attachments.length, 2);

        expect(_store.attachments.first.annotation.filemime,
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        expect(_store.attachments.first.annotation.filename, 'another_attachment.pdf');
        expect(_store.attachments.first.annotation.filesize, 9999);
        expect(_store.attachments.last.annotation.filemime,
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        expect(_store.attachments.last.annotation.filename, 'another_attachment.pdf');
        expect(_store.attachments.last.annotation.filesize, 9999);
      });

      test('downloadAttachment should fetch a download url and open it', test_utils.swallowPrints(() async {
        Completer completer = new Completer();
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Complete) completer.complete();
        });

        File mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/pdf');
        when(mockFile.name).thenReturn('test_attachment.pdf');
        when(mockFile.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _attachmentsActions.uploadFiles(new UploadAttachmentPayload(selection: selection));
        await completer.future;

        String downloadKey = _store.attachments[0].id;

        await _api.downloadAttachment(keyToDownload: downloadKey);

        verify(_attachmentsService.downloadFile(downloadKey)).called(1);
        verify(mockWindow.open('/test_download.txt', '_blank')).called(1);
      }));

      test('selectAttachment should set the store\'s currentlySelected with the passed in arg', () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Bundle attachment = new Bundle();
        attachment.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _attachmentsActions.selectAttachments(
            new SelectAttachmentsPayload(selectionKeys: [attachment.id.toString()], maintainSelections: false));
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment.id.toString());
        expect(_api.currentlySelectedAttachments, contains(attachment.id.toString()));
      });

      test('deselectAttachment should set the store\'s currentlySelected to empty', () async {
        Completer eventCompleter = new Completer();
        AttachmentDeselectedEventPayload deselectEventResult;
        _attachmentsEvents.attachmentDeselected.listen((selectEvent) {
          deselectEventResult = selectEvent;
          eventCompleter.complete();
        });

        Completer uploadCompleter = new Completer();
        _attachmentsService.uploadStatusStream.listen((uploadStatus) {
          if (uploadStatus.status == Status.Complete) uploadCompleter.complete();
        });

        File mockFile = new FileMock();
        when(mockFile.type).thenReturn('application/pdf');
        when(mockFile.name).thenReturn('test_attachment.pdf');
        when(mockFile.size).thenReturn(10000);
        when(_attachmentsService.selectFiles(allowMultiple: captureAny)).thenReturn([mockFile]);
        Selection selection = new Selection(resourceId: veryGoodResourceId);

        await _attachmentsActions.uploadFiles(new UploadAttachmentPayload(selection: selection));
        await uploadCompleter.future;
        Bundle attachment = _store.attachments[0];

        expect(_api.currentlySelectedAttachments, isEmpty);
        await _attachmentsActions.selectAttachments(
            new SelectAttachmentsPayload(selectionKeys: [attachment.id.toString()], maintainSelections: false));
        expect(_api.currentlySelectedAttachments, contains(attachment.id.toString()));

        await _attachmentsActions
            .deselectAttachments(new DeselectAttachmentsPayload(selectionKeys: [attachment.id.toString()]));
        await eventCompleter.future;

        expect(deselectEventResult.deselectedAttachmentKey, attachment.id.toString());
        expect(_api.currentlySelectedAttachments, isEmpty);
      });

      test('should be able to select a bundle by selectionKey through api', () async {
        Completer completer = new Completer();
        AttachmentSelectedEventPayload selectEventResult;
        _attachmentsEvents.attachmentSelected.listen((selectEvent) {
          selectEventResult = selectEvent;
          completer.complete();
        });

        Bundle attachment = new Bundle();
        attachment.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api
            .selectAttachmentsByIds(attachmentIds: [attachment.id.toString()], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment.id.toString());
        expect(_api.currentlySelectedAttachments, contains(attachment.id.toString()));
      });

      test('should be able to select multiple bundles by selectionKeys through api in single call', () async {
        Bundle attachment1 = new Bundle();
        attachment1.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment1.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Bundle attachment2 = new Bundle();
        attachment2.annotation
          ..filename = 'very_good_file.pptx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
          ..author = testUsername;
        attachment2.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
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

        Bundle attachment1 = new Bundle();
        attachment1.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment1.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Bundle attachment2 = new Bundle();
        attachment2.annotation
          ..filename = 'very_good_file.pptx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
          ..author = testUsername;
        attachment2.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api
            .selectAttachmentsByIds(attachmentIds: [attachment1.id.toString()], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment1.id.toString());
        expect(_api.currentlySelectedAttachments, isNotEmpty);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id.toString()));

        completer = new Completer();
        await _api
            .selectAttachmentsByIds(attachmentIds: [attachment2.id.toString()], maintainSelections: true);
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

        Bundle attachment1 = new Bundle();
        attachment1.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment1.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment1));

        Bundle attachment2 = new Bundle();
        attachment2.annotation
          ..filename = 'very_good_file.pptx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
          ..author = testUsername;
        attachment2.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
        await _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: attachment2));

        expect(_api.currentlySelectedAttachments, isEmpty);

        await _api
            .selectAttachmentsByIds(attachmentIds: [attachment1.id.toString()], maintainSelections: false);
        await completer.future;

        expect(selectEventResult.selectedAttachmentKey, attachment1.id.toString());
        expect(_api.currentlySelectedAttachments, isNotEmpty);
        expect(_api.currentlySelectedAttachments, contains(attachment1.id.toString()));

        completer = new Completer();
        await _api
            .selectAttachmentsByIds(attachmentIds: [attachment2.id.toString()], maintainSelections: false);
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

        Bundle attachment = new Bundle();
        attachment.annotation
          ..filename = 'very_good_file.docx'
          ..filemime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..author = testUsername;
        attachment.selection
          ..key = new Uuid().v4()
          ..resourceId = veryGoodResourceId;
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

      test('hoverOverAttachmentNodes should set a specified BundleTreeNode as hovered', () async {
        String someKey = new Uuid().v4();
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..resourceId = veryGoodResourceId
          ..key = someKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.hoveredNode, isNull);

        AttachmentTreeNode hovered = _store.treeNodes[toAdd.id].first;
        await _attachmentsActions.hoverOverAttachmentNode(new HoverOverNodePayload(hovered: hovered));
        expect(_store.hoveredNode, allOf(isNotNull, new isInstanceOf<AttachmentTreeNode>(), hovered));
        expect(_store.hoveredNode.key, toAdd.id);
      });

      test('hoverOverAttachmentNodes should set a specified GroupTreeNode as hovered', () async {
        String someKey = new Uuid().v4();
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..resourceId = veryGoodResourceId
          ..key = someKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _api.setGroups(groups: [parentGroup]);

        expect(_store.hoveredNode, isNull);

        GroupTreeNode hovered = _store.treeNodes[veryGoodGroup.key].first;
        await _attachmentsActions.hoverOverAttachmentNode(new HoverOverNodePayload(hovered: hovered));
        expect(_store.hoveredNode, allOf(isNotNull, new isInstanceOf<GroupTreeNode>(), hovered));
        expect(_store.hoveredNode.key, veryGoodGroup.key);
      });

      test('hoverOutAttachmentNodes should set a specified AttachmentsTreeNode as not hovered', () async {
        String someKey = new Uuid().v4();
        Bundle toAdd = new Bundle();
        toAdd.annotation
          ..filename = 'very_good_file.docx'
          ..author = testUsername;
        toAdd.selection
          ..resourceId = veryGoodResourceId
          ..key = someKey;
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: veryGoodResourceId,
              selection: new Selection(resourceId: veryGoodResourceId))
        ]);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _api.setGroups(groups: [parentGroup]);

        GroupTreeNode hovered = _store.treeNodes[veryGoodGroup.key].first;
        await _attachmentsActions.hoverOverAttachmentNode(new HoverOverNodePayload(hovered: hovered));
        expect(_store.hoveredNode, allOf(isNotNull, new isInstanceOf<GroupTreeNode>(), hovered));
        expect(_store.hoveredNode.key, veryGoodGroup.key);

        await _attachmentsActions.hoverOutAttachmentNode(new HoverOutNodePayload(unhovered: hovered));
        expect(_store.hoveredNode, isNull);
      });

      test('updateFilename should update the filename appropriately', test_utils.swallowPrints(() async {
        var uuid = new Uuid();

        await _api.getAttachmentsByProducers(producerWurlsToLoad: [uuid.v4().toString().substring(0, 22)]);

        expect(_store.attachments.length > 0, isTrue);
        String keyToUpdate = _store.attachments[0].id;
        String newFilename = 'ThisIsANewFilename.pdf';

        await _api.updateFilename(keyToUpdate: keyToUpdate, newFilename: newFilename);

        verify(_attachmentsService.updateFilename(bundle: any)).called(1);
        expect(_store.attachments[0].annotation.filename, newFilename);
      }));

      test('updateLabel should update the label appropriately', test_utils.swallowPrints(() async {
        var uuid = new Uuid();

        await _api.getAttachmentsByProducers(producerWurlsToLoad: [uuid.v4().toString().substring(0, 22)]);

        expect(_store.attachments.length > 0, isTrue);
        String keyToUpdate = _store.attachments[0].id;
        String newLabel = 'This is a new label';

        await _api.updateLabel(keyToUpdate: keyToUpdate, newLabel: newLabel);

        verify(_attachmentsService.updateLabel(bundle: any)).called(1);
        expect(_store.attachments[0].annotation.label, newLabel);
      }));
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
            primarySelection: new Selection(),
            showFilenameAsLabel: true,
            zipSelection: new Selection());

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: config,
            moduleActions: _moduleActions,
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
        expect(_store.zipSelection, config.zipSelection);
      });

      test('properties are updated when config is updated', () async {
        AttachmentsConfig config = new AttachmentsConfig(
            enableClickToSelect: true,
            enableDraggable: true,
            enableLabelEdit: true,
            enableUploadDropzones: true,
            label: 'Config Label',
            primarySelection: new Selection(),
            showFilenameAsLabel: true,
            zipSelection: new Selection());

        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            moduleConfig: config,
            moduleActions: _moduleActions,
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
        expect(_store.zipSelection, config.zipSelection);

        config = new AttachmentsConfig(
            enableClickToSelect: !config.enableClickToSelect,
            enableDraggable: !config.enableDraggable,
            enableLabelEdit: !config.enableLabelEdit,
            enableUploadDropzones: !config.enableUploadDropzones,
            label: 'Config 2',
            primarySelection: new Selection(),
            showFilenameAsLabel: !config.showFilenameAsLabel,
            zipSelection: new Selection());

        await _store.api.updateAttachmentsConfig(config);

        expect(_store.enableDraggable, config.enableDraggable);
        expect(_store.enableLabelEdit, config.enableLabelEdit);
        expect(_store.enableUploadDropzones, config.enableUploadDropzones);
        expect(_store.enableClickToSelect, config.enableClickToSelect);
        expect(_store.showFilenameAsLabel, config.showFilenameAsLabel);
        expect(_store.label, config.label);
        expect(_store.primarySelection, config.primarySelection);
        expect(_store.zipSelection, config.zipSelection);
      });
    });
  });
}
