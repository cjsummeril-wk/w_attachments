part of w_attachments_client.test.mocks;

class MockFAttachmentsService extends Mock implements FWAnnotationsServiceClient {
  static final String mockAccountResourceId = "valid resource id";
  static final String mockAnchorId = "valid anchor id";
  static final String mockAttachmentId = "valid attachment id";
  static final String mockId = "valid id";
  static final String mockLabel = "valid label";
  static final String mockParentId = "valid parent id";

  static final FAttachmentUsage mockAttachmentUsage = new FAttachmentUsage()
    ..accountResourceId = mockAccountResourceId
    ..anchorId = mockAnchorId
    ..attachmentId = mockAttachmentId
    ..id = mockId
    ..label = mockLabel
    ..parentId = mockParentId;
  static final List<FAttachmentUsage> mockAttachmentUsageList = [mockAttachmentUsage];

  static final FGetAttachmentUsagesByIdsResponse mockValidResponse = new FGetAttachmentUsagesByIdsResponse()
    ..attachmentUsages = mockAttachmentUsageList;
}
