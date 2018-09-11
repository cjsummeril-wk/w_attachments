part of w_attachments_client.example.cef;

class ExampleAttachmentsExtensionContext extends ExtensionContext {
  ExampleAttachmentsHighlightApi _highlightApi;
  @override
  ExampleAttachmentsHighlightApi get highlightApi => _highlightApi;

  ExampleAttachmentsObservedRegionApi _observedRegionApi;
  @override
  ExampleAttachmentsObservedRegionApi get observedRegionApi => _observedRegionApi;

  ExampleAttachmentsSelectionApi _selectionApi;
  @override
  ExampleAttachmentsSelectionApi get selectionApi => _selectionApi;

  ExampleAttachmentsExtensionContext() {
    _highlightApi = manageAndReturnDisposable(new ExampleAttachmentsHighlightApi());
    _observedRegionApi = manageAndReturnDisposable(new ExampleAttachmentsObservedRegionApi());
    _selectionApi = manageAndReturnDisposable(new ExampleAttachmentsSelectionApi());
  }
}
