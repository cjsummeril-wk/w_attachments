part of w_attachments_client.test.client_adapter_mocks;

class ServiceMockProxy<MockT> {
  MockT mock;

  ServiceMockProxy(this.mock);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw new NoSuchMethodError(
      this, invocation.memberName, invocation.positionalArguments, invocation.namedArguments);
}
