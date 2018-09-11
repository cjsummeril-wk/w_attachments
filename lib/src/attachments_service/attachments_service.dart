part of w_attachments_client.service;

class AttachmentsService extends Disposable {
  AppIntelligence _appIntelligence;
  Window serviceWindow = window;
  msg.NatsMessagingClient _msgClient;
//  attachments_service.FAttachmentServiceClient _attachmentsServiceClient;
  ModalManager _modalManager;
  final Logger _logger = new Logger('w_attachments_client.attachments_service');

  StreamController<UploadStatus> _uploadStatusStreamController;
  Stream<UploadStatus> get uploadStatusStream => _uploadStatusStreamController?.stream;

  UploadManager _uploadManager;

  static const analyticLabel = 'wattachments';
  static const appIntelName = 'wattachments';
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

  FContext get context => _msgClient.createFContext();

  AttachmentsService(
      {msg.NatsMessagingClient messagingClient, AppIntelligence appIntelligence, ModalManager modalManager})
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
}
