library w_attachments_client.test.components.attachments_container_test;

import 'package:over_react_test/over_react_test.dart';
import 'package:test/test.dart';
import 'package:web_skin_dart/ui_components.dart';
import 'package:w_session/mock.dart';
import 'package:w_session/w_session.dart';

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/components/components.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_attachments_client/src/test/component_test_ids.dart';
import '../attachment_test_constants.dart';

import '../mocks/mocks_library.dart';
import '../test_utils.dart' as test_utils;

void main() {
  group('AttachmentsContainer /', () {
    AttachmentsModule _module;
    Session _session;
    ExtensionContextMock _extensionContext;
    AnnotationsApiMock _annotationsApiMock;
    MockMessagingClient _msgClient;

    Object attachmentsView;

    group('with no attachments /', () {
      setUp(() async {
        MockSession.install();

        _session = new Session();
        _extensionContext = new ExtensionContextMock();
        _msgClient = new MockMessagingClient();
        _annotationsApiMock = new AnnotationsApiMock();

        _module = new AttachmentsModule(
            config: new AttachmentsConfig(viewModeSetting: ViewModeSettings.Headerless),
            session: _session,
            messagingClient: _msgClient,
            extensionContext: _extensionContext,
            annotationsApi: _annotationsApiMock,
            actionProviderFactory: StandardActionProvider.actionProviderFactory);

        await _module.load();

        attachmentsView = render(_module.components.content());
      });

      tearDown(() async {
        await _session.dispose();
        await _extensionContext.dispose();
        await _annotationsApiMock.dispose();
        await _module.unload();
        await _msgClient.dispose();

        MockSession.uninstall();
      });

      test('should render empty view', () {
        test_utils.expectTestIdWasFound(attachmentsView, ComponentTestIds.attachmentContainer);
        test_utils.expectTestIdWasFound(attachmentsView, AttachmentsContainerComponent.emptyViewTestId);
      });

      group('should use config for', () {
        EmptyViewComponent emptyViewComponent;

        setUp(() {
          emptyViewComponent = getComponentByTestId(attachmentsView, AttachmentsContainerComponent.emptyViewTestId);
          expect(emptyViewComponent, isNotNull);
        });

        test('empty view icon', () {
          expect(emptyViewComponent.props.glyph, _module.store.moduleConfig.emptyViewIcon);
        });

        test('empty view text', () {
          expect(emptyViewComponent.props.header, _module.store.moduleConfig.emptyViewText);
        });
      });
    });

    group('with Reference View /', () {
      setUp(() async {
        MockSession.install();

        _session = new Session();
        _extensionContext = new ExtensionContextMock();
        _msgClient = new MockMessagingClient();
        _annotationsApiMock = new AnnotationsApiMock();

        _module = new AttachmentsModule(
            config: new AttachmentsConfig(viewModeSetting: ViewModeSettings.References),
            session: _session,
            messagingClient: _msgClient,
            extensionContext: _extensionContext,
            annotationsApi: _annotationsApiMock,
            actionProviderFactory: StandardActionProvider.actionProviderFactory);

        await _module.load();

        attachmentsView = render(_module.components.content());
      });

      tearDown(() async {
        await _session.dispose();
        await _extensionContext.dispose();
        await _annotationsApiMock.dispose();
        await _module.unload();
        await _msgClient.dispose();

        MockSession.uninstall();
      });

      test('should render the panel and the Reference View ', () {
        test_utils.expectTestIdWasFound(attachmentsView, ComponentTestIds.attachmentContainer);
        test_utils.expectTestIdWasFound(attachmentsView, ComponentTestIds.referenceView);
      });

      test('should render a list of Attachments within the ReferenceView', () {
        _module.store.attachments = [
          AttachmentTestConstants.mockAttachment,
          AttachmentTestConstants.mockChangedAttachment
        ];
        attachmentsView = render(_module.components.content());

        test_utils.expectTestIdWasFound(attachmentsView, ComponentTestIds.referenceView);
        test_utils.expectTestIdWasFound(attachmentsView, '${ComponentTestIds.rvAttachment}-1');
        test_utils.expectTestIdWasFound(attachmentsView, '${ComponentTestIds.rvAttachment}-2');
      });
    });
  });
}
