library tool.dev;

import 'package:dart_dev/dart_dev.dart' show dev, config;
import 'package:dart_dev/src/tasks/gen_test_runner/config.dart';

main(List<String> args) async {
  // https://github.com/Workiva/dart_dev

  // Perform task configuration here as necessary.

  // Available task configurations:
  config.analyze
    ..entryPoints = ['lib/', 'test/generated_runner_test.dart', 'tool/']
    ..strong = true;
  // config.copyLicense
  config.coverage..pubServe = true;
  // config.docs
  config.examples;
  config.format
    ..paths = ['example/', 'lib/', 'test/', 'tool/']
    ..exclude = ['test/generated_runner_test.dart']
    ..lineLength = 120;
  config.test
    ..platforms = ['dartium']
    ..unitTests = ['test/generated_runner_test.dart']
    ..pubServe = true;

  config.genTestRunner.configs = [new UnitTestRunnerConfig()];

  await dev(args);
}

class UnitTestRunnerConfig extends TestRunnerConfig {
  UnitTestRunnerConfig() {
    genHtml = true;
    env = Environment.browser;
    filename = 'generated_runner_test';
    dartHeaders = [
      "import 'package:react/react_client.dart' as react_client;",
      "import 'package:web_skin_dart/ui_core.dart';",
      "import 'package:w_transport/mock.dart';"
    ];
    preTestCommands = ["react_client.setClientConfiguration();", "enableTestMode();", "configureWTransportForTest();"];
    htmlHeaders = [
      '<script src="packages/react/react_with_addons.js"></script>',
      '<script src="packages/react/react_dom.js"></script>',
    ];
  }
}
