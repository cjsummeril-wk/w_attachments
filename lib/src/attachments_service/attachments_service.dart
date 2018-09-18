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

  final msg.ThriftProtocol _protocol = msg.ThriftProtocol.BINARY;
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
      {@required msg.NatsMessagingClient messagingClient, AppIntelligence appIntelligence, ModalManager modalManager})
      : _uploadStatusStreamController = new StreamController<UploadStatus>.broadcast() {
    _appIntelligence = (appIntelligence != null)
        ? appIntelligence.clone(appIntelName)
        : new AppIntelligence(appIntelName,
            captureStartupTiming: false, captureTotalAppRunningTime: false, withTracing: false, isDebug: true);

    _msgClient = messagingClient;
    _uploadManager = manageAndReturnDisposable(new UploadManager());
    _modalManager = modalManager;
    manageStreamController(_uploadStatusStreamController);
    manageDisposable(_appIntelligence);
  }

// // Middleware for Frugal clients.  Helps us get info from Sumo Logic
  frugal.Middleware get logCorrelationIdMiddleware => (frugal.InvocationHandler next) =>
      (String serviceName, String methodName, List<Object> args) async {
        _logger.info("Starting $serviceName.$methodName(correlation ID: ${(args.first as frugal.FContext)
        .correlationId})");
        try {
          final res = await next(serviceName, methodName, args);
          _logger.info("Finished $serviceName.$methodName(correlation ID: ${(args.first as frugal.FContext)
        .correlationId})");
          return res;
        } catch (e) {
          _logger.severe("Execption raised by $serviceName.$methodName(correlation ID: ${(args.first as frugal.FContext)
        .correlationId})");
          rethrow;
        }
      };

  Future<Null> initialize() async {
    var serviceDescriptor = msg.newServiceDescriptor(
        natsSubject: AnnotationsApiV1Constants.W_ANNOTATIONS_SERVICE, frugalProtocol: _protocol);

    var provider = _msgClient.newClient(serviceDescriptor);

    var _transport = provider.transport;
    await _transport.open();

    getManagedDisposer(() async {
      await _transport?.close();
      _transport = null;
    });

    _fClient = new FWAnnotationsServiceClient(provider, [logCorrelationIdMiddleware]);
  }

  @mustCallSuper
  @override
  Future<Null> onDispose() async {
    serviceWindow = null;
    _uploadStatusStreamController = null;
    super.onDispose();
  }

  Future<AttachmentUsageCreatedPayload> createAttachmentUsage(
      {@required String producerWurl, @required String attachmentId}) async {
    return null;
  }

  Future<Iterable<Attachment>> getAttachmentsByIds({@required List<String> idsToLoad}) async {
    return null;
  }

  Future<Iterable<AttachmentUsage>> getAttachmentUsagesByIds({@required List<String> idsToLoad}) async {
    return null;
  }

  Future<AttachmentsByProducersPayload> getAttachmentsByProducers({@required List<String> producerWurls}) async {
    return null;
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

  frugal.FContext _makeFContext(String correlationId) {
    return _msgClient.createFContext(correlationId: correlationId);
  }
}
