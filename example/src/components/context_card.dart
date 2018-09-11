import 'package:dnd/dnd.dart';
import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;

import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/w_attachments_service_api.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;
import 'package:web_skin_dart/ui_components.dart';
import 'package:web_skin_dart/ui_core.dart';

import '../../index.dart' show ViewModeSettings;
import '../example_content_extension_framework.dart';
import '../utils.dart';

@Factory()
UiFactory<ContextCardProps> ContextCard;

@Props()
class ContextCardProps extends UiProps {
  String regionId;
  AttachmentsConfig config;
  AttachmentsModule module;
  AttachmentsServiceApi serviceApi;
  ExampleAttachmentsExtensionContext context;
  MouseEventCallback onMakeVisibleClick;
  bool useDefaultGroup;
  bool isHighlighted;
  ContextGroup defaultGroup;
  ViewModeSettings viewMode;
}

@State()
class ContextCardState extends UiState {
  bool isHighlighted;
  bool isVisibleRegion;
  bool attachmentDragging;
  bool isDraggingOver;
  String selectedItems;
  Map<String, PredicateGroup> selectedPredicateGroups;
}

@Component(subtypeOf: CardComponent)
class ContextCardComponent extends UiStatefulComponent<ContextCardProps, ContextCardState> {
  int _counter = 0;
  CardComponent _card;
  Function sortMethod = LabelGroupSort.compare;

  // Example Predicates
  List<PredicateGroup> availablePredicates;

  List<PredicateGroup> getCurrentPredicatesFromStore() {
    List<PredicateGroup> currentPredicates = [];
    Filter currentFilter = props.module.api.filtersByName[props.regionId];
    if (currentFilter != null) {
      currentPredicates = currentFilter.predicates;
    }
    return currentPredicates;
  }

  AttachmentsHighlight get attachmentHighlight =>
    props.context?.highlightApi?.highlights?.containsKey(props.regionId) == true ?
      props.context.highlightApi.highlights[props.regionId] :
      props.context.highlightApi.createV3(key: props.regionId, wuri: props.regionId);

  Map<String, PredicateGroup> convertPredicateListToMap(List<PredicateGroup> predicates) {
    return predicates.fold({}, (result, predicate) {
      result[predicate.name] = predicate;
      return result;
    });
  }

  @override
  getDefaultProps() => (newProps()
    ..regionId = ''
  );

  @override
  getInitialState() => (newState()
    ..isHighlighted = props.isHighlighted
    ..isVisibleRegion = false
    ..attachmentDragging = false
    ..isDraggingOver = false
    ..selectedPredicateGroups = {}
    ..selectedItems = ''
  );

  ContextGroup get _contextGroup =>
    props.module.api.groups.firstWhere(
      (group) => group.name == props.regionId, orElse: () => null
    ) ?? _searchChildGroups(props.regionId, props.module.api.groups);

  bool get isVisibleRegion =>
    props.context.observedRegionApi.getVisibleRegions().any(
      (cef.ObservedRegion region) => region.wuri == props.regionId
    );

  bool get isSelected {
    List<cef.Selection> currentSelections = props.context.selectionApi.getCurrentSelections();
    if (currentSelections.isNotEmpty) {
      return currentSelections.first?.wuri == props.regionId;
    }
  }

  bool get isSingleHighlight => props.context.highlightApi.selectedHighlights?.length == 1;

  Set<String> _currentlySelected = new Set<String>();

