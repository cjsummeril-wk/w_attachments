import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:over_react_test/over_react_test.dart';
import 'package:test/test.dart';
import 'package:w_flux/w_flux.dart';
import 'package:w_module/w_module.dart';

import 'package:w_attachments_client/src/standard_action_provider.dart';
import 'package:w_attachments_client/w_attachments_client.dart';

import './mocks/mocks_library.dart';

void mockServiceMethod(Function serviceMethod, dynamic returnValue) {
  when(serviceMethod())
      .thenAnswer((_) => (returnValue is Error || returnValue is Exception) ? throw returnValue : returnValue);
}

Completer hookinActionVerifier(Action toVerify) {
  ActionSubscription toVerifySub;
  Completer actionCompleted = new Completer();
  toVerifySub = toVerify.listen((_) {
    if (!actionCompleted.isCompleted) actionCompleted.complete(true);
    toVerifySub?.cancel();
  });
  return actionCompleted;
}

Completer hookinEventVerifier(Event toVerify) {
  StreamSubscription toVerifySub;
  Completer eventCompleted = new Completer();
  toVerifySub = toVerify.listen((_) {
    if (!eventCompleted.isCompleted) eventCompleted.complete(true);

    toVerifySub.cancel();
  });
  return eventCompleted;
}

String getRenderedHtml(dynamic renderedInstance) => findDomNode(renderedInstance).outerHtml;

// overrides calls to print in tests so they don't show up in the unit test suite output.
// this is useful for code that catches and prints exceptions, but we don't want to see it
// adapted from: http://stackoverflow.com/questions/14764323/how-do-i-mock-or-verify-a-call-to-print-in-dart-unit-tests
swallowPrints(testFunc()) => () {
      var spec = new ZoneSpecification(print: (_, __, ___, String msg) {
        // no-op
      });
      return Zone.current.fork(specification: spec).run(testFunc);
    };

Future<AttachmentsModule> loadModule() async {
  AttachmentsModule attachmentsModule = new AttachmentsModule(
      config: new AttachmentsConfig(),
      extensionContext: new ExtensionContextMock(),
      messagingClient: new MockMessagingClient(),
      actionProviderFactory: StandardActionProvider.actionProviderFactory);
  await attachmentsModule.load();

  return attachmentsModule;
}

void expectTestIdWasFound(dynamic rendered, String testId) => expect(getByTestId(rendered, testId), isNotNull);
