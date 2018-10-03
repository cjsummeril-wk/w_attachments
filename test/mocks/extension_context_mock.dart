part of w_attachments_client.test.mocks;

class ExtensionContextMock extends Mock implements cef.ExtensionContext {
  MockObservedRegionApi _observedRegionApi;
  MockSelectionApi _selectionApi;
  MockHighlightApi _highlightApi;
  @override
  MockObservedRegionApi get observedRegionApi => _observedRegionApi;
  @override
  MockSelectionApi get selectionApi => _selectionApi;
  @override
  MockHighlightApi get highlightApi => _highlightApi;
  ExtensionContextMock() {
    _observedRegionApi = new MockObservedRegionApi();
    _selectionApi = new MockSelectionApi();
    _highlightApi = new MockHighlightApi();
  }
}

class MockObservedRegionApi extends Mock implements cef.ObservedRegionApi {
  final didChangeScopesController = new StreamController<Null>();
  @override
  Stream<Null> get didChangeScopes => didChangeScopesController.stream;
  @override
  Future<Null> onDispose() async {
    didChangeScopesController.close();
  }
}

class MockSelectionApi extends Mock implements cef.SelectionApi {
  final didChangeSelectionsController = new StreamController<List<cef.Selection>>();
  @override
  Stream<List<cef.Selection>> get didChangeSelections => didChangeSelectionsController.stream;
  @override
  Future<Null> onDispose() async {
    didChangeSelectionsController.close();
  }
}

class MockHighlightApi extends Mock implements cef.HighlightApi {}