  @override
  componentDidMount() {
    super.componentDidMount();

    setState(newState()
      ..selectedPredicateGroups = convertPredicateListToMap(getCurrentPredicatesFromStore())
    );

    Dropzone _dropzone = new Dropzone(react_dom.findDOMNode(_card));

    listenToStream(attachmentHighlight.didChangeSelected, _handleHighlightActiveChanged);
    listenToStream(props.context.observedRegionApi.didChangeVisibleRegions, _handleRegionsDidChange);
    listenToStream(props.context.highlightApi.highlightWasAdded, _handleHighlightWasAdded);
    listenToStream(props.context.highlightApi.highlightWasRemoved, _handleHighlightWasRemoved);
    listenToStream(props.context.selectionApi.didChangeSelections, _handleSelectionDidChange);
    listenToStream(props.module.events.attachmentSelected, _handleSelectAttachment);
    listenToStream(props.module.events.attachmentDeselected, _handleUnselectAttachment);
    listenToStream(props.module.events.attachmentDragStart, _handleDragStart);
    listenToStream(props.module.events.attachmentDragEnd, _handleDragEnd);
    listenToStream(_dropzone.onDragEnter, _handleDragEnter);
    listenToStream(_dropzone.onDragLeave, _handleDragLeave);
    listenToStream(_dropzone.onDrop, _handleDrop);
  }

  @override
  componentWillMount() {
    super.componentWillMount();
    sortMethod = props.config.showFilenameAsLabel ? FilenameGroupSort.compare : LabelGroupSort.compare;
    availablePredicates = [
      new PredicateGroup(name: 'A-M', sortMethod: sortMethod, predicate: (Attachment attachment) {
        return new RegExp(r"^[a-m]").hasMatch(
          attachment.filename.toLowerCase()
        );
      }),
      new PredicateGroup(name: 'N-Z', sortMethod: sortMethod, predicate: (Attachment attachment) {
        return new RegExp(r"^[n-z]").hasMatch(
          attachment.filename.toLowerCase()
        );
      }),
      new PredicateGroup(name: 'Supported files (xlxs)', sortMethod: sortMethod, predicate: (Attachment attachment) {
        return ExampleSupportedMimeTypes.contains(
          attachment.filemime
        );
      }),
      new PredicateGroup(name: 'Unsupported files', sortMethod: sortMethod, predicate: (Attachment attachment) {
        return !ExampleSupportedMimeTypes.contains(
          attachment.filemime
        );
      })
    ];
  }

  @override
  render() {
    bool isVisible = state.isVisibleRegion;

    var makeVisibleButton = (Button()
      ..size = ButtonSize.SMALL
      ..skin = ButtonSkin.PRIMARY
      ..onClick = _handleMakeVisibleClick
      ..isDisabled = props.viewMode == ViewModeSettings.Headerless
    )(isVisible ? 'Make Invisible' : 'Make Visible');

    var selectAttachmentsButton = (Button()
      ..size = ButtonSize.SMALL
      ..skin = ButtonSkin.ALTERNATE
      ..isDisabled = !state.isHighlighted || props.viewMode == ViewModeSettings.Headerless
      ..onClick = _handleSelectAttachmentsClick
    )('Select attached');

    var allPredicateOptions = [];
    availablePredicates.forEach((predicateGroup) {
      bool isChecked = state.selectedPredicateGroups.containsKey(
        predicateGroup.name
      );
      allPredicateOptions.add(
        (CheckboxSelectOption()
          ..value = predicateGroup.name
          ..key = 'predicateOption:${predicateGroup.name}'
          ..isChecked = isChecked
          ..onClick = _handleFilterButtonClicked
          ..onChange = _handleFilterChanged
        )('${predicateGroup.name}')
      );
    });
    var filterCreator = (DropdownButton()
      ..displayText = 'Set Filter'
      ..skin = ButtonSkin.WARNING
      ..isDisabled = !state.isHighlighted || props.viewMode == ViewModeSettings.Headerless
      ..isOverlay = true
      ..onClick = _handleFilterButtonClicked
    )(
      (DropdownMenu())(
        allPredicateOptions
      )
    );
    return ((Card()
      ..className = 'context-card'
      ..header = props.regionId
      ..targetKey = props.regionId
      ..isCollapsible = false
      ..isSelected = state.isHighlighted
      ..onClick = _handleClick
      ..ref = ((CardComponent ref) => _card = ref)
      ..bodyFooter = !state.attachmentDragging ? [
        (VBlock()
          ..key = 1
        )(
          (BlockContent()
            ..key = 3
            ..collapse = BlockCollapse.TOP
            ..overflow = true
          )(
            '${associatedAttachments.length} attachments'
          ),
          (BlockContent()
            ..key = 4
            ..collapse = BlockCollapse.TOP
            ..overflow = true
          )(
            state.selectedItems?.isNotEmpty == true ? 'Selected: ${state.selectedItems}' : 'No selected attachment'
          )),
        (Block()
          ..className = 'grid-block grid-shrink'
          ..key = 2)((ButtonGroup()
            ..isVertical = true
            ..className = 'region-button-group'
          )(makeVisibleButton, selectAttachmentsButton, filterCreator)
        )
      ] : null
    )(
      !state.attachmentDragging
        ? 'highlighted: ${state.isHighlighted}, selected: ${isSelected}, visible: ${state.isVisibleRegion}'
        : _renderDropZone()
      )
    );
  }

