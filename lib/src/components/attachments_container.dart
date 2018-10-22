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

  @override
  render() => (Block()
    ..className = 'w_attachments_client'
    ..addTestId(ComponentTestIds.attachmentContainer))(_renderAttachmentsView());

  ReactElement _renderAttachmentsView() {
    if (props.store.attachments.isNotEmpty) {
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
          return _renderEmptyView();
      }
    } else {
      return _renderEmptyView();
    }
  }

  ReactElement _renderReferenceView() {
    List<ReactElement> attachmentsToRender = props.store.attachments.map((Attachment attachment) {
      int count = props.store.attachments.indexOf(attachment) + 1;
      return (AttachmentRegion()
        ..addTestId('${ReferenceViewTestIds.rvAttachmentComponent}-${count}')
        ..key = attachment.id
        ..attachment = attachment
        ..currentSelection = props.store.currentSelection
        ..references = props.store.usagesOfAttachment(attachment)
        ..actions = props.actions
        ..store = props.store
        ..attachmentCounter = count
        ..targetKey = attachment.id)();
    }).toList();

    // for now, sort the region by key (attachment.id). Resolves a bug where
    // an added reference to an AttachmentRegion would re-render the view and re-order the attachments.
    attachmentsToRender.sort((a, b) => a.key.compareTo(b.key));

    return (RegionCollapse()
      ..revealHeaderActionsOnHover = true
      ..className = 'reference-view__region-container'
      ..addTestId(ReferenceViewTestIds.referenceView)
      ..defaultExpandedTargetKeys = [])(attachmentsToRender);
  }

  ReactElement _renderAsRegions() {
    int ctr = 0;
    int numAttachmentsDisplayed = 0;
    var regionContent = props.store.groups.map((Group group) {
      numAttachmentsDisplayed += group.attachments.length;
      return (GroupPanel()
        ..addTestId(test_id.GroupPanelIds.groupPanelId)
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

  ReactElement _renderEmptyView() => (EmptyView()
    ..addTestId(ComponentTestIds.emptyView)
    ..glyph = props.store.moduleConfig.emptyViewIcon
    ..header = props.store.moduleConfig.emptyViewText
    ..type = EmptyViewType.VBLOCK)();
}
