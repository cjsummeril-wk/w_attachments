part of w_attachments_client.cef;

class AttachmentsHighlightApi extends HighlightApi {
  final Map<String, AttachmentsHighlight> _highlights = <String, AttachmentsHighlight>{};
  Map<String, AttachmentsHighlight> get highlights => new Map.unmodifiable(_highlights);

  final StreamController<AttachmentsHighlight> _highlightWasAddedController =
      new StreamController<AttachmentsHighlight>.broadcast();

  /// Event that dispatches when any registered [AttachmentsHighlight] is added.
  Stream<AttachmentsHighlight> get highlightWasAdded => _highlightWasAddedController.stream;

  final StreamController<AttachmentsHighlight> _highlightWasRemovedController =
      new StreamController<AttachmentsHighlight>.broadcast();

  /// Event that dispatches when any registered [AttachmentsHighlight] is removed.
  Stream<AttachmentsHighlight> get highlightWasRemoved => _highlightWasRemovedController.stream;

  List<AttachmentsHighlight> get hoveredHighlights =>
      new List.unmodifiable(_highlights.values.where((AttachmentsHighlight ah) => ah.isHovered));

  List<AttachmentsHighlight> get selectedHighlights =>
      new List.unmodifiable(_highlights.values.where((AttachmentsHighlight ah) => ah.isSelected));

  AttachmentsHighlightApi() {
    [_highlightWasAddedController, _highlightWasRemovedController].forEach(manageStreamController);
  }

  /// Return `true` if the receiver API instance "owns" the given
  /// WURI and `false` otherwise.
  ///
  /// This method will be used to determine which API should be relied
  /// upon to handle operations that involve a WURI, such as
  /// creating a new observed region or highlight.
  ///
  /// Consumers must implement their own version of this method on each
  /// API they implement. The easiest way to do this is probably to create
  /// a mix-in that defines this method and pull it into each of the APIs
  /// they implement.
  @override
  bool onCanHandleWuri(String wuri) => true;

  /// Add a highlight to the content indicated by the given WURI.
  ///
  /// This method should be implemented by content providers.
  ///
  /// The [wuri] might refer to a range of content or it might refer
  /// to an observed region. Content providers should be able to
  /// handle either case.
  @override
  AttachmentsHighlight onCreate(
      {@required String key,
      @required String wuri,
      ContextMenuGroupFactory contextMenuGroupFactory,
      HighlightStyles styles,
      String tooltipText}) {
    if (key == null) {
      throw new ArgumentError.notNull('key');
    }
    if (wuri == null) {
      throw new ArgumentError.notNull('wuri');
    }

    removeHighlight(key: key);

    AttachmentsHighlight toAdd = new AttachmentsHighlight(wuri: wuri);
    _highlights[key] = toAdd;
    _highlightWasAddedController.add(toAdd);

    return toAdd;
  }

  void removeHighlight({@required String key}) {
    AttachmentsHighlight toRemove = _highlights[key];
    if (toRemove != null) {
      toRemove.remove();
      _highlightWasRemovedController.add(toRemove);
      _highlights.remove(key);
    }
  }

  void removeAllHighlights() {
    List<String> registeredHighlightKeys = _highlights.keys.toList();
    for (String keyToRemove in registeredHighlightKeys) {
      removeHighlight(key: keyToRemove);
    }
  }

  /// Request that the targeted content be brought into view.
  void goTo({@required String wuri}) {
    // !!! TODO: test jump logic
  }
}
