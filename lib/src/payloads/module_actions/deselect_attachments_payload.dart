part of w_attachments_client.payloads.attachments_module_actions;

class DeselectAttachmentsPayload {
  final List<int> attachmentIds;
  final List<int> usageIds;

  DeselectAttachmentsPayload({@required this.attachmentIds, this.usageIds});
}
