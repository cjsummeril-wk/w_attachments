part of w_attachments_client.service;

enum UploadSpeed { Snail, Slow, Normal, Fast }

class AttachmentsTestService extends AttachmentsService {
  static const uploadSpeedSetting = 'uploadSpeed';
  static const guaranteeError = 'guaranteeError';
  static const urlFetchError = 'urlFetchError';
  static const postBundleError = 'postBundleError';
  static const putBundleError = 'putBundleError';
  static const purgeCache = 'purgeCache';
  static const fetchAttachmentsError = 'fetchAttachmentsError';
  static const exampleApp = 'exampleApp';
  static const resourcePath = '/api/v0.1/annotation/service/';
  static const maxRetryAttempts = 9;
  static const retryPollingInterval = const Duration(seconds: 1);

  Map _cfg = {
    uploadSpeedSetting: UploadSpeed.Normal,
    guaranteeError: false,
    urlFetchError: false,
    postBundleError: false,
    putBundleError: false,
    fetchAttachmentsError: false,
    purgeCache: false,
    exampleApp: false
  };

  // Cache of anchors keyed by the producerWurl
  Map<String, Anchor> _anchorsCache = {};
  // Cache of attachment usages keyed by their anchor ids
  Map<int, AttachmentUsage> _usagesCache = {};
  // Cache of attachments keyed by their ids
  Map<int, Attachment> _attachmentsCache = {};

  bool _hasEncounteredError = false;
  static const pollingInterval = const Duration(seconds: 1);
  static const maxAttempts = 9;

  AttachmentsTestService({AppIntelligence appIntelligence}) : super(appIntelligence: appIntelligence) {
//    listenToStream(uploadStatusStream, _updateBundleCacheByUpload);
  }

  dynamic getConfigSetting(String settingKey) => _cfg[settingKey];

  void resetTest([Map cfg]) {
    _hasEncounteredError = false;
    if (cfg != null) _cfg = merge(_cfg, cfg);
  }

  ///
  /// Overridden Methods
  ///

  @override
  Future<Null> onDispose() async {
    _attachmentsCache.clear();
    super.onDispose();
  }

  @override
  Future<CreateAttachmentUsageResponse> createAttachmentUsage({@required String producerWurl, int attachmentId}) async {
    Anchor anchor = new Anchor.fromFAnchor(_createFAnchors([producerWurl]).first);
    AttachmentUsage usage = new AttachmentUsage.fromFAttachmentUsage(_createFAttachmentUsages([anchor.id]).first);
    Attachment attachment = _attachmentsCache[usage.attachmentId];
    if (attachmentId != null) {
      attachment = new Attachment.fromFAttachment(_createFAttachments([usage.attachmentId]).first);
    }
    return new CreateAttachmentUsageResponse(anchor: anchor, attachmentUsage: usage, attachment: attachment);
  }

//  @override
//  Future<Iterable<Attachment>> getAttachmentsByIds({@required List<int> idsToLoad}) async {
//    if (_cfg[purgeCache]) {
//      _attachmentsCache.clear();
//    }
//    List<Attachment> attachments = [];
//    List<int> keysForWhichToCreateAttachments = new List.from(idsToLoad);
//
//    for (String id in idsToLoad) {
//      if (_attachmentsCache.keys.contains(id)) {
//        attachments.add(_attachmentsCache[id]);
//        keysForWhichToCreateAttachments.remove(id);
//      }
//    }
//    List<FAttachment> fAttachments = _createFAttachments(keysForWhichToCreateAttachments);
//    for (FAttachment attach in fAttachments) {
//      attachments.add(new Attachment.fromFAttachment(attach));
//    }
//
//    if (_cfg[fetchAttachmentsError] && !_hasEncounteredError) {
//      _hasEncounteredError = true;
//      throw new FAnnotationError();
//    }
//    return new Future.value(attachments);
//  }

  @override
  Future<FGetAttachmentUsagesByIdsResponse> getAttachmentUsagesByIds({@required List<String> usageIdsToLoad}) async {
    List<AttachmentUsage> attachmentUsages = [];
    List<String> keysForWhichToCreateAttachmentUsages = new List.from(idsToLoad);

    for (String id in usageIdsToLoad) {
      if (_usagesCache.keys.contains(id)) {
        attachmentUsages.add(_usagesCache[id]);
        keysForWhichToCreateAttachmentUsages.remove(id);
      }
    }
    List<FAttachmentUsage> fAttachmentUsages = _createFAttachmentUsages(keysForWhichToCreateAttachmentUsages);

    if (_cfg[fetchAttachmentsError] && !_hasEncounteredError) {
      _hasEncounteredError = true;
      throw new FAnnotationError();
    }
    FGetAttachmentUsagesByIdsResponse response = new FGetAttachmentUsagesByIdsResponse()
      ..attachmentUsages = fAttachmentUsages;
    return new Future.value(response);
  }

