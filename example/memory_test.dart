import 'dart:async';
import 'dart:html' hide Selection;

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_common/disposable.dart';
import 'package:w_session/mock.dart';
import 'package:w_session/w_session.dart';

import 'package:wdesk_sdk/content_extension_framework_v2.dart' hide Selection;
import 'package:wuri_sdk/wuri_sdk.dart';
import 'src/example_content_extension_framework.dart' as example_cef;
import 'src/sample_reader_permissions_action_provider.dart';

final AppIntelligence _ai = new AppIntelligence('w_attachments_client',
    captureStartupTiming: false, captureTotalAppRunningTime: false, withTracing: false, isDebug: true);
final Uri _sessionHost = Uri.parse('https://wk-dev.wdesk.org');
final Session session = new Session(sessionHost: _sessionHost);

void _createAndDisposeSubject() {
  const String exampleApp = 'exampleApp';
  Uuid uuid = new Uuid();

  final AttachmentsService attachmentsService = new AttachmentsTestService(appIntelligence: _ai)
    ..resetTest({exampleApp: true});
  final ExtensionContext extensionContext = new example_cef.ExampleAttachmentsExtensionContext();
  final Segment spreadsheetId = new Segment('spreadsheet', uuid.v4().substring(0, 22));
  final Segment sectionId = new Segment('section', uuid.v4().substring(0, 22));
  final String primarySelection =
      new Wurl('annotations', 0, [spreadsheetId, sectionId, new Segment('selection', uuid.v4().substring(0, 22))])
          .toString();

  final AttachmentsModule attachments = new AttachmentsModule(
      actionProviderFactory: SampleReaderPermissionsActionProvider.actionProviderFactory,
      config: new AttachmentsConfig(
        label: 'Memory_Test',
        primarySelection: primarySelection,
      ),
      session: session,
      extensionContext: extensionContext,
      attachmentsService: attachmentsService)
    ..load();

  attachmentsService.dispose();
  extensionContext.dispose();

  attachments.unload();
}

Future<Null> main() async {
  Disposable.enableDebugMode();

  MockSession.install();
  MockSession.sessionHost = _sessionHost;

  Stream<LogRecord> loggerStream = Logger.root.onRecord.asBroadcastStream();
  loggerStream.listen(new DebugConsoleHandler());
  loggerStream.listen(_ai.logging);

  querySelector('#createAndDispose').onClick.listen((_) {
    _createAndDisposeSubject();
  });
}
