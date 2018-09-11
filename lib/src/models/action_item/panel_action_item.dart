part of w_attachments_client.models.action_item;

class PanelActionItem extends StatefulActionItem {
  PanelActionCallback callback;
  ShouldShowPanelActionItemCallback shouldShow;

  PanelActionItem(
      {@required PanelActionCallback this.callback,
      @required ReactElement icon,
      ShouldShowPanelActionItemCallback this.shouldShow,
      String testId,
      String tooltip,
      String label,
      Map<String, ReactElement> states,
      bool isDisabled: false})
      : super(icon: icon, states: states, testId: testId, tooltip: tooltip, label: label, isDisabled: isDisabled) {
    this.shouldShow ??= () => true;
  }

  @override
  Function get callbackFunction => callback;
}
