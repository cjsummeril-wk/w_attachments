const String UPLOAD_INPUT_CACHE_CONTAINER = 'w_attachments_client-upload-input-cache-container';
const String UPLOAD_INPUT_CACHE = 'w_attachments_client-upload-input-cache';

const String TEST_ID_PREFIX = 'w_attachments_client';

typedef String TestIdGenerator(String);

TestIdGenerator buildTestIdGenerator({String containerPrefix}) =>
    ((String suffix) => '$TEST_ID_PREFIX.$containerPrefix.$suffix');

String stripExtensionFromFilename(String filename) {
  String retval = filename ?? '';
  if (retval.isEmpty == false) {
    List<String> parts = retval.split('.');
    if (parts.length > 1) {
      retval = parts.take(parts.length - 1).join('.');
    }
  }
  return retval;
}

String getExtensionFromFilename(String filename) {
  String retval = filename ?? '';
  if (retval.isEmpty == false) {
    List<String> parts = retval.split('.');
    if (parts.length > 1) {
      retval = parts.last;
    } else {
      retval = '';
    }
  }
  return retval;
}

String fixFilenameExtension(String oldFilename, String newFilename) {
  String filename = (newFilename != null && newFilename.isNotEmpty) ? newFilename : oldFilename;
  filename ??= '';
  String ext = '.${getExtensionFromFilename(oldFilename)}';
  if (ext != '.' && filename.endsWith(ext) == false) {
    filename += ext;
  }
  if (filename == ext) {
    filename = '';
  }
  return filename;
}
