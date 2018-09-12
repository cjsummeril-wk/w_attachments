part of w_attachments_client.models.action_item;

class AttachmentActionItem extends StatefulActionItem {
  AttachmentActionCallback callback;

  AttachmentActionItem(
      {@required this.callback,
      @required ReactElement icon,
      String testId,
      String tooltip,
      String label,
      Map<String, ReactElement> states,
      bool isDisabled: false})
      : super(icon: icon, states: states, testId: testId, tooltip: tooltip, label: label, isDisabled: isDisabled);

  Function get callbackFunction => callback;
}
