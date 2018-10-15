part of w_attachments_client.components;

@Factory()
UiFactory<GroupPanelProps> GroupPanel;

@Props()
class GroupPanelProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  ActionProvider actionProvider;
  ContextGroup group;
  String selection;
}

@State()
class GroupPanelState extends UiState {
  bool hoveredOn;
  bool isDragging;
}

@Component(subtypeOf: RegionComponent)
class GroupPanelComponent extends FluxUiStatefulComponent<GroupPanelProps, GroupPanelState> {
  @override
  getInitialState() => (newState()
    ..hoveredOn = false
    ..isDragging = false);

  int _counter = 0;

  @override
  render() {
    List<PredicateGroup> predicates = (props.store.filtersByName.containsKey(props.group.filterName))
        ? props.store.filtersByName[props.group.filterName].applyToContextGroup(props.group)
        : [];

    var content = predicates.isEmpty ? _renderAttachmentCards(props.group.attachments) : _renderPredicates(predicates);
    if (props.store.enableUploadDropzones) {
      content.add(_renderDropZone());
    }

    if (props.store.showingHeaderlessGroup) {
      return (Region()
            ..header = ((RegionHeader()
              )
            ())
            ..onDragEnter = _onDragEnter
            ..onDragLeave = _onDragLeave
            ..onDragOver = _onDragOver
            ..onDrop = _onDrop
//        ..isNested = false
          )(content);
    }
    return (Region()
      ..targetKey = props.group
      ..className = 'group-panel'
      ..onMouseOver = _handleMouseOver
      ..onMouseLeave = _handleMouseLeave
      ..onDragEnter = _onDragEnter
      ..onDragLeave = _onDragLeave
      ..onDragOver = _onDragOver
      ..onDrop = _onDrop
      ..header = (RegionHeader()
        ..className = 'group-panel__header'
        ..rightCap = (GroupActionRenderer()
          ..actionProvider = props.actionProvider
          ..group = props.group
          ..hoveredOn = state.hoveredOn)())((Block()..className = 'cursor-default')(props.group?.name)))(content);
  }

  _onDragEnter(react.SyntheticMouseEvent event) {
    if (props.store.enableUploadDropzones) {
      event.preventDefault();
      if (_counter == 0) {
        setState(newState()..isDragging = true);
      }
      _counter++;
    }
  }

  _onDragLeave(react.SyntheticMouseEvent event) {
    if (props.store.enableUploadDropzones) {
      event.preventDefault();
      _counter--;
      if (_counter == 0) {
        setState(newState()..isDragging = false);
      }
    }
  }

  _onDragOver(react.SyntheticMouseEvent event) {
    // This has to be here in order to allow the onDrop to function properly.
    // I have no idea why that is the case, but it won't work without this.
    if (props.store.enableUploadDropzones) {
      event.preventDefault();
    }
  }

  _onDrop(react.SyntheticMouseEvent event) {
    if (props.store.enableUploadDropzones) {
      event.preventDefault();
      _counter = 0;
//      _regionCollapse?.expandRegion(props.group);
      setState(newState()..isDragging = false);
      props.actions.dropFiles(new DropFilesPayload(
          selection: (props.selection != null) ? props.selection : props.group?.uploadSelection,
          files: event.dataTransfer?.files));
    }
  }

  _renderDropZone() {
    var classes = new ClassNameBuilder()
      ..add('group-panel__drop-target', !state.isDragging)
      ..add('group-panel__drop-target--dragover', state.isDragging)
      ..add('grid-block');

    return (Dom.div()
          ..key = 'attachment-upload-dropzone'
          ..className = classes.toClassName())(
        (Icon()
          ..align = IconAlign.LEFT
          ..colors = IconColors.TWO
          ..glyph = IconGlyph.UPLOADED)(),
        'Drop Files To Upload');
  }

  _renderAttachmentCards(List<Attachment> attachments) => (CardCollapse()
    ..key = 'attachments-collapse'
    ..defaultExpandedTargetKeys = []
    ..skin = CardCollapseSkin.INVISIBLE_LIST)(attachments?.isNotEmpty == true
      ? attachments.map((Attachment attachment) => ((AttachmentCard()
        ..actions = props.actions
        ..store = props.store
        ..key = attachment.id
        ..attachment = attachment
        ..actionProvider = props.actionProvider)(attachment.filename)))
      : (EmptyAttachmentCard()
        ..actions = props.actions
        ..store = props.store)());

  _renderPredicates(List<PredicateGroup> predicates) => predicates
      .map((PredicateGroup pred) => (RegionCollapse()
        ..key = 'attachments-predicate-group-${pred.hashCode}-collapse'
        ..isDissociated = true
        ..defaultExpandedTargetKeys = [pred])((Region()
            ..key = 'attachments-predicate-group-${pred.hashCode}'
            ..targetKey = pred
            ..header = ((RegionHeader()..className = 'predicate-header')(pred.name)))(
          _renderAttachmentCards(pred.attachments))))
      .toList();

  _handleMouseOver(e) {
    if (!state.hoveredOn) {
      setState(newState()..hoveredOn = true);
    }
  }

  _handleMouseLeave(e) {
    if (state.hoveredOn) {
      setState(newState()..hoveredOn = false);
    }
  }
}
