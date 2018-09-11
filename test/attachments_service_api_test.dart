library w_attachments_client.test.attachments_service_api_test;

import 'dart:async';
import 'dart:html' hide Client, Selection;

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/w_attachments_service_api.dart';

import './mocks.dart';
import './test_utils.dart' as test_utils;

void main() {
  group('AttachmentsService', () {
//    Map newSelectionJson = {
//      "annotation_type": null,
//      "document_id": "862c202e-9f87-40c7-9ab",
//      "draft_replaced_key": null,
//      "edge_name": null,
//      "is_attached": null,
//      "is_draft": null,
//      "last_modified": null,
//      "offset_x": null,
//      "offset_y": null,
//      "original_selection_key": null,
//      "region_end_offset": null,
//      "region_id": "862c202e-9f87-40c7-9ab",
//      "region_id_end": null,
//      "region_start_offset": null,
//      "replaced_by_key": null,
//      "resource_id": "862c202e-9f87-40c7-9ab",
//      "revision_end": null,
//      "revision_start": null,
//      "section_id": "862c202e-9f87-40c7-9ab",
//      "type": null
//    };

    AttachmentsServiceApi _serviceApi;
    AttachmentsService _attachmentsService;
    List<Attachment> testAttachments = [];
    String selectionWurl = '';

    setUp(() async {
      testAttachments.clear();
      _attachmentsService = new AttachmentsTestService();
      _serviceApi = new AttachmentsServiceApiMock.fromService(service: _attachmentsService);
      selectionWurl = new Selection.fromJson(newSelectionJson);

      Completer completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, 1);

      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000);
      await _serviceApi.getAttachment(selection, [mockFile]);
      await completer.future;
    });

    tearDown(() async {
      for (Attachment attachment in testAttachments) {
        _serviceApi.cancelUpload(uploadToCancel: attachment);
      }
      testAttachments.clear();
      await _serviceApi.dispose();
      await _attachmentsService.dispose();
    });

    test('uploadFilesReturnedAttachmentHasData', () async {
      // Wait for the uploadStatusStream event to propagate.
      await new Future(() {});

      expect(testAttachments.length, 1);
      Attachment result = testAttachments[0];
      expect(result.id, allOf([isNot(isEmpty), isNotNull]));
      expect(result.filemime, 'application/pdf');
      expect(result.filename, 'test_attachment.pdf');
      expect(result.filesize, 10000);
      expect(result.attachedDate, allOf([isNot(isEmpty), isNotNull]));
      expect(result.attachmentId, allOf([isNot(isEmpty), isNotNull]));
      expect(result.attachorId, 12345);
      expect(result.creatorId, 12345);
      expect(result.firstCreated, allOf([isNot(isEmpty), isNotNull]));
      expect(result.id, allOf([isNot(isEmpty), isNotNull]));
      expect(result.lastModified, allOf([isNot(isEmpty), isNotNull]));
      expect(result.lastModifiedBy, 12345);
      expect(result.annotationKey, allOf([isNot(isEmpty), isNotNull]));
      expect(result.lastModified, allOf([isNot(isEmpty), isNotNull]));
    });

    test('uploadMultipleFilesReturnsMultipleAttachments', () async {
      File mockFile1 = new FileMock();
      when(mockFile1.type).thenReturn('application/pdf');
      when(mockFile1.name).thenReturn('test_pdf.pdf');
      when(mockFile1.size).thenReturn(10000);

      File mockFile2 = new FileMock();
      when(mockFile2.type).thenReturn('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      when(mockFile2.name).thenReturn('test_spreadsheet.xlsx');
      when(mockFile2.size).thenReturn(20000);

      File mockFile3 = new FileMock();
      when(mockFile3.type).thenReturn('application/vnd.openxmlformats-officedocument.wordprocessingml.document');
      when(mockFile3.name).thenReturn('test_document.docx');
      when(mockFile3.size).thenReturn(30000);

      List<File> fileUploads = [mockFile1, mockFile2, mockFile3];

      Completer completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, fileUploads.length);

      await _serviceApi.uploadFiles(selection, fileUploads);
      await completer.future;

      expect(testAttachments.length, 4);
      Attachment result1 = testAttachments.firstWhere((testAttachment) => testAttachment.annotation.filename == 'test_pdf.pdf');
      expect(result1.annotation.filemime, 'application/pdf');
      expect(result1.annotation.filesize, 10000);

      Attachment result2 = testAttachments.firstWhere((testAttachment) => testAttachment.annotation.filename == 'test_spreadsheet.xlsx');
      expect(result2.annotation.filemime, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      expect(result2.annotation.filesize, 20000);

      Attachment result3 = testAttachments.firstWhere((testAttachment) => testAttachment.annotation.filename == 'test_document.docx');
      expect(result3.annotation.filemime, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
      expect(result3.annotation.filesize, 30000);

      // validate all testAttachments are copied from source, resourceId is just a convenience to that end
      expect(result1.selection.resourceId,
          allOf([equals(result2.selection.resourceId), equals(result3.selection.resourceId)]));
    });

    test('replaceAttachment', () async {
      File mockFile1 = new FileMock();
      when(mockFile1.type).thenReturn('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      when(mockFile1.name).thenReturn('test_spreadsheet.xlsx');
      when(mockFile1.size).thenReturn(20000);

      Completer completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, 3);

      await _serviceApi.replaceAttachment(toReplace: testAttachments.first, replacementFile: mockFile1);
      await completer.future;

      Attachment result = testAttachments.firstWhere((testAttachment) => testAttachment.annotation.filename == 'test_spreadsheet.xlsx');
      expect(result.annotation.filemime, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      expect(result.annotation.filesize, 20000);
    });

    test('replaceAttachment rethrows error if thrown during replace process', () async {
      File mockFile1 = new FileMock();
      when(mockFile1.type).thenThrow(new StateError('throw StateError to simulate file replace failure'));
      when(mockFile1.name).thenReturn('test_spreadsheet.xlsx');
      when(mockFile1.size).thenReturn(20000);

      Completer completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, 3);
      expect(_serviceApi.replaceAttachment(toReplace: testAttachments.first, replacementFile: mockFile1),
          throwsA(new isInstanceOf<StateError>()));
      await completer.future;
    });

    test('cancelUpload should call an upload task in the thread pool to be cancelled', () async {
      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000000);

      Completer completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, 3);

      await _serviceApi.uploadFiles(selection, [mockFile]);
      Attachment toCancel = testAttachments.firstWhere((testAttachment) => testAttachment.uploadStatus != Status.Complete);
      bool cancelResult = await _serviceApi.cancelUpload(uploadToCancel: toCancel);
      await completer.future;

      await new Future.delayed(Duration.ZERO);
      expect(cancelResult, isTrue);
      expect(testAttachments.any((testAttachment) => testAttachment.uploadStatus == Status.Cancelled), isTrue);
    });

    test('cancelUploads should call a list of upload task in the thread pool to be cancelled', () async {
      Completer completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, 2);

      File mockFile1 = new FileMock();
      when(mockFile1.type).thenReturn('application/pdf');
      when(mockFile1.name).thenReturn('test_attachment1.pdf');
      when(mockFile1.size).thenReturn(10000000);
      await _serviceApi.uploadFiles(selection, [mockFile1]);

      File mockFile2 = new FileMock();
      when(mockFile2.type).thenReturn('application/pdf');
      when(mockFile2.name).thenReturn('test_attachment2.pdf');
      when(mockFile2.size).thenReturn(10000000);
      await _serviceApi.uploadFiles(selection, [mockFile2]);

      File mockFile3 = new FileMock();
      when(mockFile3.type).thenReturn('application/pdf');
      when(mockFile3.name).thenReturn('test_attachment3.pdf');
      when(mockFile3.size).thenReturn(10000000);
      await _serviceApi.uploadFiles(selection, [mockFile3]);

      await completer.future;
      completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, 2);

      List<Attachment> toCancel = testAttachments.where((testAttachment) => testAttachment.uploadStatus != Status.Complete).toList();
      bool cancelResult = await _serviceApi.cancelUploads(uploadsToCancel: toCancel);
      await completer.future;

      await new Future.delayed(Duration.ZERO);
      expect(cancelResult, isTrue);
      expect(toCancel.every((testAttachment) => testAttachment.uploadStatus == Status.Cancelled), isTrue);
      expect(testAttachments.any((testAttachment) => testAttachment.uploadStatus == Status.Cancelled), isTrue);
    });

    test('downloadFile', test_utils.swallowPrints(() async {
      Window mockWindow = spy(new WindowMock(), window);
      (_serviceApi as AttachmentsServiceApiMock).service.serviceWindow = mockWindow;

      await _serviceApi.downloadAttachment(selection.key);
      verify(mockWindow.open('/test_download.txt', '_blank')).called(1);
    }));

    test('getDownloadUrl', test_utils.swallowPrints(() async {
      String result = await _serviceApi.getDownloadUrl(selection.key);
      expect(result, '/test_download.txt');
    }));

    test('getViewerUrl', test_utils.swallowPrints(() async {
      String result = await _serviceApi.getViewerUrl(selection.key);
      expect(result, '/test_download.txt');
    }));

    test('removeFile', () async {
      String key = selection.key;

      AttachmentRemovedServicePayload result = await _serviceApi.removeAttachment(key);
      expect(result.removedSelectionKey, selection.key);
      expect(result.responseStatus, true);
    });

    test('updateFilename', test_utils.swallowPrints(() async {
      expect(testAttachments.length, 1);
      Attachment testAttachment = testAttachments[0];
      String oldFilename = testAttachment.annotation.filename;
      String newFilename = 'ThisIsANewFilename.pdf';

      expect(testAttachment.annotation.filename == newFilename, isFalse);
      expect(oldFilename == newFilename, isFalse);

      testAttachment.annotation.filename = newFilename;
      await _serviceApi.updateFilename(testAttachment: testAttachment);

      expect(testAttachment.annotation.filename == newFilename, isTrue);
    }));

    test('updateLabel', test_utils.swallowPrints(() async {
      expect(testAttachments.length, 1);
      Attachment testAttachment = testAttachments[0];
      String oldLabel = testAttachment.annotation.label;
      String newLabel = 'Do you like my label?';

      expect(testAttachment.annotation.label == newLabel, isFalse);
      expect(oldLabel == newLabel, isFalse);

      testAttachment.annotation.label = newLabel;
      await _serviceApi.updateLabel(testAttachment: testAttachment);

      expect(testAttachment.annotation.label == newLabel, isTrue);
    }));
  });
}

Completer createUploadCompleter(Stream stream, List<Attachment> testAttachmentList, int count) {
  StreamSubscription uploadListener;
  Completer completer = new Completer();
  int completeCount = 0;
  uploadListener = stream.listen((UploadStatus uploadStatus) {
    completeCount++;
    Attachment testAttachment = testAttachmentList.firstWhere((testAttachment) => testAttachment.id == uploadStatus.attachment.id, orElse: () => null);
    if (testAttachment == null || testAttachment.uploadStatus != Status.Cancelled) {
      testAttachmentList.remove(testAttachment);
      Attachment toAdd = uploadStatus.attachment;
      toAdd.uploadStatus = uploadStatus.status;
      testAttachmentList.add(toAdd);
    }
    if (!completer.isCompleted && completeCount == count) {
      completer.complete(true);
      uploadListener.cancel();
      uploadListener = null;
    }
  });
  return completer;
}
