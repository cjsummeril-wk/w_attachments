part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentRegionProps> AttachmentRegion;

@Props()
class AttachmentRegionProps extends RegionProps with AttachmentPropsMixin {
  Attachment attachment;
}

@Component(subtypeOf: RegionComponent)
class AttachmentRegionComponent extends UiComponent<AttachmentRegionProps> {
  @override
  render() {
    return (Region()
      ..addProps(copyUnconsumedProps())
      ..targetKey = props.attachment.id
      ..key = props.attachment.id
      ..header = RegionHeader()(props.attachment.id))((CardCollapse())(
        (Card()..header = (CardHeader())(props.attachment.accountResourceId))('Insert Attachment Usage Here!')));
  }
}
