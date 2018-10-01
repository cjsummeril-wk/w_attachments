part of w_attachments_client.service;

class AttachmentsService extends Disposable {
  FWAnnotationsServiceClient _fClient;

  Window serviceWindow = window;

  AppIntelligence _appIntelligence;
  msg.NatsMessagingClient _msgClient;
  ModalManager _modalManager;
  UploadManager _uploadManager;

  StreamController<UploadStatus> _uploadStatusStreamController;
  Stream<UploadStatus> get uploadStatusStream => _uploadStatusStreamController?.stream;

  frugal.FContext get requestContext => _msgClient.createFContext()..timeout = new Duration(seconds: 30);

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
      ModalManager modalManager,
      FWAnnotationsService fClient: null})
      : _uploadStatusStreamController = new StreamController<UploadStatus>.broadcast() {
    _appIntelligence = (appIntelligence != null)
        ? appIntelligence.clone(appIntelName)
        : new AppIntelligence(appIntelName,
            captureStartupTiming: false, captureTotalAppRunningTime: false, withTracing: false, isDebug: true);

    _msgClient = messagingClient;
    _uploadManager = manageAndReturnDisposable(new UploadManager());
    _modalManager = modalManager;
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

  // TODO RAM-668 clean this up to work properly, catch FAnnotationError, etc.
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
      _logger.warning(e, stacktrace);
      rethrow;
    } catch (e, stacktrace) {
      _logger.severe(e, stacktrace);
      rethrow;
    }
  }

  Future<Iterable<Attachment>> getAttachmentsByIds({@required List<int> idsToLoad, int revisionId}) async {
    List<Attachment> result;
    FGetAttachmentsByIdsResponse response;
    try {
      FGetAttachmentsByIdsRequest request = new FGetAttachmentsByIdsRequest()
        ..attachmentIds = idsToLoad
        ..revisionId = revisionId;
      response = await _fClient.getAttachmentsByIds(context, request);

      result = [];
      for (FAttachment fAttach in response.attachments) {
        Attachment clientAttach = new Attachment.fromFAttachment(fAttach);
        result.add(clientAttach);
      }
    } on FAnnotationError catch (annoError) {
      _logger.warning('${ServiceConstants.genericAnnoError}', annoError);
    } on Exception catch (e) {
      _logger.severe('${ServiceConstants.transportError}', e);
    }

    return result;
  }

  Future<FGetAttachmentUsagesByIdsResponse> getAttachmentUsagesByIds({@required List<String> usageIdsToLoad}) async {
    /*
    try {
      FGetAttachmentUsagesByIdsRequest request = new FGetAttachmentUsagesByIdsRequest()
        ..attachmentUsageIds = usageIdsToLoad;
      FGetAttachmentUsagesByIdsResponse response = await _fClient.getAttachmentUsagesByIds(requestContext, request);
      return response;
    } catch (e) {
      _logger.warning(e);
    }
    */
    return null;
  }

  // TODO RAM-667 clean this up to work properly and all that, however it needs to be
  Future<GetAttachmentsByProducersResponse> getAttachmentsByProducers({@required List<String> producerWurls}) async {
    FGetAttachmentsByProducersRequest request = new FGetAttachmentsByProducersRequest()..producerWurls = producerWurls;
    try {
      FGetAttachmentsByProducersResponse response = await _fClient.getAttachmentsByProducers(context, request);
      List<Attachment> returnAttachments = [];
      if (response.attachments?.isNotEmpty == true) {
        response.attachments
            .forEach((FAttachment attachment) => returnAttachments.add(new Attachment.fromFAttachment(attachment)));
      }
      List<AttachmentUsage> returnAttachmentUsages = [];
      if (response.attachmentUsages?.isNotEmpty == true) {
        response.attachmentUsages.forEach((FAttachmentUsage attachmentUsage) =>
            returnAttachmentUsages.add(new AttachmentUsage.fromFAttachmentUsage(attachmentUsage)));
      }
      List<Anchor> returnAnchors = [];
      if (response.anchors?.isNotEmpty == true) {
        response.anchors.forEach((FAnchor anchor) => returnAnchors.add(new Anchor.fromFAnchor(anchor)));
      }
      return new GetAttachmentsByProducersResponse(
          attachments: returnAttachments, attachmentUsages: returnAttachmentUsages, anchors: returnAnchors);
    } on FAnnotationError catch (e, stacktrace) {
      _logger.warning(e, stacktrace);
      rethrow;
    } catch (e, stacktrace) {
      _logger.severe(e, stacktrace);
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
