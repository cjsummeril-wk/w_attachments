part of w_attachments_client.models.tree_node;

abstract class AttachmentsTreeNode<T> extends TreeNode<dynamic> {
  bool isDragTarget = false;
  bool isInDropzone = false;
  int dropzoneRefCounter = 0;
  ActionProvider _actionProvider;
  AttachmentsStore _store;
  AttachmentsActions _actions;

  AttachmentsTreeNode(dynamic content, this._actionProvider, this._store, this._actions,
      {bool isCollapsed: false, Iterable<TreeNode> children, Size size})
      : super(content, isCollapsed: isCollapsed, children: children, size: size);

  String get label => content.name;
  dynamic get key => content.id;

  ActionProvider get actionProvider => _actionProvider;
  AttachmentsActions get actions => _actions;
  AttachmentsStore get store => _store;

  AttachmentsTreeNode get dropTarget;

  renderIcon();
  renderRightCap();

  @override
  void traverse(bool visitor(AttachmentsTreeNode node), {bool visitSelf: true}) {
    super.traverse(visitor, visitSelf: visitSelf);
  }
}
