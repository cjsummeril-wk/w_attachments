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
    final classes = forwardingClassNameBuilder()..add('reference-view__region');

    return (Region()
      ..addProps(copyUnconsumedProps())
      ..addTestId('${test_id.ReferenceViewTestIds.rvAttachment}-${props.attachmentCounter}')
      ..className = classes.toClassName()
      ..key = props.attachment.id
      ..onMouseOver = _handleMouseOver
      ..onMouseLeave = _handleMouseLeave
      ..onClick = _handleOnClickExpand
      ..header = (RegionHeader()..rightCap = _renderActionButtons())(_renderHeader()))(_generateReferenceCards());
  }

  List<ReactElement> _generateReferenceCards() {
    List<ReactElement> referenceCards = props.references.map((AttachmentUsage usage) {
      int count = props.references.indexOf(usage) + 1;
      return (Card()
            ..addTestId("${test_id.ReferenceViewTestIds.rvReference}-${count}")
            ..className = 'reference-view__reference-card'
            ..key = usage.id
            ..skin = CardSkin.WHITE
            ..aria.expanded = state.isExpanded
            // for CEF implementation, we can select a card
            // we can change the selection color through ..selectedEdgeColor = CardEdgeColor.COLORNAME
            ..isSelectable = true
            ..isSelected = (usage?.id != null && props.store.usageIsSelected(usage.id))
            ..onClick = (SyntheticMouseEvent event) => _handleReferenceOnClick(event, usage))(
          (CardBlock()
                ..addTestId(test_id.ReferenceViewTestIds.referenceButtons)
                ..className = 'reference-view__reference-card__text-container')(
              (Dom.p()..className = 'reference-view__reference-card__header-text')('Reference Label ${count}'),
              (Dom.p()..className = 'reference-view__reference-card__location-text')(usage.anchorId)),
          (CardBlock()
                ..addTestId(test_id.ReferenceViewTestIds.referenceText)
                ..className = 'reference-view__reference-card__buttons-container'
                ..aria.hidden = state.isHovered)(
              (Button()
                ..size = ButtonSize.XSMALL
                ..noText = true
                ..className = 'reference-view__reference-card__button')((Icon()..glyph = IconGlyph.TASK_LINK)()),
              (Button()
                ..size = ButtonSize.XSMALL
                ..noText = true
                ..className = 'reference-view__reference-card__button')((Icon()..glyph = IconGlyph.CHEVRON_DOWN)())));
    }).toList();

    return referenceCards;
  }

  ReactElement _renderHeader() {
    return (Dom.span()..className = 'reference-view__icon')(
        Dom.strong()(
            (AttachmentIconRenderer()..attachment = props.attachment)(),
            props.attachment.filename == null || props.attachment.filename.isEmpty
                ? ' file_name'
                : props.attachment.filename),
        ' (${props.references.length})');
  }

  ReactElement _renderActionButtons() {
    if (!state.isExpanded && !state.isHovered) {
      return null;
    }

    return (Block())(
        (Button()
          ..noText = true
          ..isDisabled = !props.store.isValidSelection
          ..onClick = _handleAddReference
          ..addTestId(test_id.ReferenceViewTestIds.addReferenceButton)
          ..className = 'reference-view__buttons'
          ..modifyProps(hint('Add Reference', HintPlacement.BOTTOM))
          ..size = ButtonSize.XSMALL)((Icon()..glyph = IconGlyph.SHORTCUT_ADD)()),
        (DropdownButton()
          ..noText = true
          ..onClick = _handleDropdownClick
          ..pullMenuRight = true
          ..size = ButtonSize.XSMALL)(DropdownMenu()((MenuItem())("Delete Attachment"))));
  }

  _handleMouseOver(SyntheticMouseEvent event) {
    if (props.onMouseOver != null) {
      props.onMouseOver(event);
    }
    if (!state.isHovered) {
      props.actions.hoverAttachment(new HoverAttachmentPayload(
          previousAttachmentId: props.store.currentlyHoveredAttachmentId, nextAttachmentId: props.attachment.id));
      setState(newState()..isHovered = true);
    }
  }

  _handleMouseLeave(SyntheticMouseEvent event) {
    if (props.onMouseLeave != null) {
      props.onMouseLeave(event);
    }
    if (state.isHovered) {
      props.actions.hoverAttachment(new HoverAttachmentPayload(previousAttachmentId: props.attachment.id));
      setState(newState()..isHovered = false);
    }
  }

  _handleOnClickExpand(SyntheticMouseEvent event) {
    if (props.onClick != null) {
      props.onClick(event);
    }
    setState(newState()..isExpanded = !state.isExpanded);
  }

  _handleDropdownClick(SyntheticMouseEvent event) {
    event.stopPropagation();
    event.preventDefault();
  }

  _handleReferenceOnClick(SyntheticMouseEvent event, AttachmentUsage usage) {
    if (props.store.currentlySelectedAttachmentUsages.contains(usage.id)) {
      props.actions.deselectAttachmentUsages(new DeselectAttachmentUsagesPayload(usageIds: [usage.id]));
    } else {
      props.actions.selectAttachmentUsages(new SelectAttachmentUsagesPayload(usageIds: [usage.id]));
    }
  }

  _handleAddReference(SyntheticMouseEvent event) {
    event.preventDefault();
    event.stopPropagation();
    cef.Selection selection = props.store.currentSelection;
    CreateAttachmentUsagePayload payload =
        new CreateAttachmentUsagePayload(producerSelection: selection, attachmentId: props.attachment.id);
    props.actions.createAttachmentUsage(payload);
  }
}
