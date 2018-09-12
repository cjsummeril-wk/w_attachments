library w_attachments_client.test.components.attachments_container_test;

import 'package:over_react_test/over_react_test.dart';
import 'package:test/test.dart';
import 'package:w_session/mock.dart';
import 'package:w_session/w_session.dart';
import 'package:web_skin_dart/ui_components.dart';

import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/w_attachments_service_api.dart';

import '../mocks.dart';

import '../test_utils.dart' as test_utils;

void main() {
  group('AttachmentsContainer /', () {
    AttachmentsModule _module;
    Session _session;
    ExtensionContextMock _extensionContext;
    AttachmentsService _attachmentsService;

    dynamic renderedModule;

    group('with no attachments /', () {
      setUp(() async {
        MockSession.install();

        _session = new Session();
        _extensionContext = new ExtensionContextMock();
        _attachmentsService = new AttachmentsTestService();

        _module = new AttachmentsModule(
            config: new AttachmentsConfig(),
            session: _session,
            extensionContext: _extensionContext,
            attachmentsService: _attachmentsService,
            actionProviderFactory: StandardActionProvider.actionProviderFactory);

        await _module.load();

        renderedModule = render(_module.components.content());
      });

      tearDown(() async {
        await _session.dispose();
        await _extensionContext.dispose();
        await _attachmentsService.dispose();
        await _module.unload();

        MockSession.uninstall();
      });

      test('should render empty view', () {
        test_utils.expectTestIdWasFound(renderedModule, AttachmentsContainerComponent.emptyViewTestId);
      });

      group('should use config for', () {
        EmptyViewComponent emptyViewComponent;

        setUp(() {
          emptyViewComponent = getComponentByTestId(renderedModule, AttachmentsContainerComponent.emptyViewTestId);
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
  });
}
