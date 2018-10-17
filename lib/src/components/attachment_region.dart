part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentRegionProps> AttachmentRegion;

@Props()
class AttachmentRegionProps extends RegionProps {
  AttachmentsActions actions;
  AttachmentsStore store;
  Attachment attachment;
  List<AttachmentUsage> references;
}

@State()
class AttachmentRegionState extends UiState {
  bool isHovered;
  bool isExpanded;
}

@Component(subtypeOf: RegionComponent)
class AttachmentRegionComponent extends UiStatefulComponent<AttachmentRegionProps, AttachmentRegionState> {
  @override
  getInitialState() => (newState()
    ..isHovered = false
    ..isExpanded = false);

  @override
  render() {
    return (Region()
          ..addProps(copyUnconsumedProps())
          ..className = 'reference-view__region'
          ..className = state.isExpanded ? 'region-block' : ''
          ..targetKey = props.targetKey
          ..key = props.attachment.id
          ..onMouseOver = _handleMouseOver
          ..onMouseLeave = _handleMouseLeave
          ..onClick = _handleExpandRegion
          ..size = RegionSize.DEFAULT
          ..header = (RegionHeader()..rightCap = _handleRenderRegionDropdown())(
              Dom.strong()(props.attachment.filename.isEmpty ? 'attachment_file_name' : props.attachment.filename)))(
        (_generateReferenceCards()));
  }

  List<ReactElement> _generateReferenceCards() {
    int referenceCount = 1;
    List<ReactElement> referenceCards = props.references.map((AttachmentUsage usage) {
      return (Block()
            ..size = 12
            ..className = 'reference-view__reference-card'
            ..key = usage.id)(
          // two blocks nested next to each other: one for text, one for actions on reference.
          (BlockContent()
                ..size = 9
                ..className = "reference-view__reference-card--text-container")(
              ((Dom.p()..className = 'reference-view--header')('Reference Label ${referenceCount++}')),
              ((Dom.p()..className = 'reference-view--location')(usage.anchorId))),
          (BlockContent()
                ..size = 3
                ..className = 'reference-view__reference-card--buttons-container')(
              (Button()
                ..className = 'reference-view__reference-card--buttons'
                ..noText = true
                ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.TASK_LINK)()),
              (Button()
                ..className = 'reference-view__reference-card--buttons'
                ..noText = true
                ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.CHEVRON_DOWN)())));
    }).toList();
    return referenceCards;
  }

  ReactElement _handleRenderRegionDropdown() {
    if (state.isExpanded || state.isHovered) {
      return (DropdownButton()
        ..noText = true
        ..onClick = _handleDropdownClick
        ..pullMenuRight = true
        ..size = ButtonSize.XSMALL)(DropdownMenu()((MenuItem()..onClick = _handleAddReference)("Add Reference")));
    } else {
      return null;
    }
  }

  _handleMouseOver(e) {
    if (!state.isHovered) {
      setState(newState()..isHovered = true);
    }
  }

  _handleMouseLeave(e) {
    if (state.isHovered) {
      setState(newState()..isHovered = false);
    }
  }

  _handleExpandRegion(e) {
    if (state.isExpanded) {
      setState(newState()..isExpanded = false);
    } else {
      setState(newState()..isExpanded = true);
    }
  }

  _handleDropdownClick(event) {
    event.stopPropagation();
    event.preventDefault();
  }

  _handleAddReference(e) {
    cef.Selection selection = props.store.currentSelection;
    CreateAttachmentUsagePayload payload =
        new CreateAttachmentUsagePayload(producerSelection: selection, attachmentId: props.attachment.id);
    props.actions.createAttachmentUsage(payload);
  }
}
