part of w_attachments_client.test.mocks;

class AttachmentsServiceApiMock extends AttachmentsServiceApi {
  AttachmentsService _service;

  AttachmentsServiceApiMock.fromService({@required AttachmentsService service}) : super.fromService(service: service) {
    this._service = service;
  }

  @visibleForTesting
  AttachmentsService get service => _service;
}
