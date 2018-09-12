import 'package:uuid/uuid.dart';

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/w_attachments_service_api.dart';
import 'package:web_skin_dart/ui_components.dart';
import 'package:web_skin_dart/ui_core.dart';

import '../../index.dart' show ViewModeSettings;
import '../example_content_extension_framework.dart';
import './context_card.dart';

@Factory()
UiFactory<ContextListProps> ContextList;

@Props()
class ContextListProps extends UiProps {
  AttachmentsConfig config;
  AttachmentsModule module;
  AttachmentsServiceApi serviceApi;
  ExampleAttachmentsExtensionContext context;
  List<String> contextsToHighlight;
  bool useDefaultGroup;
  ContextGroup defaultGroup;
  ViewModeSettings viewMode;
}

@Component(subtypeOf: CardComponent)
class ContextListComponent extends UiComponent<ContextListProps> {
  @override
  componentDidMount() {
    super.componentDidMount();
    listenToStream(props.context.observedRegionApi.didChangeOrderedRegions, _handleRegionsDidChange);
    handleAddRegion(null);
  }

  @override
  render() {
    List regionCards = [];
    int ctr = 0;
    props.context.observedRegionApi.regions.forEach((region) {
      var contextCard = (ContextCard()
        ..addProps(copyUnconsumedProps())
        ..config = props.config
        ..module = props.module
        ..serviceApi = props.serviceApi
        ..context = props.context
        ..regionId = region.wuri
        ..key = 'region:${region.wuri}-${ctr++}'
        ..isHighlighted = props.contextsToHighlight.contains(region.wuri)
        ..useDefaultGroup = props.useDefaultGroup
        ..defaultGroup = props.defaultGroup
        ..viewMode = props.viewMode)();
      regionCards.add(contextCard);
    });

    var addRegionButton = (Icon()
      ..className = 'add-region-button'
      ..glyph = IconGlyph.PLUS_SIGN
      ..onClick = handleAddRegion)();
    return (Dom.div()..className = 'regions-div')(addRegionButton, (CardCollapse()..isAccordion = true)(regionCards));
  }

  handleAddRegion(_) {
    props.context.observedRegionApi.addVisibleRegion(new Uuid().v4().toString().substring(0, 22));
    redraw();
  }

  _handleRegionsDidChange(_) => redraw();
}