  _stopBubbling(react.SyntheticEvent event) {
    event.preventDefault();
    event.stopPropagation();
  }

  ContextGroup _searchChildGroups(String name, List<Group> groups) {
    if (groups?.isNotEmpty == true) {
      for (Group group in groups) {
        ContextGroup found = group.childGroups?.firstWhere((group) => group.name == name, orElse: () => null) ??
          _searchChildGroups(name, group.childGroups);
        if (found != null) {
          return found;
        }
      }
    }

    return null;
  }

  _handleMakeVisibleClick(react.SyntheticEvent event) {
    _stopBubbling(event);
    if (props.onMakeVisibleClick != null && props.onMakeVisibleClick(event) == false) {
      return;
    }

    setState(newState()
      ..isVisibleRegion = !isVisibleRegion
    );

    if (!isVisibleRegion) {
      props.context.observedRegionApi.addVisibleRegion(props.regionId);
    } else {
      props.context.observedRegionApi.removeVisibleRegion(props.regionId);
    }
  }

  _handleSelectAttachmentsClick(react.SyntheticEvent event) {
    _stopBubbling(event);
    Group group = _findGroup(props.module.api.groups);
    List<Attachment> attachmentsToSelect = group?.attachments;
    List<String> attachmentKeysToSelect = attachmentsToSelect?.map((Attachment attachment) => attachment.id)?.toList() ?? [];

    if (!props.module.api.currentlySelectedAttachments.containsAll(attachmentKeysToSelect.toSet())) {
      props.module.api.selectAttachmentsByIds(attachmentIds: attachmentKeysToSelect);
    } else {
      props.module.api.deselectAttachmentsByIds(attachmentIds: attachmentKeysToSelect);
    }
  }

  Group _findGroup(List<Group> groups) {
    if (groups.isEmpty) return null;

    List<Group> childrenToSearch = [];
    for (Group group in groups) {
      if (group.name == props.regionId) {
        return group;
      }
      childrenToSearch.addAll(group.childGroups ?? []);
    }
    return _findGroup(childrenToSearch);
  }

  void _handleRegionsDidChange(List<String> values) => redraw();

  void _handleHighlightWasAdded(AttachmentsHighlight addedHighlight) {
    if (addedHighlight?.wuri == props.regionId) {
      setState(newState()
        ..isHighlighted = true
      );
    }
  }

  void _handleHighlightWasRemoved(AttachmentsHighlight removedHighlight) {
    if (removedHighlight?.wuri == props.regionId) {
      setState(newState()
        ..isHighlighted = false
      );
    }
  }

