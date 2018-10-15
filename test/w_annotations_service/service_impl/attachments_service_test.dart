import '../../attachment_test_constants.dart';
import 'package:mockito/mirrors.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:w_annotations_api/annotations_api_v1.dart';

import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_payloads.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/service_adapters/attachments_service.dart';

import '../../mocks/client_adapter_mocks/client_adapter_mocks_library.dart';
import '../../test_utils.dart' as test_utils;

import '../mocks/mocks_library.dart' show AttachmentsServiceMock;

void main() {
  // Test Constants
  const String f_anno_error_msg_senseless = 'servicedungoofed';
  const String generic_exc_msg = 'verybusinessfriendlyandprofessionalmessage';

  // Mocks
  FAnnotationsClientMock annoServiceClientMock;
  NatsMessagingClientMock natsMsgClientMock;

  // Logging
  // https://github.com/Workiva/app_intelligence_dart/blob/master/documentation/LOGGING.md
  TestReporter testReporter;

  // Test Subject
  AttachmentsService attachmentServiceImpl;

  // Return Values
  FAnnotationError fAnnoErrorSenseless;
  Exception genericException;

  FCreateAttachmentUsageResponse createAttachmentUsageHappyPathResponse;
  FGetAttachmentsByIdsResponse getAttachmentsByIdsHappyPathResponse;
  FGetAttachmentUsagesByIdsResponse getAttachmentUsagesByIdsHappyPathResponse;
  FGetAttachmentsByProducersResponse getAttachmentsByProducersHappyPathResponse;

  group('Attachments Service Impl Tests', () {
    setUp(() {
      // Create Mocks
      annoServiceClientMock = new FAnnotationsClientMock();
      natsMsgClientMock = new NatsMessagingClientMock();

      // Wire up logging
      testReporter = new TestReporter(new Uuid().v4());

      // Create Subject
      attachmentServiceImpl = spy(new AttachmentsServiceMock(),
          new AttachmentsService(messagingClient: natsMsgClientMock, fClient: annoServiceClientMock));

      // Create return values
      fAnnoErrorSenseless = new FAnnotationError()..errorMessage = f_anno_error_msg_senseless;
      genericException = new Exception(generic_exc_msg);

      createAttachmentUsageHappyPathResponse = new FCreateAttachmentUsageResponse()
        ..anchor = AttachmentTestConstants.mockFAnchor
        ..attachmentUsage = AttachmentTestConstants.mockFAttachmentUsage
        ..attachment = AttachmentTestConstants.mockFAttachment;
      getAttachmentsByIdsHappyPathResponse = new FGetAttachmentsByIdsResponse()
        ..attachments = AttachmentTestConstants.mockFAttachmentList;
      getAttachmentUsagesByIdsHappyPathResponse = new FGetAttachmentUsagesByIdsResponse()
        ..attachmentUsages = AttachmentTestConstants.mockFAttachmentUsageList;
      getAttachmentsByProducersHappyPathResponse = new FGetAttachmentsByProducersResponse()
        ..anchors = AttachmentTestConstants.mockFAnchorList
        ..attachmentUsages = AttachmentTestConstants.mockFAttachmentUsageList
        ..attachments = AttachmentTestConstants.mockFAttachmentList;
    });

    group('getAttachmentsByProducersTests', () {
      test('service handler converts frugal to local models and returns', () async {
        // Arrange
        test_utils.mockServiceMethod(() => annoServiceClientMock.mock.getAttachmentsByProducers(any, any),
            getAttachmentsByProducersHappyPathResponse);

        // Act
        GetAttachmentsByProducersResponse results =
            await attachmentServiceImpl.getAttachmentsByProducers(producerWurls: [AttachmentTestConstants.testWurl]);

        // Assert
        expect(results.anchors.length, equals(2));
        expect(results.attachmentUsages.length, equals(2));
        expect(results.attachments.length, equals(2));

        expect(results.anchors.any((Anchor a) => a.id == AttachmentTestConstants.mockAnchor.id), isTrue);
        expect(results.anchors.any((Anchor a) => a.id == AttachmentTestConstants.mockChangedAnchor.id), isTrue);

        expect(
            results.attachmentUsages.any((AttachmentUsage a) =>
                a.id == AttachmentTestConstants.mockAttachmentUsage.id &&
                a.anchorId == AttachmentTestConstants.mockAnchor.id &&
                a.attachmentId == AttachmentTestConstants.mockAttachment.id),
            isTrue);
        expect(
            results.attachmentUsages.any((AttachmentUsage a) =>
                a.id == AttachmentTestConstants.mockChangedAttachmentUsage.id &&
                a.anchorId == AttachmentTestConstants.mockChangedAnchor.id &&
                a.attachmentId == AttachmentTestConstants.mockChangedAttachment.id),
            isTrue);

        expect(results.attachments.any((Attachment a) => a.id == AttachmentTestConstants.mockAttachment.id), isTrue);
        expect(results.attachments.any((Attachment a) => a.id == AttachmentTestConstants.mockChangedAttachment.id),
            isTrue);
      });

      test('service handler handles empty payloads', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentsByProducers(any, any),
            new FGetAttachmentsByProducersResponse()
              ..anchors = null
              ..attachmentUsages = null
              ..attachments = null);

        // Act
        GetAttachmentsByProducersResponse results =
            await attachmentServiceImpl.getAttachmentsByProducers(producerWurls: [AttachmentTestConstants.testWurl]);

        // Assert
        expect(results.anchors.length, equals(0));
        expect(results.attachmentUsages.length, equals(0));
        expect(results.attachments.length, equals(0));
      });

      test('service handler handles FAnnotationError', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentsByProducers(any, any), new FAnnotationError());

        // Act
        GetAttachmentsByProducersResponse results =
            await attachmentServiceImpl.getAttachmentsByProducers(producerWurls: [AttachmentTestConstants.testWurl]);

        // Assert
        expect(results, isNull);
      });

      test('service handler rethrows other exceptions', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentsByProducers(any, any), new Exception());

        // Act
        expect(attachmentServiceImpl.getAttachmentsByProducers(producerWurls: [AttachmentTestConstants.testWurl]),
            throwsA(new isInstanceOf<Exception>()));
      });
    });

    group('createAttachmentUsageTests', () {
      test('service handler converts frugal to local models and returns', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.createAttachmentUsage(any, any), createAttachmentUsageHappyPathResponse);

        // Act
        CreateAttachmentUsageResponse result =
            await attachmentServiceImpl.createAttachmentUsage(producerWurl: AttachmentTestConstants.testWurl);

        // Assert
        verify(annoServiceClientMock.mock.createAttachmentUsage(
            any, new FCreateAttachmentUsageRequest()..producerWurl = AttachmentTestConstants.testWurl));
        expect(result.anchor, new isInstanceOf<Anchor>());
        expect(result.anchor.id, AttachmentTestConstants.anchorIdOne);

        expect(result.attachmentUsage, new isInstanceOf<AttachmentUsage>());
        expect(result.attachmentUsage.id, AttachmentTestConstants.attachmentUsageIdOne);
        expect(result.attachmentUsage.anchorId, AttachmentTestConstants.anchorIdOne);
        expect(result.attachmentUsage.attachmentId, AttachmentTestConstants.attachmentIdOne);

        expect(result.attachment, new isInstanceOf<Attachment>());
        expect(result.attachment.id, AttachmentTestConstants.attachmentIdOne);
      });

      test('service handler converts frugal to local models and returns, using passed-in attachmentId', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.createAttachmentUsage(any, any), createAttachmentUsageHappyPathResponse);

        // Act
        CreateAttachmentUsageResponse result = await attachmentServiceImpl.createAttachmentUsage(
            producerWurl: AttachmentTestConstants.testWurl, attachmentId: AttachmentTestConstants.attachmentIdOne);

        // Assert
        verify(annoServiceClientMock.mock.createAttachmentUsage(
            any,
            new FCreateAttachmentUsageRequest()
              ..producerWurl = AttachmentTestConstants.testWurl
              ..attachmentId = AttachmentTestConstants.attachmentIdOne));
        expect(result.anchor, new isInstanceOf<Anchor>());
        expect(result.anchor.id, AttachmentTestConstants.anchorIdOne);

        expect(result.attachmentUsage, new isInstanceOf<AttachmentUsage>());
        expect(result.attachmentUsage.id, AttachmentTestConstants.attachmentUsageIdOne);
        expect(result.attachmentUsage.anchorId, AttachmentTestConstants.anchorIdOne);
        expect(result.attachmentUsage.attachmentId, AttachmentTestConstants.attachmentIdOne);

        expect(result.attachment, new isInstanceOf<Attachment>());
        expect(result.attachment.id, AttachmentTestConstants.attachmentIdOne);
      });

      test('service handler handles FAnnotationError', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.createAttachmentUsage(any, any), new FAnnotationError());

        // Act
        CreateAttachmentUsageResponse results =
            await attachmentServiceImpl.createAttachmentUsage(producerWurl: AttachmentTestConstants.testWurl);

        // Assert
        expect(results, isNull);
      });

      test('service handler rethrows other exceptions', () async {
        // Arrange
        test_utils.mockServiceMethod(() => annoServiceClientMock.mock.createAttachmentUsage(any, any), new Exception());

        // Act & Assert
        expect(attachmentServiceImpl.createAttachmentUsage(producerWurl: AttachmentTestConstants.testWurl),
            throwsA(new isInstanceOf<Exception>()));
      });
    });

    group('getAttachmentsByIdTests', () {
      test('service handler converts frugal to local models and returns', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentsByIds(any, any), getAttachmentsByIdsHappyPathResponse);

        // Act
        Iterable<Attachment> results = await attachmentServiceImpl.getAttachmentsByIds(
            idsToLoad: [AttachmentTestConstants.attachmentIdOne, AttachmentTestConstants.attachmentIdTwo]);

        // Assert
        expect(results.length, equals(2));
        expect(results.any((Attachment a) => a.id == AttachmentTestConstants.attachmentIdOne), isTrue);
        expect(results.any((Attachment a) => a.id == AttachmentTestConstants.attachmentIdTwo), isTrue);
      });

      test('service handler handles FAnnotationError', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentsByIds(any, any), new FAnnotationError());

        // Act
        Iterable<Attachment> results = await attachmentServiceImpl.getAttachmentsByIds(
            idsToLoad: [AttachmentTestConstants.attachmentIdOne, AttachmentTestConstants.attachmentIdTwo]);

        // Assert
        expect(results, isNull);
      });

      test('service handler rethrows other exceptions', () async {
        // Arrange
        test_utils.mockServiceMethod(() => annoServiceClientMock.mock.getAttachmentsByIds(any, any), new Exception());

        // Act
        expect(
            attachmentServiceImpl.getAttachmentsByIds(
                idsToLoad: [AttachmentTestConstants.attachmentIdOne, AttachmentTestConstants.attachmentIdTwo]),
            throwsA(new isInstanceOf<Exception>()));
      });

      // TODO: RAM-732 App Intelligence