  @override
  Future<GetAttachmentsByProducersResponse> getAttachmentsByProducers({@required List<String> producerWurls}) async {
    if (_cfg[purgeCache]) {
      _anchorsCache.clear();
      _usagesCache.clear();
      _attachmentsCache.clear();
    }
    List<Anchor> anchors = [];
    List<AttachmentUsage> attachmentUsages = [];
    List<Attachment> attachments = [];

    List<String> keysForWhichToCreateAnchors = new List.from(producerWurls);
    for (String wurl in producerWurls) {
      if (_anchorsCache.keys.contains(wurl)) {
        anchors.add(_anchorsCache[wurl]);
        keysForWhichToCreateAnchors.remove(wurl);
      }
    }
    List<FAnchor> fAnchors = _createFAnchors(keysForWhichToCreateAnchors);
    for (FAnchor anchor in fAnchors) {
      Anchor newAnchor = new Anchor.fromFAnchor(anchor);
      _anchorsCache[anchor.producerWurl] = newAnchor;
      anchors.add(newAnchor);
    }

    List<int> anchorIdsForWhichToCreateUsages = new List.from(anchors.map((Anchor a) => a.id));
    for (final anchorId in anchors.map((Anchor a) => a.id)) {
      if (_usagesCache.keys.contains(anchorId)) {
        attachmentUsages.add(_usagesCache[anchorId]);
        anchorIdsForWhichToCreateUsages.remove(anchorId);
      }
    }
    List<FAttachmentUsage> fAttachmentUsages = _createFAttachmentUsages(anchorIdsForWhichToCreateUsages);
    for (FAttachmentUsage usage in fAttachmentUsages) {
      AttachmentUsage newUsage = new AttachmentUsage.fromFAttachmentUsage(usage);
      _usagesCache[usage.anchorId] = newUsage;
      attachmentUsages.add(newUsage);
    }

    List<int> idsForWhichToCreateAttachments =
        new List.from(attachmentUsages.map((AttachmentUsage usage) => usage.attachmentId));
    for (final id in attachmentUsages.map((AttachmentUsage usage) => usage.attachmentId)) {
      if (_attachmentsCache.keys.contains(id)) {
        attachments.add(_attachmentsCache[id]);
        idsForWhichToCreateAttachments.remove(id);
      }
    }
    List<FAttachment> fAttachments = _createFAttachments(idsForWhichToCreateAttachments);
    for (FAttachment attach in fAttachments) {
      Attachment newAttachment = new Attachment.fromFAttachment(attach);
      attachments.add(newAttachment);
      _attachmentsCache[attach.id] = newAttachment;
    }

    if (_cfg[fetchAttachmentsError] && !_hasEncounteredError) {
      _hasEncounteredError = true;
      throw new FAnnotationError();
    }
    return new Future.value(new GetAttachmentsByProducersResponse(
        attachments: attachments, attachmentUsages: attachmentUsages, anchors: anchors));
  }

  ///
  /// Helper Methods
  ///

  List<FAttachment> _createFAttachments(List<int> ids) {
    final dynamic uuid = new Uuid();
    List<FAttachment> attachments = [];
    for (final id in ids) {
      attachments.add(new FAttachment()
        ..id = id
        ..accountResourceId = 'accountResourceId'
        ..fsResourceId = uuid.v4().toString().substring(0, 22)
        ..fsResourceType = 'fsResourceType'
        ..filename = 'some_sorta_file.docx');
    }
    return attachments;
  }

  List<FAttachmentUsage> _createFAttachmentUsages(List<int> anchorIds) {
    List<FAttachmentUsage> attachmentUsages = [];
    for (final id in anchorIds) {
      attachmentUsages.add(new FAttachmentUsage()
        ..id = (new Random()).nextInt(9847593)
        ..label = 'randomly generated label'
        ..accountResourceId = 'accountResourceId'
        ..anchorId = id
        ..attachmentId = (new Random()).nextInt(9847593));
    }
    return attachmentUsages;
  }

  List<FAnchor> _createFAnchors(List<String> wurls) {
    List<FAnchor> fAnchors = [];
    for (String wurl in wurls) {
      fAnchors.add(new FAnchor()
        ..id = (new Random()).nextInt(9847593)
        ..producerWurl = wurl
        ..accountResourceId = 'accountResourceId'
        ..disconnected = false);
    }
    return fAnchors;
  }

//  _updateBundleCacheByUpload(UploadStatus uploadStatus) {
//    // these are values filled in later, we'll add them here for testing purposes
//    if (uploadStatus.status == Status.Complete) {
//      uploadStatus.attachment.annotation.fsoObjectId = '123';
//      uploadStatus.attachment.annotation.written = true;
//    }
//    _bundlesJsonCache[uploadStatus.attachment.key] = uploadStatus.attachment.getJsonParams();
//  }
}
