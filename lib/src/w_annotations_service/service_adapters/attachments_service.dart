library w_attachments_client.w_annotations_service.attachments;

import 'dart:async';
import 'dart:core';
import 'dart:html' hide Client, Selection;

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:frugal/frugal.dart' as frugal;
import 'package:logging/logging.dart';
import 'package:messaging_sdk/messaging_sdk.dart' as msg;
import 'package:meta/meta.dart';
import 'package:w_annotations_api/annotations_api_v1.dart';
import 'package:w_common/disposable.dart';

import 'package:w_attachments_client/src/components/utils.dart' as component_utils;
import 'package:w_attachments_client/src/tools/upload.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';
import 'package:w_attachments_client/src/w_annotations_service/service_adapters/service_constants.dart';

class AttachmentsService extends Disposable {
  FWAnnotationsServiceClient _fClient;

  Window serviceWindow = window;

  AppIntelligence _appIntelligence;
  msg.NatsMessagingClient _msgClient;
  UploadManager _uploadManager;

  StreamController<UploadStatus> _uploadStatusStreamController;
  Stream<UploadStatus> get uploadStatusStream => _uploadStatusStreamController?.stream;

  final msg.ThriftProtocol _protocol = msg.ThriftProtocol.BINARY;
  frugal.FContext get context => _msgClient.createFContext();
  final Logger _logger = new Logger('w_attachments_client.attachments_service');

  static const analyticLabel = 'w_attachments_client';
  static const appIntelName = 'w_attachments_client';
  static const attachmentSystemType = 'AttachmentSystem';
  static const attachmentType = 'Attachment';
  static const attachments = 'attachments';
  static const canceled = 'canceled';
  static const key = 'key';
  static const maxRetryAttempts = 9;
  static const newTab = '_blank';
  static const newUploadLabel = 'New Attachment';
  static const placeholderLabel = 'Placeholder';
  static const retryPollingInterval = const Duration(seconds: 1);
  static const resourcePath = '/api/v0.1/annotation/service/';
  static const result = 'result';
  static const selectionKeys = 'selection_keys';

  AttachmentsService(
      {@required msg.NatsMessagingClient messagingClient,
      AppIntelligence appIntelligence,
      FWAnnotationsService fClient: null})
      : _uploadStatusStreamController = new StreamController<UploadStatus>.broadcast() {
    _appIntelligence = (appIntelligence != null)
        ? appIntelligence.clone(appIntelName)
        : new AppIntelligence(appIntelName,
            captureStartupTiming: false, captureTotalAppRunningTime: false, withTracing: false, isDebug: true);

    _msgClient = messagingClient;
    _uploadManager = manageAndReturnDisposable(new UploadManager());
    if (fClient != null) {
      _fClient = fClient;
    }
    manageStreamController(_uploadStatusStreamController);
    manageDisposable(_appIntelligence);
  }

