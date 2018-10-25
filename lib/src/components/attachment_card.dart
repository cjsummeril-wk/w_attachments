part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentCardProps> AttachmentCard;

@Props()
class AttachmentCardProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  Attachment attachment;
  ActionProvider actionProvider;
}

@State()
class AttachmentCardState extends UiState {
  bool hoveredOn;
  bool isDragging;
}

@Component(subtypeOf: CardComponent)
class AttachmentCardComponent extends FluxUiStatefulComponent<AttachmentCardProps, AttachmentCardState> {
  dynamic _avatarAnchorComponent;
  Draggable _draggable;

  @override
  redrawOn() => [];

  @override
  getInitialState() => (newState()
    ..hoveredOn = false
    ..isDragging = false);

  @override
  componentDidMount() {
    super.componentDidMount();

    if (props.store.enableDraggable) {
      _refreshAvatar();
    }
  }

  @override
  componentWillUnmount() {
    super.componentWillUnmount();

    _disposeAvatar();
  }

  bool get _selected => (props.attachment?.id != null && props.store.attachmentIsSelected(props.attachment.id));

  @override
  render() {
    var classes = new ClassNameBuilder()
      ..add('attachment-card')
      ..add('cursor-default')
      ..add('is-drag-source', state.isDragging);

    return (Card()
      ..addTestId(test_id.AttachmentCardIds.attachmentCardId)
      ..className = classes.toClassName()
      ..header = _renderHeader()
      ..isSelected = _selected
      ..isCollapsible = true
      ..isExpanded = _selected
      ..onClick = _handleClick
      ..onMouseOver = _handleMouseOver
      ..onMouseLeave = _handleMouseLeave
      ..selectedEdgeColor = CardEdgeColor.GRAY_LIGHT
      ..skin = _selected ? CardSkin.DEFAULT : CardSkin.WHITE
      ..ref = ((ref) => _avatarAnchorComponent = ref))('Attachment metadata to go here');
  }

  _renderHeader() {
    return (AttachmentCardHeader()
      ..actions = props.actions
      ..actionProvider = props.actionProvider
      ..store = props.store
      ..isSelected = _selected
      ..isHovered = state.hoveredOn
      ..key = props.attachment.id
      ..attachment = props.attachment
      ..ref = 'cardHeader-${props.attachment.id}')();
  }

  _handleMouseOver(e) {
    if (!state.hoveredOn) {
      props.actions.hoverAttachment(new HoverAttachmentPayload(
          previousAttachmentId: props.store.currentlyHoveredAttachmentId, nextAttachmentId: props.attachment.id));
      setState(newState()..hoveredOn = true);
    }
  }

  _handleMouseLeave(e) {
    if (state.hoveredOn) {
      props.actions.hoverAttachment(new HoverAttachmentPayload(previousAttachmentId: props.attachment.id));
      setState(newState()..hoveredOn = false);
    }
  }

  _handleClick(e) {
    if (props.store.enableClickToSelect) {
      if (_selected) {
        props.actions.deselectAttachments(new DeselectAttachmentsPayload(attachmentIds: [props.attachment?.id]));
      } else {
        props.actions.selectAttachments(
            new SelectAttachmentsPayload(attachmentIds: [props.attachment?.id], maintainSelections: false));
      }
    }
  }

  _handleDragStart(DraggableEvent event) {
    props.store.attachmentsEvents.attachmentDragStart(event, props.store.dispatchKey);
    setState(newState()..isDragging = true);
  }

  _handleDragEnd(DraggableEvent event) {
    props.store.attachmentsEvents.attachmentDragEnd(event, props.store.dispatchKey);
    setState(newState()..isDragging = false);
  }

  void _refreshAvatar() {
    _disposeAvatar();

    html.Element el = react_dom.findDOMNode(_avatarAnchorComponent);
    if (el != null) {
      _draggable = new Draggable(el,
          avatarHandler: new AttachmentAvatarHandler(props.attachment)
            ..zIndex = 999999
            ..avatarFactory = () => (new html.DivElement()..append(new html.DivElement())));
      listenToStream(_draggable.onDragStart, _handleDragStart);
      listenToStream(_draggable.onDragEnd, _handleDragEnd);
    }
  }

  void _disposeAvatar() {
    _draggable?.destroy();
  }
}