  _handleClick(react.SyntheticMouseEvent event) {
    if (props.viewMode != ViewModeSettings.Headerless) {
      bool isHighlighted = !state.isHighlighted;
      setState(newState()
        ..isHighlighted = isHighlighted
      );
      attachmentHighlight.isSelected = isHighlighted;

      props.context.selectionApi.changeCurrentSelection(
        (props.context.selectionApi.getCurrentSelections()?.first?.wuri != props.regionId && isHighlighted)
          ? props.regionId : null
      );
    }
  }

  _handleDragEnter(DropzoneEvent event) {
    if (_counter == 0) {
      setState(newState()
        ..isDraggingOver = true);
    }
    _counter++;
  }

  _handleDragLeave(DropzoneEvent event) {
    if (_counter > 0) {
      _counter--;
    }

    if (_counter == 0) {
      setState(newState()
        ..isDraggingOver = false);
    }
  }

  _handleDrop(DropzoneEvent event) async {
    _counter = 0;

    setState(newState()
      ..isDraggingOver = false);

    // Arbitrary dropzone action here, use any function or API call you need in your dropzone.
    // This particular functionality represents one possible way to reuse annotations for one selection.
    if (event.avatarHandler != null) {
      Attachment attachment = (event.avatarHandler as AttachmentAvatarHandler).attachment;
      List<Attachment> attachmentsAtThisRegionId = props.module.api.getAttachmentsByProducerWurl(props.regionId);
      
      if (!attachmentsAtThisRegionId.contains(attachment)) {
        await props.serviceApi.createAttachmentUsage(props.regionId, attachment.id);

        List<String> revisedKeys = props.context.observedRegionApi.regions.map((cef.ObservedRegion region) => region.wuri);
        props.module.api.getAttachmentsByProducers(producerWurlsToLoad: revisedKeys);
      }
    }
  }

  _renderDropZone() {
    var classes = new ClassNameBuilder()
      ..add('region__drop-target')
      ..add('is-drop-target')
      ..add('grid-block')
      ..add('is-drop-target--dragover', state.isDraggingOver);

    return (CardBlock()
      ..className = classes.toClassName()
    )(
      (Icon()
        ..align = IconAlign.LEFT
        ..glyph = IconGlyph.UPLOADED
        ..colors = IconColors.TWO
      )(), 'Example Drop Zone - Makes a new usage of the same attached file. '
      'Does nothing if dropping on the same context as the attachment.'
    );
  }

  void _handleDragEnd(event) => setState(newState()..attachmentDragging = false);
  void _handleDragStart(event) => setState(newState()..attachmentDragging = true);

  _handleHighlightActiveChanged(bool isActive) {
    List<String> active_wuris = props.context.highlightApi.selectedHighlights?.map(
      (AttachmentsHighlight highlight) => highlight.wuri
    )?.toList() ?? <String>[];

    List<ContextGroup> relatedGroups = [];
    for (String wuri in active_wuris) {
      ContextGroup toAdd = props.module.api.groups.firstWhere((group) => group.name == wuri, orElse: () => null);
      if (props.viewMode != ViewModeSettings.Tree && toAdd != null) {
        relatedGroups.add(toAdd);
      }
      else {
        toAdd = _searchChildGroups(wuri, props.module.api.groups);
        if (toAdd?.name == wuri) {
          relatedGroups.add(toAdd);
        }
      }
    }

    // Add this card's group if it doesn't already exist
    if (isActive && !relatedGroups.any((group) => group.name == props.regionId)) {
      relatedGroups.add(new ContextGroup(
        name: props.regionId,
        childGroups: [],
        pivots: [new GroupPivot(
          type: GroupPivotType.REGION,
          id: props.regionId,
          selection: props.regionId
        )],
        sortMethod: props.config.showFilenameAsLabel ? FilenameGroupSort.compare : LabelGroupSort.compare,
        uploadSelection: props.regionId
      ));
      // Remove this card's group if it's no longer active
    } else if (!isActive && relatedGroups.any((group) => group.name == props.regionId)) {
      relatedGroups.remove(relatedGroups.firstWhere((group) => group.name == props.regionId));
    }

    if (relatedGroups.isEmpty && props.useDefaultGroup) {
      relatedGroups.add(props.defaultGroup);
    }

    if (props.viewMode == ViewModeSettings.Tree) {
      PredicateGroup parent = new PredicateGroup(
        predicate: ((Attachment attachment) => true),
        name: 'Attribute Matrix - Predicate Group',
        childGroups: relatedGroups,
        customIconGlyph: IconGlyph.FILE_SHEET_G2
      );
      PredicateGroup grandparent = new PredicateGroup(
        predicate: ((Attachment attachment) => true),
        name: 'Interim Testing - Predicate Group',
        childGroups: [parent],
        customIconGlyph: IconGlyph.BEAKER_BADGE
      );
      props.module.api.setGroups(groups: [grandparent]);
    } else {
      props.module.api.setGroups(groups: relatedGroups);
    }
  }

