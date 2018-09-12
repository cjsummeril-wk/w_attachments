part of w_attachments_client.components;

@Factory()
UiFactory<EmptyAttachmentCardProps> EmptyAttachmentCard;

@Props()
class EmptyAttachmentCardProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {}

@State()
class EmptyAttachmentCardState extends UiState {
  bool hoveredOn;
}

@Component(subtypeOf: CardComponent)
class EmptyAttachmentCardComponent extends FluxUiStatefulComponent<EmptyAttachmentCardProps, EmptyAttachmentCardState> {
  @override
  redrawOn() => [];

  @override
  getInitialState() => (newState()..hoveredOn = false);

  @override
  render() => (Card()
    ..addTestId('wh.AttachmentCardComponent.EmptyCard')
    ..className = ((new ClassNameBuilder()..add('attachment-card')..add('cursor-default')).toClassName())
    ..header = _renderEmptyHeader()
    ..isCollapsible = true
    ..isExpanded = false
    ..onMouseOver = _handleMouseOver
    ..onMouseLeave = _handleMouseLeave
    ..selectedEdgeColor = CardEdgeColor.GRAY_LIGHT
    ..skin = CardSkin.WHITE)();

  _renderEmptyHeader() => (CardHeader()
    ..className = ((new ClassNameBuilder()..add('attachment-card-header')..add('no-attachments')..add('not-editing'))
        .toClassName())
    ..leftCap = AttachmentIconRenderer()())(props.store.moduleConfig.emptyViewText);

  _handleMouseOver(e) {
    if (!state.hoveredOn) {
      setState(newState()..hoveredOn = true);
    }
  }

  _handleMouseLeave(e) {
    if (state.hoveredOn) {
      setState(newState()..hoveredOn = false);
    }
  }
}
