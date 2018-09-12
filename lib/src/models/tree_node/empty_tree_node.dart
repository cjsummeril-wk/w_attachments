part of w_attachments_client.models.tree_node;

class EmptyTreeNode extends AttachmentsTreeNode<Null> {
  EmptyTreeNode(AttachmentsStore store, AttachmentsActions actions, {bool isCollapsed: false, Size size})
      : super(null, null, store, actions, isCollapsed: isCollapsed, size: size);

  @override
  String get label => 'No Attachments Found';

  /// Children are not allowed
  @override
  void addChild(TreeNode<dynamic> newChild) {
    return;
  }

  /// Children are not allowed
  @override
  void addChildren(Iterable<TreeNode<dynamic>> newChildren) {
    return;
  }

  @override
  GroupTreeNode get dropTarget => (parent as AttachmentsTreeNode).dropTarget;

  @override
  renderIcon() => (BlockContent()
    ..className = 'content-glyph-item no-children'
    ..shrink = true)(AttachmentIconRenderer()());

  @override
  renderRightCap() => null;
}
