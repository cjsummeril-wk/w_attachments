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
  render() => (Region()
    ..addProps(copyUnconsumedProps())
    ..addTestId('${ReferenceViewTestIds.rvAttachment}-${props.attachmentCounter}')
    ..className = 'reference-view__region'
    ..targetKey = props.targetKey
    ..key = props.attachment.id
    ..onMouseOver = _handleMouseOver
    ..onMouseLeave = _handleMouseLeave
    ..onClick = _handleOnClickExpand
    ..size = RegionSize.DEFAULT
    ..header = (RegionHeader()..rightCap = _renderActionButtons())(_renderHeader()))((_generateReferenceCards()));

  List<ReactElement> _generateReferenceCards() {
    List<ReactElement> referenceCards = props.references.map((AttachmentUsage usage) {
      // increment test ids by 1
      int count = props.references.indexOf(usage);
      return (Block()
            ..addTestId("${ReferenceViewTestIds.rvReference}-${count}")
            ..size = 12
            ..className = 'reference-view__reference-card'
            ..key = usage.id)(
          // two blocks nested next to each other: one for text, one for actions on reference.
          (BlockContent()
                ..size = 9
                ..addTestId(ReferenceViewTestIds.referenceText)
                ..className = "reference-view__reference-card__text-container")(
              ((Dom.p()..className = 'reference-view__reference-card__header-text')('Reference Label ${count}')),
              ((Dom.p()..className = 'reference-view__reference-card__location-text')(usage.anchorId))),
          (BlockContent()
                ..size = 3
                ..addTestId(ReferenceViewTestIds.referenceButtons)
                ..className = 'region__cap--right reference-view__reference-card__buttons-container')(
              (Button()
                ..className = 'reference-view__reference-card__buttons'
                ..noText = true
                ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.TASK_LINK)()),
              (Button()
                ..className = 'reference-view__reference-card__buttons'
                ..noText = true
                ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.CHEVRON_DOWN)())));
    }).toList();
    return referenceCards;
  }

  ReactElement _renderHeader() {
    return (Dom.span()..className = 'reference-view__icon')(
        Dom.strong()(
            (AttachmentIconRenderer()..attachment = props.attachment)(),
            props.attachment.filename == null || props.attachment.filename.isEmpty
                ? ' attachment_file_name'
                : props.attachment.filename),
        ' (${props.references.length})');
  }

  ReactElement _renderActionButtons() {
    if (state.isExpanded || state.isHovered) {
      return (Block())(
          (Button()
            ..noText = true
            ..isDisabled = !props.store.isValidSelection
            ..onClick = _handleAddReference
            ..addTestId(ReferenceViewTestIds.addReferenceButton)
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

  _handleOnClickExpand(e) {
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
