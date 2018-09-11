part of w_attachments_client.models.action_item;

abstract class ActionItem {
  String testId;
  ReactElement icon;
  String label;
  String tooltip;
  bool isDisabled;
  bool isDivider = false;

  ActionItem(
      {@required ReactElement this.icon,
      String this.testId,
      String this.tooltip,
      String this.label,
      bool this.isDisabled: false});

  Function get callbackFunction;

  static ReactElement iconBuilder({@required IconGlyph icon, IconColors colors: IconColors.TWO}) => (Icon()
    ..align = IconAlign.LEFT
    ..glyph = icon
    ..colors = colors)();
}
