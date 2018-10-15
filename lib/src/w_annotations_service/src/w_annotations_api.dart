import 'dart:async';
import 'package:meta/meta.dart';
import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:w_common/disposable.dart';

import 'package:messaging_sdk/messaging_sdk.dart' as msg;

import 'package:w_annotations_api/annotations_api_v1.dart';

import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_payloads.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/service_adapters/attachments_service.dart';

class AnnotationsServiceApi extends Disposable {
  AttachmentsService _attachmentService;

  Stream<UploadStatus> get uploadStatusStream => _attachmentService.uploadStatusStream;

  AnnotationsServiceApi(
      {@required msg.NatsMessagingClient messagingClient,
      AppIntelligence appIntelligence,
      FWAnnotationsService fClient: null}) {
    _attachmentService = manageAndReturnDisposable(new AttachmentsService(messagingClient: messagingClient));
  }

  // Attachment Methods
  Future<CreateAttachmentUsageResponse> createAttachmentUsage(
          {@required String producerWurl, int attachmentId}) async =>
      _attachmentService.createAttachmentUsage(producerWurl: producerWurl, attachmentId: attachmentId);

  Future<Iterable<Attachment>> getAttachmentsByIds({@required List<int> idsToLoad, int revisionId}) async =>
      _attachmentService.getAttachmentsByIds(idsToLoad: idsToLoad, revisionId: revisionId);

  Future<Iterable<AttachmentUsage>> getAttachmentUsagesByIds({@required List<int> usageIdsToLoad}) async =>
      _attachmentService.getAttachmentUsagesByIds(usageIdsToLoad: usageIdsToLoad);

  Future<GetAttachmentsByProducersResponse> getAttachmentsByProducers({@required List<String> producerWurls}) async =>
      _attachmentService.getAttachmentsByProducers(producerWurls: producerWurls);

  Future<Null> initialize() async {
    await _attachmentService.initialize();
  }

  @mustCallSuper
  @override
  Future<Null> dispose() async {
    super.dispose();
    await _attachmentService.dispose();
  }
}
