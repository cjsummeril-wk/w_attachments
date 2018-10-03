class ServiceMockProxy<MockT> {
  MockT mock;

  ServiceMockProxy(this.mock);

  @override
  dynamic noSuchMethod(Invocation invocation) => mock.noSuchMethod(invocation);
}
