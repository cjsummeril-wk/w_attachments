part of w_attachments_client.test.mocks;

class MockFAttachmentsService extends Mock implements FWAnnotationsServiceClient {
  static final String mockAccountResourceId = "valid resource id";
  static final String mockLabel = "valid label";
  static final int mockAnchorId = 1234;
  static final int mockAttachmentId = 3456;
  static final int mockId = 5678;
  static final int mockParentId = 7890;

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
