part of w_attachments_client.payloads.attachments_module_actions;

class ActionStateChangePayload {
  final StatefulActionItem action;
  final String newState;

  ActionStateChangePayload({@required this.action, @required this.newState});
}
