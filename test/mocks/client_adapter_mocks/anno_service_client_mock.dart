part of w_attachments_client.test.client_adapter_mocks;

class _FAnnotationsClientMock extends Mock implements FWAnnotationsServiceClient {}

class FAnnotationsClientMock extends ServiceMockProxy<_FAnnotationsClientMock> implements FWAnnotationsServiceClient {
  FAnnotationsClientMock() : super(new _FAnnotationsClientMock());

  @override
  Future<FGetAttachmentsByIdsResponse> getAttachmentsByIds(FContext ctx, FGetAttachmentsByIdsRequest request) =>
      new Future.value(mock.getAttachmentsByIds(ctx, request));

  static final String mockAccountResourceId = "valid resource id";
  static final int mockAnchorId = 1234;
  static final int mockAttachmentId = 4567;
  static final int mockId = 7890;
  static final String mockLabel = "valid label";
  static final int mockParentId = 9000;

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
