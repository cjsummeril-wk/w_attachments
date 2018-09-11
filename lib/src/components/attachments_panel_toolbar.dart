part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentsPanelToolbarProps> AttachmentsPanelToolbar;

@Props()
class AttachmentsPanelToolbarProps extends PanelToolbarProps<AttachmentsActions, AttachmentsStore> {
  List<ActionItem> panelActions;
}

@Component()
class AttachmentsPanelToolbarComponent extends FluxUiComponent<AttachmentsPanelToolbarProps> {
  List<ActionItem> _panelActions;

  @override
  get consumedProps => const [
    const $Props(AttachmentsPanelToolbarProps),
  ];

  @override
  componentWillMount() {
    super.componentWillMount();
    _panelActions = props.panelActions;
  }

  @override
  render() {
    final classes = forwardingClassNameBuilder()..add('attachments-controls');

    return (PanelToolbar()
      ..addProps(copyUnconsumedProps())
      ..addTestId('attachment.AttachmentViewComponent.Toolbar')
      ..belowToolbarContent = (Block()
        ..id = utils.UPLOAD_INPUT_CACHE_CONTAINER
        ..style = {
          'display': 'none'
        }
      )()
      ..className = classes.toClassName()
      ..toolbarItems = _renderItems()
    )();
  }

  List<ReactElement> _renderItems() {
    int keyCounter = 1;
    // take each template from the Action Provider and render the action button associated.
    return props.store.actionItems.map((ActionItem action) => _renderMenuButton(
      actionItem: action,
      key: 'attachments_controls_${keyCounter++}'
    )).toList();
  }

  ReactElement _renderMenuButton({@required PanelActionItem actionItem, @required String key}) {
    if (actionItem == null) return null;
    if (!actionItem.shouldShow()) return null;

    return (Button()
      ..key = key
      ..onClick = (_) {
        if (actionItem.callbackFunction != null) {
          actionItem.callbackFunction(actionItem);
        }
      }
      ..aria.label = actionItem.tooltip
      ..isDisabled = actionItem.isDisabled
      ..allowedHandlersWhenDisabled = EventHandlers.MOUSE_HOVER
      ..addTestId(actionItem.testId)
    )(
        actionItem.currentStateView
    );
  }
}
