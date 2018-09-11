part of w_attachments_client.components;

var attachmentTreeNodeRenderer = react.registerComponent(() => new _AttachmentTreeNodeRenderer());

class _AttachmentTreeNodeRenderer extends w_virtual_components.TreeNodeRenderer {
  @override
  AttachmentsTreeNode get node => props['node'];

  bool get isEmptyNode => node is EmptyTreeNode;

  bool get selected => (!isEmptyNode && node.content is Attachment && node.store.currentlySelected.contains(node.key));

  dynamic _avatarAnchorComponent;

  // Draggable properties
  Draggable _draggable;
  List<StreamSubscription> _subs = [];
  bool _isDragging = false;

  // Dropzone properties
  int _counter = 0;

  @override
  componentDidMount() {
    super.componentDidMount();

    if (node is AttachmentTreeNode && node.store.enableDraggable) {
      _refreshAvatar();
    }
  }

  @override
  componentWillUnmount() {
    super.componentWillUnmount();

    _disposeAvatar();
    _subs.forEach((sub) {
      sub.cancel();
    });
    _subs.clear();
  }

  render() {
    var nodeClasses = new ClassNameBuilder()
      ..add('node-container')
      ..add('selected-node', selected)
      ..add('hovered-node', node.isInDropzone == true || node.store?.hoveredNode == node)
      ..add('drag-target-node', node.isDragTarget)
      ..add('is-drag-source', _isDragging)
      ..add('is-empty', isEmptyNode);

    return (Dom.div()
      ..addTestId(isEmptyNode ? 'wa.TreeNodeRenderer.empty' : 'wa.TreeNodeRenderer-${node.key}')
      ..tabIndex = 0
      ..onClick = _onClick
      ..onMouseOver = _onMouseEnter
      ..onMouseLeave = _onMouseLeave
      ..onDragEnter = _onDragEnter
      ..onDragLeave = _onDragLeave
      ..onDragOver = _onDragOver
      ..onDrop = _onDrop
      ..key = isEmptyNode ? 'node-empty' : 'node-${node.key}'
      ..ref = ((ref) => _avatarAnchorComponent = ref))((Block()..className = nodeClasses.toClassName())(
        depthPadding(), expandIcon(), Block()(node.renderIcon(), _renderContentText(), node.renderRightCap())));
  }

  void _handleExpansionToggleClick(react.SyntheticMouseEvent e) {
    if (node.isCollapsed) {
      node.expand();
    } else {
      node.collapse();
    }
    e.stopPropagation();
  }

  _onClick(react.SyntheticMouseEvent e) {
    if (node.store.enableClickToSelect) {
      _toggleSelectAttachment();
    }
  }

  _onMouseEnter(_) {
    node.actions.hoverOverAttachmentNode(new HoverOverNodePayload(hovered: node));
  }

  _onMouseLeave(_) {
    node.actions.hoverOutAttachmentNode(new HoverOutNodePayload(unhovered: node));
  }

  expandIcon() {
    if (node.isLeaf) return null;

    String expandClass = node.isCollapsed ? "collapsed" : "open";

    return (BlockContent()
      ..className = 'expand-node-item'
      ..onClick = _handleExpansionToggleClick
      ..shrink = true)((Dom.span()
      ..addTestId('wa.TreeNodeRenderer.ExpandIcon')
      ..className = 'caret ${expandClass}')());
  }

  /// Renders the empty space that pushes the content item to the right.
  /// This gives the node a nested appearance.
  depthPadding() {
    List padders = new List();

    void addPadder(key) {
      padders.add((Dom.span()
        ..addTestId('wa.TreeNodeRenderer.DepthPadding')
        ..className = 'node-depth-padding'
        ..key = key)());
    }

    for (int i = 0; i < node.depth - 1; i++) {
      addPadder(i);
    }
    if (node.isLeaf) {
      addPadder(padders.length);
    }

    return (Block()
      ..className = 'node-depth-padding-item'
      ..shrink = true)(padders);
  }