//      test('when there is an FAnnotationError, service logs it as a warning', () async {
//        // Arrange
//        test_utils.mockServiceMethod(() => annoServiceClientMock.mock.getAttachmentsByIds(any, any),
//            fAnnoErrorSenseless);
//
//        // Act
//        await attachmentServiceImpl.getAttachmentsByIds(idsToLoad: [1]);
//
//        // Assert
//        testReporter.reportStream.map((Serializable log) {
//          LogEntry logEntry = log;
//          print('log entry message: ' + logEntry.message);
//          return logEntry;
//        }).firstWhere((LogEntry logEntry) {
//          return logEntry.message == '${ServiceConstants.genericAnnoError}$f_anno_error_msg_senseless';
//        }).then(expectAsync1((LogEntry logEntry) {
//          expect(logEntry.level, LoggingLevel.warning);
//        }, count: 1));
//      });
//
//      test('when there is any non FAnnotationError, service logs it as a severe transport issue', () async {
//        // Arrange
//        test_utils.mockServiceMethod(() => annoServiceClientMock.mock.getAttachmentsByIds(any, any), genericException);
//
//        // Act
//        await attachmentServiceImpl.getAttachmentsByIds(idsToLoad: [1]);
//
//        // Assert
//        testReporter.reportStream.map((Serializable log) {
//          LogEntry logEntry = log;
//          return logEntry;
//        }).firstWhere((LogEntry logEntry) {
//          return logEntry.message == '${ServiceConstants.trasportError}Exception: $generic_exc_msg';
//        }).then(expectAsync1((LogEntry logEntry) {
//          expect(logEntry.level, LoggingLevel.warning);
//        }, count: 1));
//      });
    });

    group('getAttachmentUsagesByIdsTests', () {
      test('should convert FAttachmentUsage to AttachmentUsage in _getAttachmentUsagesByIds', () async {
        // Arrange
        test_utils.mockServiceMethod(() => annoServiceClientMock.mock.getAttachmentUsagesByIds(any, any),
            getAttachmentUsagesByIdsHappyPathResponse);

        // Act
        List<AttachmentUsage> results = await attachmentServiceImpl.getAttachmentUsagesByIds(usageIdsToLoad: [
          AttachmentTestConstants.attachmentUsageIdOne,
          AttachmentTestConstants.attachmentUsageIdTwo
        ]);

        // Assert
        expect(results.length, equals(2));
        expect(
            results.any((AttachmentUsage usage) => usage.id == AttachmentTestConstants.attachmentUsageIdOne), isTrue);
        expect(
            results.any((AttachmentUsage usage) => usage.id == AttachmentTestConstants.attachmentUsageIdTwo), isTrue);
      });

      test(
          'should handle a null return successfully, no attachmentUsage should be returned, in the case that the service returns an error.',
          () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentUsagesByIds(any, any), new FAnnotationError());

        // Act
        List<AttachmentUsage> results = await attachmentServiceImpl.getAttachmentUsagesByIds(usageIdsToLoad: [null]);
        // TODO: RAM-732 App Intelligence
        // add logger expectations and handlers when implemented.

        // Assert
        expect(results, isNull);
      });

      test('service handler rethrows other exceptions', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentUsagesByIds(any, any), new Exception());

        // Act
        expect(
            attachmentServiceImpl.getAttachmentUsagesByIds(usageIdsToLoad: [
              AttachmentTestConstants.attachmentUsageIdOne,
              AttachmentTestConstants.attachmentUsageIdTwo
            ]),
            throwsA(new isInstanceOf<Exception>()));
      });
    });
  });
}
