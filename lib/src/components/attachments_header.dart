part of w_attachments_client.components;

@Factory()
UiFactory<AttachmentsHeaderProps> AttachmentsHeader;

@Props()
class AttachmentsHeaderProps extends FluxUiProps<AttachmentsActions, AttachmentsStore> {
  String headingLabel;
}

@Component()
class AttachmentsHeaderComponent extends FluxUiComponent<AttachmentsHeaderProps> {
  render() => ((Block()
        ..shrink = true
        ..collapse = BlockCollapse.ALL
        ..align = BlockAlign.CENTER)(
      (Dom.text()..addTestId('attachment.AttachmentViewComponent.Heading'))(props.headingLabel),
      (Block()
        ..id = utils.UPLOAD_INPUT_CACHE_CONTAINER
        ..style = {'display': 'none'})()));
}
