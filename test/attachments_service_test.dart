library w_attachments_client.test.attachments_service_test;

import 'dart:async';
import 'dart:html' hide Client, Selection;

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/standard_action_provider.dart';

import './mocks.dart';
import './test_utils.dart' as test_utils;

void main() {
  group('AttachmentsService', () {
    AttachmentsStore _store;
    AttachmentsActions _attachmentsActions;
    AttachmentsEvents _attachmentsEvents;
    cef.ExtensionContext _extensionContext;
    AttachmentsService _attachmentsService;

    setUp(() {
      _attachmentsActions = new AttachmentsActions();
      _attachmentsEvents = new AttachmentsEvents();
      _extensionContext = new ExtensionContextMock();
      _attachmentsService = new AttachmentsTestService();
      _store = new AttachmentsStore(
          actionProviderFactory: StandardActionProvider.actionProviderFactory,
          attachmentsActions: _attachmentsActions,
          attachmentsEvents: _attachmentsEvents,
          attachmentsService: _attachmentsService,
          extensionContext: _extensionContext,
          dispatchKey: attachmentsModuleDispatchKey,
          attachments: [],
          groups: []);
    });

    tearDown(() {
      _attachmentsService.dispose();
    });

    test('uploadFilesReturnedBundleHasData', () async {
      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000);

      await _attachmentsService.uploadFiles(selection: selection, files: [mockFile]);
      await new Future.delayed(Duration.ZERO);

      expect(_store.attachments.length, 1);
      Bundle result = _store.attachments[0];
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

      Selection selection = new Selection.fromJson(newSelectionJson);

      await _attachmentsService.uploadFiles(selection: selection, files: [mockFile1, mockFile2, mockFile3]);
      await new Future.delayed(Duration.ZERO);

      expect(_store.attachments.length, 3);
      Bundle result1 = _store.attachments[0];
      expect(result1.annotation.filemime, 'application/pdf');
      expect(result1.annotation.filename, 'test_pdf.pdf');
      expect(result1.annotation.filesize, 10000);

      Bundle result2 = _store.attachments[1];
      expect(result2.annotation.filemime, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      expect(result2.annotation.filename, 'test_spreadsheet.xlsx');
      expect(result2.annotation.filesize, 20000);

      Bundle result3 = _store.attachments[2];
      expect(result3.annotation.filemime, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
      expect(result3.annotation.filename, 'test_document.docx');
      expect(result3.annotation.filesize, 30000);

      // validate all bundles are copied from source, resourceId is just a convenience to that end
      expect(result1.selection.resourceId,
          allOf([equals(result2.selection.resourceId), equals(result3.selection.resourceId)]));
    });

    test('uploadFiles returns empty list when selection is null', () async {
      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000);

      var result = await _attachmentsService.uploadFiles(selection: null, files: [mockFile]);
      await new Future.delayed(Duration.ZERO);

      expect(_store.attachments, isEmpty);
      expect(result, allOf([isNotNull, new isInstanceOf<List>(), isEmpty]));
    });

    test('uploadFiles returns empty list when files list is null', () async {
      Selection selection = new Selection.fromJson(newSelectionJson);

      var result = await _attachmentsService.uploadFiles(selection: selection, files: null);
      await new Future.delayed(Duration.ZERO);

      expect(_store.attachments.length, 0);
      expect(result, allOf([isNotNull, new isInstanceOf<List>(), isEmpty]));
    });

    test('downloadFile', test_utils.swallowPrints(() async {
      // add a file to be downloaded
      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000);
      Selection selection = new Selection.fromJson(newSelectionJson);
      await _attachmentsService.uploadFiles(selection: selection, files: [mockFile]);

      Window mockWindow = spy(new WindowMock(), window);
      _attachmentsService..serviceWindow = mockWindow;

      await _attachmentsService.downloadFile(selection.key);
      verify(mockWindow.open('/test_download.txt', '_blank')).called(1);
    }));

    test('removeFile', () async {
      // add a file to be removed
      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000);
      Selection selection = new Selection.fromJson(newSelectionJson);
      await _attachmentsService.uploadFiles(selection: selection, files: [mockFile]);
      String key = selection.key;

      AttachmentRemovedServicePayload result = await _attachmentsService.removeAttachment(key);
      expect(result.removedSelectionKey, selection.key);
      expect(result.responseStatus, true);
    });

    test('loadAttachments with selection keys', () async {
      var uuid = new Uuid();
      List<String> selectionKeys = [];
      for (int i = 0; i < 12; i++) {
        selectionKeys.add(uuid.v4().toString().substring(0, 22));
      }

      var result = await _attachmentsService.getAttachmentsByProducers(producerWurls: selectionKeys);
      expect(result.length, 12);
    });

    test('loadAttachments with an empty list', () async {
      var result = await _attachmentsService.getAttachmentsByProducers(producerWurls: []);
      expect(result.length, 0);
    });

    test('downloadFilesAsZip', test_utils.swallowPrints(() async {
      // add a file to be downloaded
      File mockFile = new FileMock();
      when(mockFile.type).thenReturn('application/pdf');
      when(mockFile.name).thenReturn('test_attachment.pdf');
      when(mockFile.size).thenReturn(10000);
      Selection selection = new Selection.fromJson(newSelectionJson);
      await _attachmentsService.uploadFiles(selection: selection, files: [mockFile]);

      Window mockWindow = spy(new WindowMock(), window);
      _attachmentsService..serviceWindow = mockWindow;

      await _attachmentsService.downloadFilesAsZip(
          keys: [selection.key],
          zipSelection: new Selection(),
          label: 'hipster label listened to that before it was cool');
      verify(mockWindow.open('/test_download.txt', '_blank')).called(1);
    }));
  });
}