  // Middleware for Frugal clients.  Helps us get info from Sumo Logic
  frugal.Middleware get logCorrelationIdMiddleware =>
      (frugal.InvocationHandler next) => (String serviceName, String methodName, List<Object> args) async {
            _logger.info("Starting $serviceName.$methodName(correlation ID: ${(args.first as frugal.FContext)
            .correlationId})");
            try {
              final res = await next(serviceName, methodName, args);
              _logger.info("Finished $serviceName.$methodName(correlation ID: ${(args.first as frugal.FContext)
              .correlationId})");
              return res;
            } catch (e, s) {
              _logger.severe(
                  "Execption raised by $serviceName.$methodName(correlation ID: ${(args.first as frugal.FContext)
                  .correlationId})",
                  e,
                  s);
              rethrow;
            }
          };

  Future<Null> initialize() async {
    // TODO: RAM-732 App Intelligence
    Logger.root.onRecord.listen(_appIntelligence.logging);
    var serviceDescriptor = msg.newServiceDescriptor(
        natsSubject: AnnotationsApiV1Constants.W_ANNOTATIONS_SERVICE, frugalProtocol: _protocol);

    var provider = _msgClient.newClient(serviceDescriptor);

    var _transport = provider.transport;
    await _transport.open();

    getManagedDisposer(() async {
      await _transport?.close();
      _transport = null;
    });

    // Only initialize the client if one has not been provided in the constructor
    _fClient = _fClient == null ? new FWAnnotationsServiceClient(provider, [logCorrelationIdMiddleware]) : _fClient;
  }

  @mustCallSuper
  @override
  Future<Null> onDispose() async {
    serviceWindow = null;
    _uploadStatusStreamController = null;
    super.onDispose();
  }

  Future<CreateAttachmentUsageResponse> createAttachmentUsage({@required String producerWurl, int attachmentId}) async {
    try {
      FCreateAttachmentUsageRequest request = new FCreateAttachmentUsageRequest()..producerWurl = producerWurl;
      if (attachmentId != null) {
        request.attachmentId = attachmentId;
      }
      FCreateAttachmentUsageResponse response = await _fClient.createAttachmentUsage(context, request);
      return new CreateAttachmentUsageResponse(
          attachment: new Attachment.fromFAttachment(response.attachment),
          attachmentUsage: new AttachmentUsage.fromFAttachmentUsage(response.attachmentUsage),
          anchor: new Anchor.fromFAnchor(response.anchor));
    } on FAnnotationError catch (e, stacktrace) {
      _logger.warning('${ServiceConstants.genericAnnoError}', e, stacktrace);
      return null;
    } on Exception catch (e, stacktrace) {
      _logger.severe('${ServiceConstants.transportError}', e, stacktrace);
      rethrow;
    }
  }

  Future<Iterable<Attachment>> getAttachmentsByIds({@required List<int> idsToLoad, int revisionId}) async {
    try {
      List<Attachment> result = [];
      FGetAttachmentsByIdsRequest request = new FGetAttachmentsByIdsRequest()
        ..attachmentIds = idsToLoad
        ..revisionId = revisionId;
      FGetAttachmentsByIdsResponse response = await _fClient.getAttachmentsByIds(context, request);

      for (FAttachment fAttach in response.attachments) {
        Attachment clientAttach = new Attachment.fromFAttachment(fAttach);
        result.add(clientAttach);
      }
      return result;
    } on FAnnotationError catch (annoError) {
      _logger.warning('${ServiceConstants.genericAnnoError}', annoError);
      return null;
    } on Exception catch (e) {
      _logger.severe('${ServiceConstants.transportError}', e);
      rethrow;
    }
  }

  Future<Iterable<AttachmentUsage>> getAttachmentUsagesByIds({@required List<int> usageIdsToLoad}) async {
    try {
      FGetAttachmentUsagesByIdsRequest request = new FGetAttachmentUsagesByIdsRequest()
        ..attachmentUsageIds = usageIdsToLoad;
      FGetAttachmentUsagesByIdsResponse response = await _fClient.getAttachmentUsagesByIds(context, request);

      List<AttachmentUsage> returnAttachmentUsages = [];
      if (response.attachmentUsages?.isNotEmpty == true) {
        response.attachmentUsages.forEach(
            (FAttachmentUsage usage) => returnAttachmentUsages.add(new AttachmentUsage.fromFAttachmentUsage(usage)));
      }
      return returnAttachmentUsages;
    } on FAnnotationError catch (e, stacktrace) {
      _logger.warning('${ServiceConstants.genericAnnoError}', e, stacktrace);
      return null;
    } on Exception catch (e, stacktrace) {
      _logger.severe('${ServiceConstants.transportError}', e, stacktrace);
      rethrow;
    }
  }

  Future<GetAttachmentsByProducersResponse> getAttachmentsByProducers({@required List<String> producerWurls}) async {
    try {
      FGetAttachmentsByProducersRequest request = new FGetAttachmentsByProducersRequest()
        ..producerWurls = producerWurls;
      List<Anchor> returnAnchors = [];
      List<AttachmentUsage> returnAttachmentUsages = [];
      List<Attachment> returnAttachments = [];

      FGetAttachmentsByProducersResponse response = await _fClient.getAttachmentsByProducers(context, request);

      if (response.attachments?.isNotEmpty == true) {
        response.attachments
            .forEach((FAttachment attachment) => returnAttachments.add(new Attachment.fromFAttachment(attachment)));
      }

      if (response.attachmentUsages?.isNotEmpty == true) {
        response.attachmentUsages.forEach((FAttachmentUsage attachmentUsage) =>
            returnAttachmentUsages.add(new AttachmentUsage.fromFAttachmentUsage(attachmentUsage)));
      }

      if (response.anchors?.isNotEmpty == true) {
        response.anchors.forEach((FAnchor anchor) => returnAnchors.add(new Anchor.fromFAnchor(anchor)));
      }

      return new GetAttachmentsByProducersResponse(
          attachments: returnAttachments, attachmentUsages: returnAttachmentUsages, anchors: returnAnchors);
    } on FAnnotationError catch (e, stacktrace) {
      _logger.warning('${ServiceConstants.genericAnnoError}', e, stacktrace);
      return null;
    } on Exception catch (e, stacktrace) {
      _logger.severe('${ServiceConstants.transportError}', e, stacktrace);
      rethrow;
    }
  }

  Future<Attachment> updateAttachmentLabel({@required int attachmentId, @required String newLabel}) async {
    try {
      FUpdateAttachmentLabelRequest request = new FUpdateAttachmentLabelRequest()
        ..attachmentId = attachmentId
        ..label = newLabel;
      FUpdateAttachmentLabelResponse response = await _fClient.updateAttachmentLabel(context, request);

      return new Attachment.fromFAttachment(response?.attachment);
    } on FAnnotationError catch (e, stacktrace) {
      _logger.warning('${ServiceConstants.genericAnnoError}', e, stacktrace);
      return null;
    } on Exception catch (e, stacktrace) {
      _logger.severe('${ServiceConstants.transportError}', e, stacktrace);
      rethrow;
    }
  }

  Future<Iterable<File>> selectFiles({bool allowMultiple: true}) async {
    // Construct the file upload input.
    final fileUploadInput = new FileUploadInputElement()
      ..id = component_utils.UPLOAD_INPUT_CACHE
      ..style.display = 'none'
      ..multiple = allowMultiple;

    var inputCache = querySelector('#${component_utils.UPLOAD_INPUT_CACHE}');
    if (inputCache != null) {
      inputCache.remove();
    }

    var inputCacheContainer = querySelector('#${component_utils.UPLOAD_INPUT_CACHE_CONTAINER}');
    inputCacheContainer.append(fileUploadInput);

    // Listen for the `change` event to grab the list of files.
    final c = new Completer<Iterable<File>>();
    manageCompleter(c);
    listenToStream(fileUploadInput.onChange, (Event e) {
      c.complete(fileUploadInput.files);
      if (inputCache != null) {
        inputCache.remove();
      }
    });

    fileUploadInput.click();
    // Return a Future that will resolve with the list of selected files.
    return c.future;
  }
}
