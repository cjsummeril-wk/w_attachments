part of w_attachments_client.test.client_adapter_mocks;

class _FAnnotationsClientMock extends Mock implements FWAnnotationsServiceClient {}

class FAnnotationsClientMock extends ServiceMockProxy<_FAnnotationsClientMock> implements FWAnnotationsServiceClient {
  FAnnotationsClientMock() : super(new _FAnnotationsClientMock());

  @override
  Future<FGetAttachmentsByIdsResponse> getAttachmentsByIds(FContext ctx, FGetAttachmentsByIdsRequest request) =>
      new Future.value(mock.getAttachmentsByIds(ctx, request));

  @override
  Future<FGetAttachmentUsagesByIdsResponse> getAttachmentUsagesByIds(
          FContext ctx, FGetAttachmentUsagesByIdsRequest request) =>
      new Future.value(mock.getAttachmentUsagesByIds(ctx, request));
}
