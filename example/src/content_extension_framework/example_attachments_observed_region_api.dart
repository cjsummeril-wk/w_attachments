part of w_attachments_client.example.cef;

class ExampleAttachmentsObservedRegionApi extends AttachmentsObservedRegionApi {
  Set<ObservedRegion> get regions =>
      new Set<ObservedRegion>.from(new Set<ObservedRegion>.from(getVisibleRegions())..addAll(getOrderedRegions()));

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
  bool onCanHandleWuri(String wuri) => regions.any((ObservedRegion region) => wuri == region?.wuri);

  /// Create a new [ObservedRegion].
  ///
  /// This method should not generally be overridden by content providers.
  /// Implement [onCreate] instead.
  ///
  /// Returns an [ObservedRegion] from the first registered api that answers
  /// to [canHandleWuri].
  ///
  /// Returns `null` if no registered api recognize the wuri.
  ///
  /// [Selection] - A payload describing the range of content to be observed,
  /// obtained from the [SelectionApi].
  @override
  Future<ObservedRegion> create({@required Selection selection}) async {
    // essentially a no-op. but gets rid of the @mustCallSuper warning
    super.create(selection: selection);

    return await onCreate(selection: new AttachmentsSelection(scope: selection.scope, wuri: selection.wuri));
  }

  /// Create an [ObservedRegion] based on the given [selectionWuri].
  ///
  /// If the content provider can't produce an [ObservedRegion] for the given
  /// wuri, it should return `null`.
  ///
  /// [selectionWuri] - a WURI obtained from the [SelectionApi]
  ///
  /// **Important**: if the content provider does not "own" the
  /// provided [Selection], and therefore cannot provide a valid
  /// observed region for it, this method *must* return `null`.
  @override
  Future<ObservedRegion> onCreate({@required Selection selection}) {
    addVisibleRegion(selection?.wuri);
    return new Future.value(getVisibleRegions().last);
  }

  void addVisibleRegion(String wuri) {
    if (wuri?.isNotEmpty == true &&
        getVisibleRegions().firstWhere((ObservedRegion region) => region?.wuri == wuri, orElse: () => null) == null) {
      changeVisibleRegions(
          visibleRegions: new Set.from(getVisibleRegions()..add(new ObservedRegion(scope: wuri, wuri: wuri))));
    }
  }

  void removeVisibleRegion(String wuri) {
    Set<ObservedRegion> regionsToRemove =
        getVisibleRegions().where((ObservedRegion region) => region?.wuri == wuri).toSet();
    if (regionsToRemove.isNotEmpty) {
      changeVisibleRegions(visibleRegions: new Set.from(getVisibleRegions())..removeAll(regionsToRemove));
    }
  }
}
