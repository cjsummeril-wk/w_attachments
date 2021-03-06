part of w_attachments_client.test.w_annotations_service.mocks;

class _FAnnotationsClientMock extends Mock implements FWAnnotationsServiceClient {}

class FAnnotationsClientMock extends ServiceMockProxy<_FAnnotationsClientMock> implements FWAnnotationsServiceClient {
  FAnnotationsClientMock() : super(new _FAnnotationsClientMock());

  @override
  Future<FCreateAttachmentUsageResponse> createAttachmentUsage(FContext ctx, FCreateAttachmentUsageRequest request) =>
      new Future.value(mock.createAttachmentUsage(ctx, request));

  @override
  Future<FGetAttachmentsByIdsResponse> getAttachmentsByIds(FContext ctx, FGetAttachmentsByIdsRequest request) =>
      new Future.value(mock.getAttachmentsByIds(ctx, request));

  @override
  Future<FGetAttachmentUsagesByIdsResponse> getAttachmentUsagesByIds(
          FContext ctx, FGetAttachmentUsagesByIdsRequest request) =>
      new Future.value(mock.getAttachmentUsagesByIds(ctx, request));

  @override
  Future<FGetAttachmentsByProducersResponse> getAttachmentsByProducers(
          FContext ctx, FGetAttachmentsByProducersRequest request) =>
      new Future.value(mock.getAttachmentsByProducers(ctx, request));

  @override
  Future<FUpdateAttachmentLabelResponse> updateAttachmentLabel(FContext ctx, FUpdateAttachmentLabelRequest request) =>
      new Future.value(mock.updateAttachmentLabel(ctx, request));
}
