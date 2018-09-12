library w_attachments_client.test.components.utils;

import 'package:test/test.dart';
import 'package:w_attachments_client/src/components/utils.dart' as utils;

void main() {
  group('Components / Utils', () {
    group('buildTestIdGenerator', () {
      test('can build a test id properly', () {
        String containerPrefix = 'container';
        String suffix = 'testThing';
        utils.TestIdGenerator _testId = utils.buildTestIdGenerator(containerPrefix: containerPrefix);

        String emptyView = _testId(suffix);
        expect(emptyView, '${utils.TEST_ID_PREFIX}.${containerPrefix}.${suffix}');
      });
    });
    group('stripExtensionFromFilename', () {
      test('strips the extension as expected on normal filename', () {
        String fileWithoutExtension = 'filename';
        String extension = 'extension';

        expect(utils.stripExtensionFromFilename('${fileWithoutExtension}.${extension}'), fileWithoutExtension);
      });
      test('doesn\'t strip an extension that doesn\'t exist', () {
        String fileWithoutExtension = 'filename';

        expect(utils.stripExtensionFromFilename('${fileWithoutExtension}'), fileWithoutExtension);
      });
      test('can handle null filename', () {
        expect(utils.stripExtensionFromFilename(null), '');
      });
      test('can handle empty filename', () {
        expect(utils.stripExtensionFromFilename(''), '');
      });
    });
    group('getExtensionFromFilename', () {
      test('gets the extension on a normal filename', () {
        String fileWithoutExtension = 'filename';
        String extension = 'extension';

        expect(utils.getExtensionFromFilename('${fileWithoutExtension}.${extension}'), extension);
      });
      test('doesn\'t get the extension that doesn\'t exist', () {
        String fileWithoutExtension = 'filename';

        expect(utils.getExtensionFromFilename('${fileWithoutExtension}'), '');
      });
      test('can handle null filename', () {
        expect(utils.getExtensionFromFilename(null), '');
      });
      test('can handle empty filename', () {
        expect(utils.getExtensionFromFilename(''), '');
      });
    });
    group('fixFilenameExtension', () {
      test('appends the extension if modified', () {
        String oldFileWithoutExtension = 'oldFilename';
        String newFileWithoutExtension = 'newFilename';
        String oldExtension = 'ext';
        String newExtension = 'ex';

        expect(
            utils.fixFilenameExtension(
                '${oldFileWithoutExtension}.${oldExtension}', '${newFileWithoutExtension}.${newExtension}'),
            '${newFileWithoutExtension}.${newExtension}.${oldExtension}');
      });
      test('appends the extension if removed', () {
        String oldFileWithoutExtension = 'oldFilename';
        String newFileWithoutExtension = 'newFilename';
        String extension = 'ext';

        expect(utils.fixFilenameExtension('${oldFileWithoutExtension}.${extension}', '${newFileWithoutExtension}'),
            '${newFileWithoutExtension}.${extension}');
      });
      test('leaves the extension if not changed', () {
        String oldFileWithoutExtension = 'oldFilename';
        String newFileWithoutExtension = 'newFilename';
        String extension = 'ext';

        expect(
            utils.fixFilenameExtension(
                '${oldFileWithoutExtension}.${extension}', '${newFileWithoutExtension}.${extension}'),
            '${newFileWithoutExtension}.${extension}');
      });
      test('appends extension if completely changed', () {
        String oldFileWithoutExtension = 'oldFilename';
        String newFileWithoutExtension = 'newFilename';
        String oldExtension = 'old';
        String newExtension = 'new';

        expect(
            utils.fixFilenameExtension(
                '${oldFileWithoutExtension}.${oldExtension}', '${newFileWithoutExtension}.${newExtension}'),
            '${newFileWithoutExtension}.${newExtension}.${oldExtension}');
      });
      test('can handle no extension', () {
        String oldFileWithoutExtension = 'oldFilename';
        String newFileWithoutExtension = 'newFilename';

        expect(utils.fixFilenameExtension('${oldFileWithoutExtension}', '${newFileWithoutExtension}'),
            '${newFileWithoutExtension}');
      });
      test('can handle . without extension', () {
        String newFileWithoutExtension = 'newFilename';

        expect(utils.fixFilenameExtension('', '${newFileWithoutExtension}.'), '${newFileWithoutExtension}.');
      });
      test('can and an extension on file with no extension', () {
        String oldFileWithoutExtension = 'oldFilename';
        String newFileWithoutExtension = 'newFilename';
        String newExtension = 'ext';

        expect(utils.fixFilenameExtension('${oldFileWithoutExtension}', '${newFileWithoutExtension}.${newExtension}'),
            '${newFileWithoutExtension}.${newExtension}');
      });
      test('can handle null new filename', () {
        String oldFileWithoutExtension = 'oldFilename';
        String oldExtension = 'ext';

        expect(utils.fixFilenameExtension('${oldFileWithoutExtension}.${oldExtension}', null),
            '${oldFileWithoutExtension}.${oldExtension}');
      });
      test('can handle empty new filename', () {
        String oldFileWithoutExtension = 'oldFilename';
        String oldExtension = 'ext';

        expect(utils.fixFilenameExtension('${oldFileWithoutExtension}.${oldExtension}', ''),
            '${oldFileWithoutExtension}.${oldExtension}');
      });
      test('can handle null old filename', () {
        String newFileWithoutExtension = 'newFilename';
        String newExtension = 'ext';

        expect(utils.fixFilenameExtension(null, '${newFileWithoutExtension}.${newExtension}'),
            '${newFileWithoutExtension}.${newExtension}');
      });
      test('can handle empty old filename', () {
        String newFileWithoutExtension = 'newFilename';
        String newExtension = 'ext';

        expect(utils.fixFilenameExtension('', '${newFileWithoutExtension}.${newExtension}'),
            '${newFileWithoutExtension}.${newExtension}');
      });
      test('can handle filename of only the extension', () {
        expect(utils.fixFilenameExtension('something.txt', '.txt'), '');
      });
    });
  });
}
