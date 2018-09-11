part of w_attachments_client.components;

class AttachmentsComponents extends ModuleComponents {
  final AttachmentsActions attachmentsActions;
  final AttachmentsStore store;
  final ActionProvider actionProvider;

  AttachmentsComponents({
    @required AttachmentsActions this.attachmentsActions,
    @required this.store,
    @required this.actionProvider
  });

  @override
  content() => (AttachmentsContainer()
    ..store = store
    ..actionProvider = actionProvider
    ..actions = attachmentsActions
  )();

  icon() => (Icon()
    ..glyph = IconGlyph.ATTACHMENT
    ..addTestId('attachments.AttachmentViewComponent.Icon')
  )();

  /// __Deprecated.__ Use [titleV2] instead.
  @deprecated
  title() => (AttachmentsHeader()
    ..headingLabel = 'Attachments'
  )();

  PanelTitleProps titleV2() => PanelTitle()
    ..addTestId('attachment.AttachmentViewComponent.Heading')
    ..defaultValue = 'Attachments';

  /// __Deprecated.__ Use [panelToolbar] instead.
  @deprecated
  menu() => (AttachmentsControls()
    ..actions = attachmentsActions
    ..store = store
    ..actionProvider = actionProvider
  )();

  AttachmentsPanelToolbarProps panelToolbar() => AttachmentsPanelToolbar()
      ..actions = attachmentsActions
      ..store = store
      ..panelActions = store.actionItems;
}
