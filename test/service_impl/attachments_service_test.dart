import 'package:frugal/frugal.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:frugal/frugal.dart' show FContext;
import 'package:w_annotations_api/annotations_api_v1.dart';

import 'package:w_attachments_client/src/attachments_service.dart' show AttachmentsService;
import '../mocks/client_adapter_mocks/anno_service_client_mock.dart';
import '../mocks.dart';
import '../test_utils.dart' as test_utils;

void main() {
  // Test Constants
  const String f_anno_error_senseless = 'servicedungoofed';

  // Mocks
  FAnnotationsClientMock annoServiceClientMock;
  AppIntelligenceMock appIntMock;
  NatsMessagingClientMock natsMsgClientMock;

  // Test Subject
  AttachmentsService attachmentServiceImpl;

  // Return Values
  FAnnotationError fAnnoErrorSenseless;

  group('Attachments Service Impl Tests', () {
    setUp(() {
      // Create Mocks
      annoServiceClientMock = new FAnnotationsClientMock();
      appIntMock = new AppIntelligenceMock();
      natsMsgClientMock = new NatsMessagingClientMock();
      when(natsMsgClientMock.createFContext(correlationId: '')).thenReturn(new FContext());

      // Create Subject
      attachmentServiceImpl = new AttachmentsService(
          messagingClient: natsMsgClientMock,
          appIntelligence: appIntMock,
          fClient: annoServiceClientMock
      );

      // Create return values
      fAnnoErrorSenseless = new FAnnotationError();
      fAnnoErrorSenseless.errorMessage = f_anno_error_senseless;
    });

    test('when there is an FAnnotationError, service logs it', () {
      // Arrange
      test_utils.mockServiceMethod(() => annoServiceClientMock.mock.getAttachmentsByIds(any, any),  fAnnoErrorSenseless);

      // Act
      attachmentServiceImpl.getAttachmentsByIds(idsToLoad: [1]);

      // Assert
      verify(appIntMock.logging).called(1);
    });
  });
}
