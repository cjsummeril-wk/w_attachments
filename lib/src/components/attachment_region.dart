part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentRegionProps> AttachmentRegion;

@Props()
class AttachmentRegionProps extends RegionProps {
  AttachmentsActions actions;
  AttachmentsStore store;
  Attachment attachment;
  List<AttachmentUsage> references;
  cef.Selection currentSelection;
  int attachmentCounter;
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
      ..addTestId('${ComponentTestIds.rvAttachment}-${props.attachmentCounter}')
      ..className = 'reference-view__region'
      ..targetKey = props.targetKey
      ..key = props.attachment.id
      ..onMouseOver = _handleMouseOver
      ..onMouseLeave = _handleMouseLeave
      ..onClick = _handleExpandRegion
      ..size = RegionSize.DEFAULT
      ..header = (RegionHeader()..rightCap = _handleRenderActionButtons())(
          Dom.strong()(
              (Dom.span()
                ..className = 'reference-view__icon')((AttachmentIconRenderer()..attachment = props.attachment)()),
              props.attachment.filename == null || props.attachment.filename.isEmpty
                  ? 'attachment_file_name'
                  : props.attachment.filename),
          ' (${props.references.length})'))((_generateReferenceCards()));
  }

  List<ReactElement> _generateReferenceCards() {
    int referenceCount = 0;
    List<ReactElement> referenceCards = props.references.map((AttachmentUsage usage) {
      // increment test ids by 1
      referenceCount += 1;
      return (Block()
            ..addTestId("${ComponentTestIds.rvReference}-${referenceCount}")
            ..size = 12
            ..className = 'reference-view__reference'
            ..key = usage.id)(
          // two blocks nested next to each other: one for text, one for actions on reference.
          (BlockContent()
                ..size = 9
                ..addTestId(ComponentTestIds.referenceText)
                ..className = "reference-view__reference--text-container")(
              ((Dom.p()..className = 'reference-view__reference--header-text')('Reference Label ${referenceCount}')),
              ((Dom.p()..className = 'reference-view__reference--location-text')(usage.anchorId))),
          (BlockContent()
                ..size = 3
                ..addTestId(ComponentTestIds.referenceButtons)
                ..className = 'region__cap--right reference-view__reference--buttons-container')(
              (Button()
                ..className = 'reference-view__reference--buttons'
                ..noText = true
                ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.TASK_LINK)()),
              (Button()
                ..className = 'reference-view__reference--buttons'
                ..noText = true
                ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.CHEVRON_DOWN)())));
    }).toList();
    return referenceCards;
  }

  ReactElement _handleRenderActionButtons() {
    if (state.isExpanded || state.isHovered) {
      return (Block())(
          (Button()
            ..noText = true
            ..isDisabled = !props.store.isValidSelection
            ..onClick = _handleAddReference
            ..addTestId(ComponentTestIds.addReferenceButton)
            ..className = 'reference-view__buttons'
            ..modifyProps(hint('Add Reference', HintPlacement.BOTTOM))
            ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.SHORTCUT_ADD)()),
          (DropdownButton()
            ..noText = true
            ..onClick = _handleDropdownClick
            ..pullMenuRight = true
            ..size = ButtonSize.XSMALL)(DropdownMenu()((MenuItem())("Delete Attachment"))));
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
