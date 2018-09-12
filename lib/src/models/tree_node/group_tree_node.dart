part of w_attachments_client.models.tree_node;

class GroupTreeNode extends AttachmentsTreeNode<Group> {
  IconGlyph customIconGlyph;

  @override
  Group get content => (super.content as Group);

  GroupTreeNode(Group content, ActionProvider actionProvider, AttachmentsStore store, AttachmentsActions actions,
      {bool isCollapsed: false, Iterable<TreeNode> children, Size size})
      : customIconGlyph = content.customIconGlyph,
        super(content, actionProvider, store, actions, isCollapsed: isCollapsed, children: children, size: size);

  @override
  GroupTreeNode get dropTarget {
    if (content is ContextGroup && (content as ContextGroup).uploadSelection != null) {
      return this;
    } else {
      return (parent as GroupTreeNode)?.dropTarget;
    }
  }

  @override
  renderIcon() {
    String ifChildrenClass = (isLeaf && content.attachments?.isEmpty == true) ? "no-children" : "";

    return (BlockContent()
      ..className = 'content-glyph-item ${ifChildrenClass} '
      ..shrink = true)((Icon()
      ..addTestId('wh.CardComponent.HeaderTitle.DocTypeIcon')
      ..colors = IconColors.TWO
      ..glyph = customIconGlyph)());
  }

  @override
  renderRightCap() {
    return (content is ContextGroup && (content as ContextGroup).uploadSelection != null)
        ? (GroupActionRenderer()
          ..actionProvider = actionProvider
          ..group = content
          ..hoveredOn = store.hoveredNode == this
          ..addedClassName = 'node-action-item')()
        : null;
  }
}
