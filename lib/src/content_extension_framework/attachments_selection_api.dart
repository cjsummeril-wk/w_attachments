part of w_attachments_client.cef;

class AttachmentsSelectionApi extends SelectionApi {
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
  bool onCanHandleWuri(String wuri) => getCurrentSelection()?.wuri == wuri;

  /// Fetch and return the fragments for a particular selection.
  ///
  /// This method should be implemented by content providers.
  ///
  /// **Important**: if the content provider does not "own" the
  /// provided [Selection], and therefore cannot provide valid
  /// fragments for it, this method *must* return `null`.
  @override
  Future<Iterable<Selection>> onGetFragments({@required Selection selection}) async => new Future.value(null);

  void changeCurrentSelection(String regionId) {
    changeSelection(
        selection: ((regionId?.isNotEmpty == true) ? new AttachmentsSelection(scope: regionId, wuri: regionId) : null));
  }
}
