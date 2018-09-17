part of w_attachments_client.test.mocks;

class MockFServiceProvider extends Mock implements frugal.FServiceProvider {
  @override
  frugal.FTransport get transport => mockFTransport;

  /// Middleware applied to clients.
  List<frugal.Middleware> _middleware;

  MockFServiceProvider() {
    _middleware = [];
  }

  @override
  List<frugal.Middleware> get middleware => new List.from(_middleware);
}

class MockFTransport extends Mock implements frugal.FTransport {}

class MockMessagingClient extends Mock implements NatsMessagingClient {
  @override
  frugal.FServiceProvider newClient(ServiceDescriptor serviceDescriptor) => mockFServiceProvider;
}

final frugal.FTransport mockFTransport = new MockFTransport();
final frugal.FServiceProvider mockFServiceProvider = new MockFServiceProvider();
