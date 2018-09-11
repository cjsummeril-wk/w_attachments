part of w_attachments_client.models.action_item;

class GroupActionItem extends StatefulActionItem {
  GroupActionCallback callback;

  GroupActionItem(
      {@required GroupActionCallback this.callback,
      @required ReactElement icon,
      String testId,
      String tooltip,
      String label,
      Map<String, ReactElement> states,
      bool isDisabled: false})
      : super(icon: icon, states: states, testId: testId, tooltip: tooltip, label: label, isDisabled: isDisabled);

  Function get callbackFunction => callback;
}
