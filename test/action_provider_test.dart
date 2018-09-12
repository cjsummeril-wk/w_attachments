library w_attachments_client.test.action_provider_test;

import 'package:meta/meta.dart';
import 'package:mockito/mirrors.dart';
import 'package:over_react_test/over_react_test.dart';
import 'package:test/test.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;
import 'package:web_skin_dart/ui_components.dart';

import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

import './mocks.dart';

void main() {
  group('ActionProvider', () {
//    StandardActionProvider _actionProvider;
//    AttachmentsStore _store;
//    AttachmentsActions _attachmentsActions;
//    AttachmentsEvents _attachmentsEvents;
//    cef.ExtensionContext _extensionContext;
//    AttachmentsService _attachmentsService;
//    ContextGroup _testGroup;
//    Attachment _testAttachment;
//
//    AttachmentsStore _createStore({@required List<ContextGroup> groups}) => spy(
//        new AttachmentsStoreMock(),
//        new AttachmentsStore(
//            actionProviderFactory: StandardActionProvider.actionProviderFactory,
//            moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'),
//            attachmentsActions: _attachmentsActions,
//            attachmentsEvents: _attachmentsEvents,
//            attachmentsService: _attachmentsService,
//            extensionContext: _extensionContext,
//            dispatchKey: attachmentsModuleDispatchKey,
//            attachments: [_testAttachment],
//            groups: groups ?? <ContextGroup>[]));
//
//    setUp(() {
//      _testGroup = new ContextGroup(name: 'hipster group', displayAsHeaderless: true);
//      _testAttachment = new Attachment();
//      _attachmentsActions = new AttachmentsActions();
//      _attachmentsEvents = new AttachmentsEvents();
//      _extensionContext = new ExtensionContextMock();
//      _attachmentsService = new AttachmentsTestService();
//      _store = _createStore(groups: [_testGroup]);
//      _actionProvider = _store.actionProvider;
//    });
//
//    tearDown(() {
//      _attachmentsService.dispose();
//    });
//
//    test('should provide Panel Menu actionItems, in headless mode', () {
//      List<ActionItem> result = _actionProvider.getPanelActions();
//      expect(result.length, 2);
//
//      expect((getDartComponent(render(result[0].icon)).props as IconProps).glyph, IconGlyph.FOLDER_ZIP_G2);
//      expect(result[0].callbackFunction, isNotNull);
//      expect((getDartComponent(render(result[1].icon)).props as IconProps).glyph, IconGlyph.UPLOADED);
//      expect(result[1].callbackFunction, isNotNull);
//    });
//
//    test('should provide Panel Menu actionItems, displaying groups', () {
//      // need to establish a new store so that it makes a new actionProvider
//      _store =
//          _createStore(groups: [new ContextGroup(name: 'the first one'), new ContextGroup(name: 'the second one')]);
//      List<ActionItem> result = _actionProvider.getPanelActions();
//      expect(result.length, 2);
//
//      expect((getDartComponent(render(result[0].icon)).props as IconProps).glyph, IconGlyph.FOLDER_ZIP_G2);
//      expect(result[0].callbackFunction, isNotNull);
//    });
//
//    test('should provide Group Header actionItems', () {
//      List<ActionItem> result = _actionProvider.getGroupActions(_testGroup);
//      expect(result.length, 1);
//
//      expect((getDartComponent(render(result[0].icon)).props as IconProps).glyph, IconGlyph.UPLOADED);
//      expect(result[0].callbackFunction, isNotNull);
//    });
//
//    test('should provide three Attachment Header actionItems for completed uploads', () {
//      _testAttachment.uploadStatus = Status.Complete;
//      List<ActionItem> result = _actionProvider.getAttachmentActions(_testAttachment);
//      expect(result.length, 3);
//
//      expect((getDartComponent(render(result[0].icon)).props as IconProps).glyph, IconGlyph.DOWNLOADED);
//      expect(result[0].callbackFunction, isNotNull);
//      expect((getDartComponent(render(result[1].icon)).props as IconProps).glyph, IconGlyph.TRASH);
//      expect(result[1].callbackFunction, isNotNull);
//    });
//
//    test('should provide two Attachment Header actionItem for failed upload', () {
//      _testAttachment.uploadStatus = Status.Failed;
//      List<ActionItem> result = _actionProvider.getAttachmentActions(_testAttachment);
//      expect(result.length, 2);
//
//      expect((getDartComponent(render(result[0].icon)).props as IconProps).glyph, IconGlyph.TRASH);
//      expect(result[0].callbackFunction, isNotNull);
//    });
//
//    test('should have proper default state', () {
//      String state = 'default';
//      List<StatefulActionItem> result = _actionProvider.getPanelActions();
//      expect(result.length, 2);
//
//      result[0].itemState = state;
//      expect(result[0].currentStateName, state);
//      expect((getDartComponent(render(result[0].currentStateView)).props as IconProps).glyph, IconGlyph.FOLDER_ZIP_G2);
//      expect(result[0].callbackFunction, isNotNull);
//    });
//
//    test('should have proper progress state', () {
//      String state = 'progress';
//      List<StatefulActionItem> result = _actionProvider.getPanelActions();
//      expect(result.length, 2);
//
//      result[0].itemState = state;
//      expect(result[0].currentStateName, state);
//      expect(result[0].callbackFunction, isNotNull);
//    });
  });
}
