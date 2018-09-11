part of w_attachments_client.components;

@Factory()
UiFactory<GroupActionRendererProps> GroupActionRenderer;

@Props()
class GroupActionRendererProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  @requiredProp
  ActionProvider actionProvider;

  @requiredProp
  ContextGroup group;

  bool hoveredOn;
  String className;
}

@Component()
class GroupActionRendererComponent extends FluxUiComponent<GroupActionRendererProps> {
  @override
  getDefaultProps() => (newProps()
    ..hoveredOn = false
    ..className = ''
  );

  @override
  redrawOn() => [];

  @override
  render() {
    int keyCounter = 1;
    List<GroupActionItem> actions = props.actionProvider.getGroupActions(props.group);
    List buttons = new List.from(actions.map((ActionItem action) {
      return _renderGroupHeaderButton(action, 'group_panel_${keyCounter++}');
    }));

    return CardHeaderActions()(buttons);
  }

  _renderGroupHeaderButton(StatefulActionItem action, String key) {
    return props.hoveredOn == true ?
    (OverlayTrigger()
      ..className = props.className
      ..placement = OverlayPlacement.TOP
      ..overlay = Tooltip()(action.tooltip)
      ..key = key
      ..addProps(Button()
        ..skin = ButtonSkin.VANILLA)
    )(
      (Button()
        ..noText = true
        ..onClick = action.callbackFunction != null ? ((react.SyntheticMouseEvent event) {
          action.callbackFunction(action, props.group);
          return _stopBubbling(event);
        }) : null
        ..skin = ButtonSkin.VANILLA
        ..isDisabled = action.isDisabled
        ..allowedHandlersWhenDisabled = EventHandlers.MOUSE_HOVER
      )(action.currentStateView)
    ) : null;
  }

  _stopBubbling(react.SyntheticEvent event) {
    event.preventDefault();
    return event.stopPropagation();
  }
}
