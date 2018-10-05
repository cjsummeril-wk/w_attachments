import 'package:mockito/mirrors.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:w_annotations_api/annotations_api_v1.dart';

import 'package:w_attachments_client/src/models.dart';
import 'package:w_attachments_client/src/service_adapters/attachments_service_library.dart';

import '../mocks/client_adapter_mocks/client_adapter_mocks_library.dart';
import '../mocks/mocks_library.dart' show AttachmentsServiceMock;
import '../test_utils.dart' as test_utils;

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
  FGetAttachmentsByIdsResponse getAttachmentsByIdsHappyPathResponse;
  FGetAttachmentUsagesByIdsResponse getAttachmentUsagesByIdsHappyPathResponse;

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

      List<FAttachment> happyPathAttachments = [
        new FAttachment()..id = 1,
        new FAttachment()..id = 2,
      ];

      List<FAttachmentUsage> happyPathAttachmentUsages = [
        new FAttachmentUsage()..id = 1234,
        new FAttachmentUsage()..id = 4567,
      ];
      getAttachmentsByIdsHappyPathResponse = new FGetAttachmentsByIdsResponse()..attachments = happyPathAttachments;
      getAttachmentUsagesByIdsHappyPathResponse = new FGetAttachmentUsagesByIdsResponse()
        ..attachmentUsages = happyPathAttachmentUsages;
    });

    group('getAttachmentsByIdTests', () {
      test('(happy path) service handler converts frugal to local models and returns', () async {
        // Arrange
        test_utils.mockServiceMethod(
            () => annoServiceClientMock.mock.getAttachmentsByIds(any, any), getAttachmentsByIdsHappyPathResponse);

        // Act
        Iterable<Attachment> results = await attachmentServiceImpl.getAttachmentsByIds(idsToLoad: [1, 2]);

        // Assert
        expect(results.length, equals(2));
        expect(results.any((Attachment attch) => attch.id == 1), isTrue);
        expect(results.any((Attachment attch) => attch.id == 2), isTrue);
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
      test('(happy path) should convert FAttachmentUsage to AttachmentUsage in _getAttachmentUsagesByIds', () async {
        // Arrange
        test_utils.mockServiceMethod(() => annoServiceClientMock.mock.getAttachmentUsagesByIds(any, any),
            getAttachmentUsagesByIdsHappyPathResponse);

        // Act
        List<AttachmentUsage> results =
            await attachmentServiceImpl.getAttachmentUsagesByIds(usageIdsToLoad: [1234, 4567]);

        // Assert
        expect(results.length, equals(2));
        expect(results.any((AttachmentUsage usage) => usage.id == 1234), isTrue);
        expect(results.any((AttachmentUsage usage) => usage.id == 4567), isTrue);
      });
    });
  });
}
