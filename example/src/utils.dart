import 'package:uuid/uuid.dart';

int uniqueRecordId = 0;
int nextRecordId() => uniqueRecordId++;

final String ExampleDocumentId = new Uuid().v4();

const List<String> ExampleSupportedMimeTypes = const [
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-excel.sheet.macroenabled.12',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
  'application/vnd.ms-excel.sheet.binary.macroenabled.12',
  'application/vnd.ms-excel.template.macroenabled.12',
  'application/vnd.ms-excel.addin.macroenabled.12'
];