  _renderContentText() {
    return (BlockContent()
      ..className = 'content-item node-content-input')((node is AttachmentTreeNode && node.store.enableLabelEdit)
        ? (AttachmentFileLabel()
          ..actions = node.actions
          ..attachment = node.content
          ..labelText = node.label
          ..store = node.store)()
        : node.label);
  }

  _toggleSelectAttachment() async {
    if (node is AttachmentTreeNode) {
      if (selected) {
        node.actions.deselectAttachments(new DeselectAttachmentsPayload(selectionKeys: [node.key]));
      } else {
        node.actions
            .selectAttachments(new SelectAttachmentsPayload(selectionKeys: [node.key], maintainSelections: false));
      }
    }
    node.trigger();
  }

  // Dropzone Event Handlers
  _onDragEnter(react.SyntheticMouseEvent event) {
    if (node.store?.enableUploadDropzones == true) {
      event.preventDefault();

      if (_counter == 0) {
        node.dropTarget?.traverse((AttachmentsTreeNode draggedOverNode) {
          // isDragTarget is the part of the dropzone that the mouse is actually hovering over during drag
          // if hovering over the dropTarget, the dropTarget is dark blue and all its descendants are light blue
          // if hovering over any descendant of dropTarget, all descendants are dark blue and the dropTarget is light blue
          draggedOverNode.isDragTarget =
              (node == node.dropTarget) ? node.dropTarget == draggedOverNode : node.dropTarget != draggedOverNode;
          draggedOverNode.isInDropzone = true;
          draggedOverNode.trigger();
          return true;
        });
      }
      _counter++;
      node.dropTarget?.dropzoneRefCounter++;
    }
  }

  _onDragLeave(react.SyntheticMouseEvent event) {
    if (node.store?.enableUploadDropzones == true) {
      event.preventDefault();

      _counter--;
      node.dropTarget?.dropzoneRefCounter--;
      if (_counter == 0 && node.dropTarget?.dropzoneRefCounter == 0) {
        node.dropTarget?.traverse((draggedOverNode) {
          draggedOverNode.isDragTarget = false;
          draggedOverNode.isInDropzone = false;
          draggedOverNode.trigger();
          return true;
        });
      }
    }
  }

  _onDragOver(react.SyntheticMouseEvent event) {
    // This has to be here in order to allow the onDrop to function properly.
    // I have no idea why that is the case, but it won't work without this.
    if (node.store?.enableUploadDropzones == true) {
      event.preventDefault();
    }
  }

  _onDrop(react.SyntheticMouseEvent event) {
    if (node.store?.enableUploadDropzones == true) {
      event.preventDefault();

      _counter = 0;
      var selection = (node?.dropTarget?.content as ContextGroup)?.uploadSelection;
      node.actions.dropFiles(new DropFilesPayload(selection: selection, files: event.dataTransfer?.files));
    }
  }

  // Draggable Event Handlers
  _handleDragStart(DraggableEvent event) {
    node.store?.attachmentsEvents?.attachmentDragStart(event, node.store?.dispatchKey);
    _isDragging = true;
    node.trigger();
  }

  _handleDragEnd(DraggableEvent event) {
    node.store?.attachmentsEvents?.attachmentDragEnd(event, node.store?.dispatchKey);
    _isDragging = false;
    node.trigger();
  }

  void _refreshAvatar() {
    _disposeAvatar();
    html.Element el = react_dom.findDOMNode(_avatarAnchorComponent);
    if (el != null) {
      var avatar = new AttachmentAvatarHandler(node.content as Attachment);
      _draggable = new Draggable(el, avatarHandler: avatar);
      _subs..add(_draggable.onDragStart.listen(_handleDragStart))..add(_draggable.onDragEnd.listen(_handleDragEnd));
    }
  }

  void _disposeAvatar() {
    _draggable?.destroy();
  }
}
