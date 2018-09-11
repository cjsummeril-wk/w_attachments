part of w_attachments_client.components;

class AttachmentAvatarHandler extends AvatarHandler {
  final Attachment attachment;

  int zIndex = 999999;

  reactComponent() => (Block()..className = 'is-dragging dragged-attachment')(
      (Icon()
        ..className = 'dragged-attachment-icon'
        ..colors = IconColors.TWO
        ..glyph = FileMimeType.IconByMimeType[attachment.filemime] ?? IconGlyph.FILE_G2)(),
      (Dom.div()..className = 'dragged-attachment-text')(attachment.filename));

  AvatarFactory avatarFactory = () => new html.DivElement();

  AttachmentAvatarHandler(this.attachment);

  @override
  void dragStart(html.Element draggable, html.Point startPosition) {
    avatar = avatarFactory != null ? avatarFactory() : new html.DivElement();

    // To translate and drag, it needs to be absolutely posn'd. More
    // importantly, consumers can supply their own already-styled avatar
    // element, so we need to override any positioning they did or else the
    // algorithm here will have wrong locations.
    avatar.style
      ..position = 'absolute'
      ..zIndex = zIndex != null ? zIndex.toString() : 999999;

    // Add the drag avatar to the page.
    html.Element avatarParent = html.document.body;
    avatarParent.append(avatar);
    react_dom.render(reactComponent(), avatar);

    // Set the initial position of avatar to be under mouse cursor
    html.Point pageOffset = draggable.offsetTo(avatarParent);
    var widthDelta = startPosition.x - pageOffset.x;
    var heightDelta = startPosition.y - pageOffset.y;
    var pointDirectlyUnderCursor = new html.Point(pageOffset.x + widthDelta, pageOffset.y + heightDelta);
    setLeftTop(pointDirectlyUnderCursor);
  }

  @override
  void drag(html.Point startPosition, html.Point position) {
    setTranslate(position - startPosition);
  }

  @override
  void dragEnd(html.Point startPosition, html.Point position) {
    avatar.remove();
  }
}
