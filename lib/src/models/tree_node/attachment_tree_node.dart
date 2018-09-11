part of w_attachments_client.models.tree_node;

class AttachmentTreeNode extends AttachmentsTreeNode<Attachment> {
  AttachmentTreeNode(
      Attachment content, ActionProvider actionProvider, AttachmentsStore store, AttachmentsActions actions,
      {bool isCollapsed: false, Size size})
      : super(content, actionProvider, store, actions, isCollapsed: isCollapsed, size: size);

  @override
  String get label => (store.showFilenameAsLabel) ? content.annotation.filename : content.annotation.label;

  /// Children are not allowed for an AttachmentTreeNode.
  @override
  void addChild(TreeNode<dynamic> newChild) {
    return;
  }

  /// Children are not allowed for an AttachmentTreeNode.
  @override
  void addChildren(Iterable<TreeNode<dynamic>> newChildren) {
    return;
  }

  @override
  GroupTreeNode get dropTarget => (parent as AttachmentsTreeNode).dropTarget;

  @override
  renderIcon() {
    String spinnerClassName = (content.uploadStatus == Status.Started || content.uploadStatus == Status.Progress)
        ? 'content-glyph-spinner'
        : '';

    return (BlockContent()
      ..className = '$spinnerClassName content-glyph-item no-children'
      ..shrink = true)((AttachmentIconRenderer()..attachment = content)());
  }

  @override
  renderRightCap() {
    return (AttachmentActionRenderer()
      ..store = store
      ..actions = actions
      ..actionProvider = actionProvider
      ..attachment = content
      ..isHovered = store.hoveredNode == this
      ..isSelected = store.currentlySelected?.contains(key) == true
      ..addedClassName = 'node-action-item node-menu-item')();
  }
}
