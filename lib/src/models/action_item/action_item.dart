part of w_attachments_client.models.action_item;

abstract class ActionItem {
  String testId;
  ReactElement icon;
  String label;
  String tooltip;
  bool isDisabled;
  bool isDivider = false;

  ActionItem(
      {@required this.icon,
      this.testId,
      this.tooltip,
      this.label,
      this.isDisabled: false});

  Function get callbackFunction;

  static ReactElement iconBuilder({@required IconGlyph icon, IconColors colors: IconColors.TWO}) => (Icon()
    ..align = IconAlign.LEFT
    ..glyph = icon
    ..colors = colors)();
}
