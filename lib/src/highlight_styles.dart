import 'package:color/color.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart';
import 'package:web_skin_dart/ui_components.dart';

const String appName = 'w_attachments';
const String serviceName = 'annotations';

const int noStrokeWidth = 0;
const int strokeWidth = 2;

// The default style is intended to be applied when the attachment is not selected explicitly
final Color NormalColor = new Color.hex(ZestyCrayonColor.ORANGE_60);

final Color HoverColor = new Color.hex(ZestyCrayonColor.ORANGE_120);

final Color SelectedColor = new Color.hex(ZestyCrayonColor.ORANGE_120);

final HighlightStyle normalHighlightStyle = new HighlightStyle(
  fill: NormalColor,
  stroke: NormalColor,
  strokeWidth: noStrokeWidth,
);

final HighlightStyle hoverHighlightStyle = new HighlightStyle(
  fill: HoverColor,
  stroke: HoverColor,
  strokeWidth: noStrokeWidth,
);

final HighlightStyle selectedHighlightStyle = new HighlightStyle(
  fill: SelectedColor,
  stroke: SelectedColor,
  strokeWidth: noStrokeWidth,
);

final HighlightStyles normalHighlightStyles = new HighlightStyles(
  selected: normalHighlightStyle,
  hoverSelected: normalHighlightStyle,
  hover: hoverHighlightStyle,
  normal: normalHighlightStyle,
);

final HighlightStyles selectedHighlightStyles = new HighlightStyles(
  selected: selectedHighlightStyle,
  hoverSelected: selectedHighlightStyle,
  hover: hoverHighlightStyle,
  normal: selectedHighlightStyle,
);

final HighlightStyles normalPanelHoverStyles = new HighlightStyles(
  selected: hoverHighlightStyle,
  hoverSelected: hoverHighlightStyle,
  hover: hoverHighlightStyle,
  normal: hoverHighlightStyle,
);

final HighlightStyles selectedPanelHoverStyles = new HighlightStyles(
  selected: hoverHighlightStyle,
  hoverSelected: hoverHighlightStyle,
  hover: hoverHighlightStyle,
  normal: hoverHighlightStyle,
);
