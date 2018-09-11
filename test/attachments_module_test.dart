library w_attachments_client.test.attachments_module_test;

import 'package:test/test.dart';
import 'package:w_attachments_client/mocks.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_session/mock.dart';
import 'package:w_session/w_session.dart';

void main() {
  group('AttachmentsModule', () {
    AttachmentsModule _module;
    ExtensionContextMock _extensionContext;
    AttachmentsService _attachmentsService;
    Session _session;

    setUp(() async {
      // mock out the session.

      final sessionHost = Uri.parse('https://wk-dev.wdesk.org');
      MockSession.install();
      MockSession.sessionHost = sessionHost;

      _session = new Session(sessionHost: sessionHost);
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
          attachmentsService: _attachmentsService,
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
