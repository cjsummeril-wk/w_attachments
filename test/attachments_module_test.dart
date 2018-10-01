library w_attachments_client.test.attachments_module_test;

import 'package:test/test.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_session/mock.dart';
import 'package:w_session/w_session.dart';

import './mocks.dart';

void main() {
  group('AttachmentsModule', () {
    AttachmentsModule _module;
    ExtensionContextMock _extensionContext;
    MockMessagingClient _msgClient;
    Session _session;

    setUp(() async {
      // mock out the session.

      final sessionHost = Uri.parse('https://wk-dev.wdesk.org');
      MockSession.install();
      MockSession.sessionHost = sessionHost;

      _session = new Session(sessionHost: sessionHost);
      _msgClient = new MockMessagingClient();
      _extensionContext = new ExtensionContextMock();
    });

    tearDown(() async {
      if (_module?.isLoaded == true) {
        await _module.unload();
      }
    });

    test('should be present when constructed', () async {
      _module = new AttachmentsModule(
          config: new AttachmentsConfig(),
          session: _session,
          extensionContext: _extensionContext,
          messagingClient: _msgClient,
          actionProviderFactory: StandardActionProvider.actionProviderFactory);
      await _module.load();

      expect(_module, isNotNull);
      expect(_module.api, isNotNull);
      expect(_module.components, isNotNull);
      expect(_module.store, isNotNull);
      expect(_module.events, isNotNull);
    });
  });
}
