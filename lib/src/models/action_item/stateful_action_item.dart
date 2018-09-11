part of w_attachments_client.models.action_item;

abstract class StatefulActionItem extends ActionItem {
  Map<String, ReactElement> states;
  String _currentStateName;
  ReactElement _currentStateView;
  bool _isStateful;

  String get currentStateName => _currentStateName;
  ReactElement get currentStateView => _currentStateView;
  bool get isStateful => _isStateful;

  StatefulActionItem(
      {@required ReactElement icon,
      String testId,
      String tooltip,
      String label,
      this.states,
      bool isDisabled: false})
      : super(icon: icon, testId: testId, tooltip: tooltip, label: label, isDisabled: isDisabled) {
    if (states?.isNotEmpty == true) {
      _isStateful = true;
      itemState = states.keys.first;
    } else {
      _isStateful = false;
      itemState = null;
    }
  }

  set itemState(String state) {
    if (isStateful && states?.isNotEmpty == true && states.containsKey(state)) {
      _currentStateName = state;
      _currentStateView = states[state];
    } else {
      _currentStateName = state;
      _currentStateView = icon;
    }
  }
}
