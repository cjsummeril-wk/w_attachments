import 'package:color/color.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart';
import 'package:web_skin_dart/ui_components.dart';

const String appName = 'w_attachments';
const String serviceName = 'annotations';

const int noStrokeWidth = 0;
const int strokeWidth = 2;

// The default style is intended to be applied when the attachment is not selected explicitly
//const int NormalRColor = 224;
//const int NormalGColor = 242;
//const int NormalBColor = 255;
//final Color NormalColor = new Color.rgb(NormalRColor, NormalGColor, NormalBColor);
final Color NormalColor = new Color.hex(ZestyCrayonColor.ORANGE_40);

//const int ActiveRColor = 194;
//const int ActiveGColor = 230;
//const int ActiveBColor = 255;
//final Color HoverColor = new Color.rgb(ActiveRColor, ActiveGColor, ActiveBColor);
final Color HoverColor = new Color.hex(ZestyCrayonColor.ORANGE_60);

//const int HoverRColor = 0;
//const int HoverGColor = 148;
//const int HoverBColor = 255;
//final Color ActiveColor = new Color.rgb(HoverRColor, HoverGColor, HoverBColor);
final Color ActiveColor = new Color.hex(ZestyCrayonColor.ORANGE_120);

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

final HighlightStyle activeHighlightStyle = new HighlightStyle(
  fill: ActiveColor,
  stroke: ActiveColor,
  strokeWidth: noStrokeWidth,
);

final HighlightStyles normalHighlightStyles = new HighlightStyles(
  selected: normalHighlightStyle,
  hoverSelected: normalHighlightStyle,
  hover: hoverHighlightStyle,
  normal: normalHighlightStyle,
);

final HighlightStyles activeHighlightStyles = new HighlightStyles(
  selected: activeHighlightStyle,
  hoverSelected: activeHighlightStyle,
  hover: hoverHighlightStyle,
  normal: activeHighlightStyle,
);

final HighlightStyles normalPanelHoverStyles = new HighlightStyles(
  selected: hoverHighlightStyle,
  hoverSelected: hoverHighlightStyle,
  hover: hoverHighlightStyle,
  normal: hoverHighlightStyle,
);

final HighlightStyles activePanelHoverStyles = new HighlightStyles(
  selected: hoverHighlightStyle,
  hoverSelected: hoverHighlightStyle,
  hover: hoverHighlightStyle,
  normal: hoverHighlightStyle,
);
