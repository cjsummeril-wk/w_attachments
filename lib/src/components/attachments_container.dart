part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentsContainerProps> AttachmentsContainer;

@Props()
class AttachmentsContainerProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  ActionProvider actionProvider;
}

class AttachmentsContainerTestIds {
  static final utils.TestIdGenerator _testId = utils.buildTestIdGenerator(
    containerPrefix: 'attachmentsContainer'
  );

  static final String emptyView = _testId('empty-view');
  static final String virtualTree = _testId('virtual-tree-container');
}

@Component()
class AttachmentsContainerComponent
  extends FluxUiComponent<AttachmentsContainerProps>
{
  RegionCollapseComponent _regionCollapse;

  // if any groups have childGroups, render as Tree, else render as regions
  render() => props.store.groups.any((Group group) => group.childGroups?.isNotEmpty == true) ?
    _renderAsVirtualTree() :
    _renderAsRegions();

  _renderAsVirtualTree() => (Dom.div()
    ..className = 'w-attachments attachments-container'
    ..addTestId(AttachmentsContainerTestIds.virtualTree)
  )(
    (w_virtual_components.VirtualTree()
      ..hideRootNode = true
      ..nodeRenderer = attachmentTreeNodeRenderer
      ..root = props.store.rootNode
      ..nodeSize = new w_virtual_components.Size(null, 30)
      ..scrollMultiplier = 1.00
      ..showScrollBars = true
      ..nodeUniqueIdFactory = ((int index, w_virtual_components.TreeNode node) {
        AttachmentsTreeNode attNode = node as AttachmentsTreeNode;
        if (attNode != null) {
          return '${attNode.label}${attNode.label.hashCode}';
        }
        return node.hashCode;
      })
    )()
  );

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
        ..selection = (
          (props.store.showingHeaderlessGroup && props.store.primarySelection != null) ?
            props.store.primarySelection :
            null
        )
        ..key = 'attachments-group-${group.name.hashCode}-${ctr++}'
      )();
    }).toList();

//    return (BlockContent()
//      ..shrink = true
//      ..collapse = BlockCollapse.ALL
//      ..className = 'attachments-container'
//    )(
//      regionContent.isEmpty || (props.store.showingHeaderlessGroup && numAttachmentsDisplayed == 0) ?
//        _renderEmptyView() :
//        regionContent
//    );

    return regionContent.isEmpty || (props.store.showingHeaderlessGroup && numAttachmentsDisplayed == 0) ?
    _renderEmptyView() : (RegionCollapse()
//        ..defaultExpandedTargetKeys = [props.group]
      ..className = 'attachments-container'
      ..ref = ((RegionCollapseComponent ref) => _regionCollapse = ref)
    )(regionContent);
  }

  _renderEmptyView() => (EmptyView()
    ..addTestId(AttachmentsContainerTestIds.emptyView)
    ..glyph = props.store.moduleConfig.emptyViewIcon
    ..header = props.store.moduleConfig.emptyViewText
    ..type = EmptyViewType.VBLOCK
  )();
}
