import 'dart:async';
import 'dart:html' hide Selection;

import 'package:over_react/over_react.dart';
import 'package:over_react_test/over_react_test.dart';
import 'package:test/test.dart';
import 'package:truss/truss.dart' show PanelToolbarComponent;
import 'package:web_skin_dart/ui_components.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/components.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_attachments_client/w_attachments_client.dart';

import '../mocks/mocks_library.dart';

void main() {
  group('AttachmentPanelToolbar', () {
    AttachmentsStore _store;
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    ExtensionContextMock _extensionContext;
    AnnotationsApiMock _annotationsApiMock;

    Element mockShellBodyElement;
    TestJacket<AttachmentsPanelToolbarComponent> testJacket;
    var panelToolbarInstance;

    void fetchVariables() {
      expect(testJacket, isNotNull, reason: 'test setup sanity check');

      panelToolbarInstance = getByTestId(testJacket.getInstance(), 'attachment.AttachmentViewComponent.Toolbar');
    }

    void mountAndRenderDefaultToolbar() {
      testJacket = mount((AttachmentsPanelToolbar()
        ..actions = _attachmentsActions
        ..store = _store)());

      fetchVariables();
    }

    sharedChildButtonPropAssertions(ButtonProps props) {
      expect(props.isDisabled, isFalse);
      expect(props.noText, isTrue);
      expect(props.size, ButtonSize.XSMALL);
      expect(props.skin, ButtonSkin.VANILLA);
    }

    setUp(() async {
      _attachmentsActions = new AttachmentsActions();
      _attachmentsEvents = new AttachmentsEvents();
      _extensionContext = new ExtensionContextMock();
      _annotationsApiMock = new AnnotationsApiMock();
      _store = new AttachmentsStore(
          actionProviderFactory: StandardActionProvider.actionProviderFactory,
          attachmentsActions: _attachmentsActions,
          attachmentsEvents: _attachmentsEvents,
          extensionContext: _extensionContext,
          dispatchKey: attachmentsModuleDispatchKey,
          annotationsApi: _annotationsApiMock,
          attachments: [],
          groups: []);

      mockShellBodyElement = new DivElement();
      mockShellBodyElement.className = 'attachments-controls';

      document.body.append(mockShellBodyElement);
    });

    tearDown(() {
      testJacket = null;
      panelToolbarInstance = null;
      mockShellBodyElement.remove();
      mockShellBodyElement = null;
    });

    test('renders', () {
      mountAndRenderDefaultToolbar();

      expect(panelToolbarInstance, isNotNull);
      expect(getDartComponent(panelToolbarInstance), const isInstanceOf<PanelToolbarComponent>());
    });

    test('does not render panelToolbar buttons when there is no file to download', () {
      mountAndRenderDefaultToolbar();

      var buttonProps1 = Button(getPropsByTestId(testJacket.getInstance(), 'wa.AttachmentControls.Icon.ZipAll'));
      var buttonProps2 = Button(getPropsByTestId(testJacket.getInstance(), 'wa.AttachmentControls.Icon.UploadFile'));

      expect(buttonProps1, isEmpty);
      expect(buttonProps2, isEmpty);
    });

    test('renders upload button with correct props', () async {
      // make sure isValidSelection is true
      final testSelection = new cef.Selection(wuri: "selectionWuri", scope: "selectionScope");
      _extensionContext.selectionApi.didChangeSelectionsController.add([testSelection]);

      ContextGroup headerlessGroup = new ContextGroup(name: 'headerlessGroup', displayAsHeaderless: true);
      await _store.api.setGroups(groups: [headerlessGroup]);

      mountAndRenderDefaultToolbar();

      var buttonProps = Button(getPropsByTestId(testJacket.getInstance(), 'wa.AttachmentControls.Icon.UploadFile'));

      expect(buttonProps.aria.label, 'Upload File');
      sharedChildButtonPropAssertions(buttonProps);
    });

    test('renders upload button as disabled ', () async {
      // make sure isValidSelection is true
      final testSelection = new cef.Selection(wuri: "selectionWuri", scope: "selectionScope");
      _extensionContext.selectionApi.didChangeSelectionsController.add([testSelection]);

      ContextGroup headerlessGroup = new ContextGroup(name: 'headerlessGroup', displayAsHeaderless: true);
      await _store.api.setGroups(groups: [headerlessGroup]);

      mountAndRenderDefaultToolbar();

      var buttonProps = Button(getPropsByTestId(testJacket.getInstance(), 'wa.AttachmentControls.Icon.UploadFile'));

      expect(buttonProps.aria.label, 'Upload File');
      expect(buttonProps.isDisabled, false);

      // setting readOnly to true will get new actionsItems.
      // triggering refreshPanelToolbar will trigger a re-render and re-instantiate new actions from the ActionFactory.
      // new actions with read only will be loaded in and rendered in the attachmentsPanel.

      StandardActionProvider.readOnly = true;
      await new Future(() {});
      await _store.api.refreshPanelToolbar();

      mountAndRenderDefaultToolbar();

      var buttonPropsUpdated =
          Button(getPropsByTestId(testJacket.getInstance(), 'wa.AttachmentControls.Icon.UploadFile'));

      expect(buttonPropsUpdated.aria.label, 'Upload File');
      expect(buttonPropsUpdated.isDisabled, true);
    });
  });
}
