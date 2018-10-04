part of w_attachments_client.service_api;

/// # AttachmentsServiceApi
/// is a Headless SDK that allows server interaction for attachments without having to load the full attachments module.
///
/// # Client
/// This class requires a messaging client. This is used for the authenticated requests to the server.
///
/// # Upload Status
/// When [uploadFile] is called, all statuses are piped through the [uploadStatusStream], so consumers should be
/// subscribing to that stream in order to receive [uploadStatus] objects.
///     listenToStream(_serviceApi.uploadStatusStream, _addUpdateTestAttachment);
///
/// # To dispose of an AttachmentsServiceApi object:
/// Disposable is used here, so to destroy any invocations, use `dispose()` which terminates the StreamController and
/// closes the client, cancelling or closing any outstanding connections.
class AttachmentsServiceApi extends Disposable {
  AttachmentsService _attachmentsService;

  /// uploadStatusStream can be subscribed to for [uploadStatus],
  /// which contain the bundle being uploaded and the status of that upload.
  Stream<UploadStatus> get uploadStatusStream {
    return _attachmentsService.uploadStatusStream;
  }

  /// Instantiates a new service API with the supplied messagingClient.
  ///
  ///   [messagingClient] is the required [NatsMessagingClient] object to use for frugal calls.
  AttachmentsServiceApi({@required msg.NatsMessagingClient messagingClient, AppIntelligence appIntelligence}) {
    _attachmentsService = manageAndReturnDisposable(
        new AttachmentsService(messagingClient: messagingClient, appIntelligence: appIntelligence));
  }

  /// Constructor for a new service api from an existent service.
  /// This is for use cases with an experience that needs to make direct calls to
  /// the frugal endpoints as well as represent an attachments panel at the same time.
  ///
  ///   [service] is the previously initialized [AttachmentsService]
  AttachmentsServiceApi.fromService({@required AttachmentsService service}) {
    _attachmentsService = service;
  }

  Future<CreateAttachmentUsageResponse> createAttachmentUsage(String producerWurl, int attachmentId) async {
    return _attachmentsService.createAttachmentUsage(producerWurl: producerWurl, attachmentId: attachmentId);
  }

  Future<Iterable<Attachment>> getAttachmentsByIds({@required List<String> idsToLoad}) async {
    return _attachmentsService.getAttachmentsByIds(idsToLoad: idsToLoad);
  }

  Future<FGetAttachmentUsagesByIdsResponse> getAttachmentUsagesByIds({@required List<int> idsToLoad}) async {
    return _attachmentsService.getAttachmentUsagesByIds(usageIdsToLoad: idsToLoad);
  }

  Future<GetAttachmentsByProducersResponse> getAttachmentsByProducers({@required List<String> producerWurls}) async {
    return _attachmentsService.getAttachmentsByProducers(producerWurls: producerWurls);
  }

  /// Uses the browser's file selector to create and return a list of [File]s,
  /// the list gets filled by the [File]s as the Future completes.
  ///
  ///   [allowMultiple] is whether to allow multiple file selections or just one.
  Future<Iterable<File>> selectFiles({bool allowMultiple: true}) =>
      _attachmentsService.selectFiles(allowMultiple: allowMultiple);

  /// Overridden method from w_common.Disposable, closes bigskyClient if it's not already closed.
  @override
  Future<Null> onDispose() async {
    // TODO do we need anything here?
  }
}
