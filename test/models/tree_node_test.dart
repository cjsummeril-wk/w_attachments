library w_attachments_client.test.models.tree_node;

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/action_payloads.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

import '../mocks.dart';

void main() {
  group('TreeNode', () {
    AttachmentsStore _store;
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    cef.ExtensionContext _extensionContext;
    AttachmentsService _attachmentsService;
    String validWurl = 'wurl://docs.v1/doc:962DD25A85142FBBD7AC5AC84BAE9BD6';

    group('Group Tree Node', () {
      setUp(() async {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = new AttachmentsTestService();
        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

        Attachment toAdd = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = 'Ron Swanson';
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
          name: 'veryGoodGroup',
          pivots: [
            new GroupPivot(
              type: GroupPivotType.RESOURCE,
              id: 'very_good_resource_id',
//                  selection: new Selection(resourceId: 'very_good_resource_id')
            )
          ],
//            uploadSelection: new Selection(resourceId: 'very_good_resource_id')
        );

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _store.api.setGroups(groups: [parentGroup]);
      });

      tearDown(() {
        _attachmentsActions.dispose();
        _attachmentsEvents.dispose();
        _extensionContext.dispose();
        _attachmentsService.dispose();
        _store.dispose();
      });

//      test('should have non-null actionProvider, actions, and store', () {
//        GroupTreeNode testGroupNode = _store.rootNode.children.toList()[0].children.toList()[0];
//        expect(testGroupNode.actionProvider, isNotNull);
//        expect(testGroupNode.actionProvider, new isInstanceOf<ActionProvider>());
//        expect(testGroupNode.actions, isNotNull);
//        expect(testGroupNode.actions, new isInstanceOf<AttachmentsActions>());
//        expect(testGroupNode.store, isNotNull);
//        expect(testGroupNode.store, new isInstanceOf<AttachmentsStore>());
//      });

//      test('should have non-null renderRightCap result', () {
//        GroupTreeNode testGroupNode = _store.rootNode.children.toList()[0].children.toList()[0];
//        expect(testGroupNode.renderRightCap(), isNotNull);
//      });

//      test('should set self as dropTarget when content contains a valid uploadSelection', () {
//        GroupTreeNode testGroupNode = _store.rootNode.children.toList().first.children.toList().first;
//        expect(testGroupNode.dropTarget, testGroupNode);
//      });

//      test('should have valid dropTarget when a parent node contains a valid uploadSelection', () async {
//        PredicateGroup childGroupWithNoSelection =
//            new PredicateGroup(name: 'childGroupWithNoSelection', predicate: ((Attachment attachment) => true));
//
//        ContextGroup groupWithSelection = new ContextGroup(
//          name: 'groupWithSelection',
//          pivots: [
//            new GroupPivot(
//              type: GroupPivotType.RESOURCE,
//              id: 'very_good_resource_id',
//              selection: validWurl
//            )
//          ],
//          childGroups: [childGroupWithNoSelection],
//          uploadSelection: validWurl
//        );
//
//        await _store.api.setGroups(groups: [groupWithSelection]);
//
//        GroupTreeNode testGroupNode = _store.rootNode.children.toList().first.children.toList().first;
//        GroupTreeNode dropTargetGroupNode = _store.rootNode.children.toList().first;
//        expect(testGroupNode.dropTarget, dropTargetGroupNode);
//      });

//      test('should have null dropTarget when no parent node containing a valid uploadSelection exists', () async {
//        PredicateGroup childGroupWithNoSelection =
//            new PredicateGroup(name: 'childGroupWithNoSelection', predicate: ((Attachment attachment) => true));
//
//        ContextGroup groupWithNoSelection =
//            new ContextGroup(name: 'groupWithNoSelection', childGroups: [childGroupWithNoSelection]);
//
//        await _store.api.setGroups(groups: [groupWithNoSelection]);
//
//        GroupTreeNode testGroupNode = _store.rootNode.children.toList().first.children.toList().first;
//        expect(testGroupNode.dropTarget, isNull);
//      });

//      test('should have null dropTarget when no parent node exists', () async {
//        PredicateGroup childGroupWithNoSelection =
//            new PredicateGroup(name: 'childGroupWithNoSelection', predicate: ((Attachment attachment) => true));
//
//        ContextGroup groupWithNoSelection =
//            new ContextGroup(name: 'groupWithNoSelection', childGroups: [childGroupWithNoSelection]);
//
//        await _store.api.setGroups(groups: [groupWithNoSelection]);
//
//        GroupTreeNode testGroupNode = _store.rootNode.children.toList().first;
//        expect(testGroupNode.dropTarget, isNull);
//      });
    });

    group('Attachment Tree Node', () {
      setUp(() async {
        _attachmentsActions = new AttachmentsActions();
        _attachmentsEvents = new AttachmentsEvents();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = new AttachmentsTestService();
        _store = new AttachmentsStore(
            actionProviderFactory: StandardActionProvider.actionProviderFactory,
            attachmentsActions: _attachmentsActions,
            attachmentsEvents: _attachmentsEvents,
            attachmentsService: _attachmentsService,
            extensionContext: _extensionContext,
            dispatchKey: attachmentsModuleDispatchKey,
            attachments: [],
            groups: []);

        Attachment toAdd = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = 'Ron Swanson';
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        ContextGroup veryGoodGroup = new ContextGroup(
            name: 'veryGoodGroup',
            pivots: [new GroupPivot(type: GroupPivotType.RESOURCE, id: 'very_good_resource_id', selection: validWurl)],
            uploadSelection: validWurl);

        ContextGroup parentGroup = new ContextGroup(name: 'parentGroup', childGroups: [veryGoodGroup]);
        await _store.api.setGroups(groups: [parentGroup]);
      });

      tearDown(() {
        _attachmentsActions.dispose();
        _attachmentsEvents.dispose();
        _extensionContext.dispose();
        _attachmentsService.dispose();
        _store.dispose();
      });

//      test('should have non-null actionProvider, actions, and store', () {
//        AttachmentTreeNode testBundleNode =
//            _store.rootNode.children.toList()[0].children.toList()[0].children.toList()[0];
//        expect(testBundleNode.actionProvider, isNotNull);
//        expect(testBundleNode.actionProvider, new isInstanceOf<ActionProvider>());
//        expect(testBundleNode.actions, isNotNull);
//        expect(testBundleNode.actions, new isInstanceOf<AttachmentsActions>());
//        expect(testBundleNode.store, isNotNull);
//        expect(testBundleNode.store, new isInstanceOf<AttachmentsStore>());
//      });
//
//      test('should have non-null renderRightCap result', () {
//        AttachmentTreeNode testBundleNode =
//            _store.rootNode.children.toList()[0].children.toList()[0].children.toList()[0];
//        expect(testBundleNode.renderRightCap(), isNotNull);
//      });
//
//      test('should have valid GroupTreeNode as dropTarget when a parent node contains a valid uploadSelection', () {
//        AttachmentTreeNode testBundleNode =
//            _store.rootNode.children.toList().first.children.toList().first.children.toList().first;
//        GroupTreeNode testGroupNode = _store.rootNode.children.toList().first.children.toList().first;
//        expect(testBundleNode.dropTarget, testGroupNode);
//      });

      test('should have null GroupTreeNode as dropTarget when a parent node does not contain a valid uploadSelection',
          () async {
        Attachment toAdd = new Attachment()
          ..filename = 'very_good_file.docx'
          ..id = 1
          ..userName = 'Ron Swanson';
        _attachmentsActions.addAttachment(new AddAttachmentPayload(toAdd: toAdd));

        PredicateGroup childGroupWithNoSelection =
            new PredicateGroup(name: 'childGroupWithNoSelection', predicate: ((Attachment attachment) => true));

        ContextGroup groupWithNoSelection =
            new ContextGroup(name: 'groupWithNoSelection', childGroups: [childGroupWithNoSelection]);

        await _store.api.setGroups(groups: [groupWithNoSelection]);

        AttachmentTreeNode testBundleNode =
            _store.rootNode.children.toList().first.children.toList().first.children.toList().first;
        expect(testBundleNode.dropTarget, isNull);
      });
    });
  });
}
