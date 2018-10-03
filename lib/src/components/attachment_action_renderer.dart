part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentActionRendererProps> AttachmentActionRenderer;

@Props()
class AttachmentActionRendererProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  @requiredProp
  ActionProvider actionProvider;

  @requiredProp
  Attachment attachment;

  bool isHovered;
  bool isSelected;
  bool renderAsCardHeaderActions;
  String addedClassName;
}

@Component()
class AttachmentActionRendererComponent extends FluxUiComponent<AttachmentActionRendererProps> {
  @override
  getDefaultProps() => (newProps()
    ..isHovered = false
    ..isSelected = false
    ..renderAsCardHeaderActions = false
    ..addedClassName = '');

  @override
  redrawOn() => [];

  @override
  render() {
    List<ActionItem> attachmentActions = props.actionProvider.getAttachmentActions(props.attachment);

    int menuItemCount = 0;
    List menuItems = new List.from(attachmentActions.map((ActionItem action) {
      return _renderMenuItemWithIcon(action, menuItemCount++);
    }));

    if (menuItems.isNotEmpty && (props.isHovered == true || props.isSelected == true)) {
      var actionDropdown = (DropdownButton()
        ..className = props.addedClassName
        ..noText = true
        ..onClick = _handleDropdownClick
        ..isOverlay = true
        ..useLegacyPositioning = false
        ..pullMenuRight = true
        ..size = ButtonSize.XSMALL)(DropdownMenu()(menuItems));
      if (props.renderAsCardHeaderActions) {
        return CardHeaderActions()(actionDropdown);
      } else {
        return actionDropdown;
      }
    }
    // need to return a valid react component or an error gets thrown
    return (Block()..shrink = true)();
  }

  _renderMenuItemWithIcon(StatefulActionItem action, dynamic key) {
    if (action.isDivider) {
      return (MenuItem()
        ..isDivider = true
        ..key = key)();
    }
    return (MenuItem()
      ..key = key
      ..isDisabled = action.isDisabled
      ..onSelect = (action.callbackFunction != null)
          ? ((react.SyntheticEvent event, Object object) => action.callbackFunction(action, props.attachment))
          : null)(action.currentStateView, action.label);
  }

  _handleDropdownClick(event) {
    event.stopPropagation();
    event.preventDefault();

    if (props.store.enableClickToSelect && !props.store.currentlySelectedAttachments.contains(props.attachment?.id)) {
      props.actions.selectAttachments(
          new SelectAttachmentsPayload(attachmentIds: [props.attachment?.id], maintainSelections: false));
    }
  }
}
