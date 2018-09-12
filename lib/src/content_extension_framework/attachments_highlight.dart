part of w_attachments_client.cef;

class AttachmentsHighlight extends Highlight {
  final String wuri;

  AttachmentsHighlight({this.wuri});

  /// Handle the removal of a highlight.
  ///
  /// Content providers should override this method in their subclasses.
  @override
  void onRemove() {}

  /// Handle updating a highlight's styles and other metadata.
  ///
  /// Content providers should override this method in their subclasses.
  @override
  void onUpdate(
      {ContextMenuGroupFactory contextMenuGroupFactory, HighlightStyles styles, String tooltipText, String wuri}) {}
}
