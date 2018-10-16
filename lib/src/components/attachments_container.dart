part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentsContainerProps> AttachmentsContainer;

@Props()
class AttachmentsContainerProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  ActionProvider actionProvider;
}

@Component()
class AttachmentsContainerComponent extends FluxUiComponent<AttachmentsContainerProps> {
  RegionCollapseComponent _regionCollapse;

  static final utils.TestIdGenerator _testId = utils.buildTestIdGenerator(containerPrefix: 'attachmentsContainer');

  static final String emptyViewTestId = _testId('empty-view');

  // if any groups have childGroups, render as Tree, else render as regions
  @override
  render() => (Dom.div()
    ..className = 'w_attachments_client'
    ..addTestId('w_attachments_client'))(_renderAttachmentsView());

  _renderAttachmentsView() {
    switch (props.store.moduleConfig.viewModeSetting) {
      case ViewModeSettings.References:
        return _renderReferenceView();

        break;
      case ViewModeSettings.Groups:
        return _renderAsRegions();

        break;
      case ViewModeSettings.Headerless:
        return _renderAsRegions();

        break;
      default:
        return null;
    }
  }

  _renderReferenceView() {
    List<ReactElement> attachmentsToRender = props.store.attachments.map((Attachment attachment) {
      return (AttachmentRegion()
        ..addProps(copyUnconsumedProps())
        ..key = attachment.id
        ..attachment = attachment
        ..actions = props.actions
        ..store = props.store
        ..targetKey = attachment.id)();
    }).toList();

    return (RegionCollapse()
      ..className = 'reference-view__region-container'
      ..addTestId('reference-view__region-container')
      ..defaultExpandedTargetKeys = []
      ..onRegionSelect = _handleAttachmentRegionSelect)(attachmentsToRender);
  }

  bool _handleAttachmentRegionSelect(SyntheticEvent event, Object selectedRegionTargetKey) {
    Attachment expandAttachmentRegion = props.store.attachments
        .firstWhere((Attachment attachment) => attachment.id == selectedRegionTargetKey, orElse: () => null);
    if (expandAttachmentRegion != null) {}
    return true;
  }

  _renderAsRegions() {
    int ctr = 0;
    int numAttachmentsDisplayed = 0;
    var regionContent = props.store.groups.map((Group group) {
      numAttachmentsDisplayed += group.attachments.length;
      return (GroupPanel()
        ..key = group.key
        ..actions = props.actions
        ..actionProvider = props.actionProvider
        ..store = props.store
        ..group = group
        ..selection = ((props.store.showingHeaderlessGroup && props.store.primarySelection != null)
            ? props.store.primarySelection
            : null)
        ..key = 'attachments-group-${group.name.hashCode}-${ctr++}')();
    }).toList();

//    return (BlockContent()
//      ..shrink = true
//      ..collapse = BlockCollapse.ALL
//    )(
//      regionContent.isEmpty || (props.store.showingHeaderlessGroup && numAttachmentsDisplayed == 0) ?
//        _renderEmptyView() :
//        regionContent
//    );

    return regionContent.isEmpty || (props.store.showingHeaderlessGroup && numAttachmentsDisplayed == 0)
        ? _renderEmptyView()
        : (RegionCollapse()
//        ..defaultExpandedTargetKeys = [props.group]
          ..ref = ((RegionCollapseComponent ref) => _regionCollapse = ref))(regionContent);
  }

  _renderEmptyView() => (EmptyView()
    ..addTestId(emptyViewTestId)
    ..glyph = props.store.moduleConfig.emptyViewIcon
    ..header = props.store.moduleConfig.emptyViewText
    ..type = EmptyViewType.VBLOCK)();
}
