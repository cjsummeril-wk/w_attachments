part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentsControlsProps> AttachmentsControls;

@Props()
class AttachmentsControlsProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  ActionProvider actionProvider;
}

@Component()
class AttachmentsControlsComponent extends FluxUiComponent<AttachmentsControlsProps> {
  List<ActionItem> _panelActions;

  @override
  componentWillMount() {
    super.componentWillMount();

    _panelActions = props.actionProvider.getPanelActions();
  }

  @override
  render() {
    int keyCounter = 1;

    return (Block()
      ..className = 'attachments-controls'
      ..shrink = true)(_panelActions.map(
        (ActionItem action) => _renderMenuButton(actionItem: action, key: 'attachments_controls_${keyCounter++}')));
  }

  _renderMenuButton({@required PanelActionItem actionItem, @required String key}) => (actionItem?.shouldShow() == true
      ? ((Block()
        ..addTestId(actionItem.testId)
        ..shrink = true
        ..align = BlockAlign.END
        ..collapse = BlockCollapse.ALL
        ..key = key)((OverlayTrigger()
        ..placement = OverlayPlacement.TOP
        ..overlay = Tooltip()(actionItem.tooltip))((Button()
        ..noText = true
        ..onClick = actionItem.callbackFunction != null
            ? ((react.SyntheticMouseEvent event) => actionItem.callbackFunction(actionItem))
            : null
        ..skin = ButtonSkin.VANILLA
        ..size = ButtonSize.XSMALL
        ..isDisabled = actionItem.isDisabled
        ..allowedHandlersWhenDisabled = EventHandlers.MOUSE_HOVER)(actionItem.currentStateView))))
      : null);
}
