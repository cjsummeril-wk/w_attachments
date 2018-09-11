import 'package:web_skin_dart/ui_components.dart';

class FileMimeType {
  static Map _mimeTypesByDocType = new Map.unmodifiable({
    'word': {
      'icon': IconGlyph.FILE_MSWORD_G2,
      'mimeTypes': [
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-word.document.macroenabled.12',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
        'application/vnd.ms-word.template.macroenabled.12'
      ]
    },
    'excel': {
      'icon': IconGlyph.FILE_EXCEL_G2,
      'mimeTypes': [
        'application/excel',
        'application/vnd.ms-excel',
        'application/vnd.msexcel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-excel.sheet.macroenabled.12',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
        'application/vnd.ms-excel.sheet.binary.macroenabled.12',
        'application/vnd.ms-excel.template.macroenabled.12',
        'application/vnd.ms-excel.addin.macroenabled.12'
      ]
    },
    'powerpoint': {
      'icon': IconGlyph.FILE_MSPOWERPOINT_G2,
      'mimeTypes': [
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'application/vnd.ms-powerpoint.presentation.macroenabled.12',
        'application/vnd.openxmlformats-officedocument.presentationml.template',
        'application/vnd.ms-powerpoint.template.macroenabled.12',
        'application/vnd.ms-powerpoint.addin.macroenabled.12',
        'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
        'application/vnd.ms-powerpoint.slideshow.macroenabled.12',
        'application/vnd.openxmlformats-officedocument.presentationml.slide',
        'application/vnd.ms-powerpoint.slide.macroenabled.12'
      ]
    },
    'pdf': {
      'icon': IconGlyph.FILE_PDF_G2,
      'mimeTypes': ['application/pdf']
    },
    'image': {
      'icon': IconGlyph.FILE_IMAGE_G2,
      'mimeTypes': [
        'image/tiff',
        'image/gif',
        'image/jpeg',
        'image/x-citrix-jpeg',
        'image/pipeg',
        'image/jp2',
        'image/jpx',
        'image/png',
        'image/x-citrix-png',
        'image/x-png'
      ]
    },
    'csv': {
      'icon': IconGlyph.FILE_CSV_G2,
      'mimeTypes': [
        'text/comma-separated-values',
        'text/x-comma-separated-values',
        'text/csv',
        'text/x-csv',
        'application/csv',
        'application/x-csv',
        'text/anytext'
      ]
    },
    // rtf and txt share an icon so are combined as a mime type category
    'rtf-txt': {
      'icon': IconGlyph.FILE_TXT_RTF_G2,
      'mimeTypes': [
        // rtf mimeTypes
        'application/rtf',
        'application/x-rtf',
        'text/rtf',
        'application/rtf',
        'text/richtext',
        // txt mimeTypes
        'application/plain',
        'text/plain'
      ]
    }
  });

  /// IconByMimeType takes each categorical doc type from [_mimeTypesByDocType] and maps
  /// the [IconGlyph] to each mimeType string. Like so:
  ///
  ///     {
  ///       'application/msword': IconGlyph.FILE_MSWORD_G2,
  ///       'application/vnd.openxmlformats-officedocument.wordprocessingml.document': IconGlyph.FILE_MSWORD_G2,
  ///       'application/vnd.ms-word.document.macroenabled.12': IconGlyph.FILE_MSWORD_G2,
  ///       'application/vnd.ms-excel': IconGlyph.FILE_EXCEL_G2,
  ///       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': IconGlyph.FILE_EXCEL_G2,
  ///       'application/vnd.ms-excel.sheet.macroenabled.12': IconGlyph.FILE_EXCEL_G2,
  ///        etc.
  ///     }
  static Map<String, IconGlyph> IconByMimeType = new Map.unmodifiable(_mimeTypesByDocType.values.fold(
      new Map<String, IconGlyph>(),
      (Map result, Map mimeTypeInfo) => result
        ..addAll(mimeTypeInfo['mimeTypes'].fold(new Map<String, IconGlyph>(), (Map result, String mimeType) {
          result[mimeType] = mimeTypeInfo['icon'];
          return result;
        }))));
}