  _handleFilterButtonClicked(react.SyntheticMouseEvent event) {
    _stopBubbling(event);
  }

  _handleFilterChanged(react.SyntheticFormEvent event) {
    String predName = event.target.value;
    if (state.selectedPredicateGroups.containsKey(predName)) {
      state.selectedPredicateGroups.remove(predName);
    } else {
      state.selectedPredicateGroups[predName] =
        availablePredicates.firstWhere((pred) => pred.name == predName);
    }

    setState(newState()
      ..selectedPredicateGroups = state.selectedPredicateGroups
    );

    if (props.viewMode != ViewModeSettings.Tree) {
      _contextGroup?.filterName = props.regionId;
    }

    Map<String, num> availablePredicatesById = availablePredicates.fold({}, (result, predGroup) {
      result[predGroup.name] = availablePredicates.indexOf(predGroup);
      return result;
    });

    List<Filter> currentFilters = new List.from(props.module.api.filters);
    Filter newFilter = new Filter(
      name: props.regionId,
      predicates: state.selectedPredicateGroups.values.toList()
        ..sort((PredicateGroup a, PredicateGroup b) {
          return availablePredicatesById[a.name].compareTo(availablePredicatesById[b.name]);
        })
    );

    num newFilterIndex = currentFilters.indexOf(newFilter);
    if (newFilterIndex >= 0) {
      currentFilters[newFilterIndex] = newFilter;
    } else {
      currentFilters.add(newFilter);
    }
    props.module.api.setFilters(filters: currentFilters);

    if (props.viewMode == ViewModeSettings.Tree) {
      _contextGroup?.childGroups = state.selectedPredicateGroups.values.toList()
        ..sort((PredicateGroup a, PredicateGroup b) {
          return availablePredicatesById[a.name].compareTo(availablePredicatesById[b.name]);
        });
      var currentGroups = props.module.api.groups;
      props.module.api.setGroups(groups: currentGroups);
    }
  }

  void _handleSelectionDidChange(_) {
    redraw();
  }

  _handleSelectAttachment(AttachmentSelectedEventPayload result) {
    _currentlySelected.add(result.selectedAttachmentKey);
    updateSelectedFilesDisplay();
  }

  _handleUnselectAttachment(AttachmentDeselectedEventPayload result) {
    _currentlySelected.remove(result.deselectedAttachmentKey);
    updateSelectedFilesDisplay();
  }

  void updateSelectedFilesDisplay() {
    List<Attachment> selectedAttachments = props.module.api.getAttachmentsByProducerWurl(props.regionId).where((Attachment attachment) =>
      _currentlySelected.contains(attachment.id)).toList();
    setState(newState()
      ..selectedItems = selectedAttachments.map((Attachment attachment) => attachment.filename).join('\n')
    );
  }

  List<Attachment> get associatedAttachments {
    return props.module.api.getAttachmentsByProducerWurl(props.regionId).toList();
  }
}
