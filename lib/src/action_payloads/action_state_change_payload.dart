part of w_attachments_client.action_payloads;

class ActionStateChangePayload {
  final StatefulActionItem action;
  final String newState;

  ActionStateChangePayload({@required this.action, @required this.newState});
}
