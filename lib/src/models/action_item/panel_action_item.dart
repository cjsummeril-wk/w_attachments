part of w_attachments_client.models.action_item;

class PanelActionItem extends StatefulActionItem {
  PanelActionCallback callback;
  ShouldShowPanelActionItemCallback shouldShow;

  PanelActionItem(
      {@required this.callback,
      @required ReactElement icon,
      this.shouldShow,
      String testId,
      String tooltip,
      String label,
      Map<String, ReactElement> states,
      bool isDisabled: false})
      : super(icon: icon, states: states, testId: testId, tooltip: tooltip, label: label, isDisabled: isDisabled) {
    shouldShow ??= () => true;
  }

  @override
  Function get callbackFunction => callback;
}
