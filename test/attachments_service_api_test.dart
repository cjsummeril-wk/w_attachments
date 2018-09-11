library w_attachments_client.test.attachments_service_api_test;

import 'dart:async';
import 'dart:html' hide Client, Selection;

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';

import 'package:w_attachments_client/mocks.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/w_attachments_service_api.dart';

import './test_utils.dart' as test_utils;

void main() {
  group('AttachmentsService', () {
    Map newSelectionJson = {
      "annotation_type": null,
      "document_id": "862c202e-9f87-40c7-9ab",
      "draft_replaced_key": null,
      "edge_name": null,
      "is_attached": null,
      "is_draft": null,
      "last_modified": null,
      "offset_x": null,
      "offset_y": null,
      "original_selection_key": null,
      "region_end_offset": null,
      "region_id": "862c202e-9f87-40c7-9ab",
      "region_id_end": null,
      "region_start_offset": null,
      "replaced_by_key": null,
      "resource_id": "862c202e-9f87-40c7-9ab",
      "revision_end": null,
      "revision_start": null,
      "section_id": "862c202e-9f87-40c7-9ab",
      "type": null
    };

    AttachmentsServiceApi _serviceApi;
    AttachmentsService _attachmentsService;
    List<Attachment> testAttachments = [];

    setUp(() async {
      testAttachments.clear();
      _attachmentsService = new AttachmentsTestService();
      _serviceApi = new AttachmentsServiceApiMock.fromService(service: _attachmentsService);
      selection = new Selection.fromJson(newSelectionJson);

      Completer completer = createUploadCompleter(_serviceApi.uploadStatusStream, testAttachments, 1);

      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000);
      await _serviceApi.uploadFiles(selection, [mockFile]);
      await completer.future;
    });

    tearDown(() async {
      for (Bundle attachment in testAttachments) {
        _serviceApi.cancelUpload(uploadToCancel: attachment);
      }
      testAttachments.clear();
      await _serviceApi.dispose();
      await _attachmentsService.dispose();
    });

    test('createBundles should return a list of bundles of length matching numFiles specified', () async {
      List<Bundle> result = await _serviceApi.createBundles(testAttachments.first, 3);

      expect(result.length, 3);
      expect(result.first.selection.resourceId, '862c202e-9f87-40c7-9ab');
      expect(result.last.selection.resourceId, '862c202e-9f87-40c7-9ab');
    });

    test('uploadFilesReturnedBundleHasData', () async {
      // Wait for the uploadStatusStream event to propagate.
      await new Future(() {});

      expect(testAttachments.length, 1);
      Bundle result = testAttachments[0];
      expect(result.id, allOf([isNot(isEmpty), isNotNull]));
      expect(result.annotation.filemime, 'application/pdf');
      expect(result.annotation.filename, 'test_attachment.pdf');
      expect(result.annotation.filesize, 10000);
      expect(result.annotation.attachedDate, allOf([isNot(isEmpty), isNotNull]));
      expect(result.annotation.attachmentId, allOf([isNot(isEmpty), isNotNull]));
      expect(result.annotation.attachorId, 12345);
      expect(result.annotation.creatorId, 12345);
      expect(result.annotation.firstCreated, allOf([isNot(isEmpty), isNotNull]));
      expect(result.annotation.key, allOf([isNot(isEmpty), isNotNull]));
      expect(result.annotation.lastModified, allOf([isNot(isEmpty), isNotNull]));
      expect(result.annotation.lastModifiedBy, 12345);
      expect(result.selection.annotationKey, allOf([isNot(isEmpty), isNotNull]));
      expect(result.selection.key, allOf([isNot(isEmpty), isNotNull]));
      expect(result.selection.lastModified, allOf([isNot(isEmpty), isNotNull]));
    });

    test('uploadMultipleFilesReturnsMultipleBundles', () async {
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
      Bundle result1 = testAttachments.firstWhere((bundle) => bundle.annotation.filename == 'test_pdf.pdf');
      expect(result1.annotation.filemime, 'application/pdf');
      expect(result1.annotation.filesize, 10000);

      Bundle result2 = testAttachments.firstWhere((bundle) => bundle.annotation.filename == 'test_spreadsheet.xlsx');
      expect(result2.annotation.filemime, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      expect(result2.annotation.filesize, 20000);

      Bundle result3 = testAttachments.firstWhere((bundle) => bundle.annotation.filename == 'test_document.docx');
      expect(result3.annotation.filemime, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
      expect(result3.annotation.filesize, 30000);

      // validate all bundles are copied from source, resourceId is just a convenience to that end
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

      Bundle result = testAttachments.firstWhere((bundle) => bundle.annotation.filename == 'test_spreadsheet.xlsx');
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
      Bundle toCancel = testAttachments.firstWhere((bundle) => bundle.uploadStatus != Status.Complete);
      bool cancelResult = await _serviceApi.cancelUpload(uploadToCancel: toCancel);
      await completer.future;

      await new Future.delayed(Duration.ZERO);
      expect(cancelResult, isTrue);
      expect(testAttachments.any((bundle) => bundle.uploadStatus == Status.Cancelled), isTrue);
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

      List<Bundle> toCancel = testAttachments.where((bundle) => bundle.uploadStatus != Status.Complete).toList();
      bool cancelResult = await _serviceApi.cancelUploads(uploadsToCancel: toCancel);
      await completer.future;

      await new Future.delayed(Duration.ZERO);
      expect(cancelResult, isTrue);
      expect(toCancel.every((bundle) => bundle.uploadStatus == Status.Cancelled), isTrue);
      expect(testAttachments.any((bundle) => bundle.uploadStatus == Status.Cancelled), isTrue);
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
      Bundle bundle = testAttachments[0];
      String oldFilename = bundle.annotation.filename;
      String newFilename = 'ThisIsANewFilename.pdf';

      expect(bundle.annotation.filename == newFilename, isFalse);
      expect(oldFilename == newFilename, isFalse);

      bundle.annotation.filename = newFilename;
      await _serviceApi.updateFilename(bundle: bundle);

      expect(bundle.annotation.filename == newFilename, isTrue);
    }));

    test('updateLabel', test_utils.swallowPrints(() async {
      expect(testAttachments.length, 1);
      Bundle bundle = testAttachments[0];
      String oldLabel = bundle.annotation.label;
      String newLabel = 'Do you like my label?';

      expect(bundle.annotation.label == newLabel, isFalse);
      expect(oldLabel == newLabel, isFalse);

      bundle.annotation.label = newLabel;
      await _serviceApi.updateLabel(bundle: bundle);

      expect(bundle.annotation.label == newLabel, isTrue);
    }));
  });
}

Completer createUploadCompleter(Stream stream, List<Bundle> bundleList, int count) {
  StreamSubscription uploadListener;
  Completer completer = new Completer();
  int completeCount = 0;
  uploadListener = stream.listen((UploadStatus uploadStatus) {
    completeCount++;
    Bundle bundle = bundleList.firstWhere((bundle) => bundle.id == uploadStatus.attachment.id, orElse: () => null);
    if (bundle == null || bundle.uploadStatus != Status.Cancelled) {
      bundleList.remove(bundle);
      Bundle toAdd = uploadStatus.attachment;
      toAdd.uploadStatus = uploadStatus.status;
      bundleList.add(toAdd);
    }
    if (!completer.isCompleted && completeCount == count) {
      completer.complete(true);
      uploadListener.cancel();
      uploadListener = null;
    }
  });
  return completer;
}
