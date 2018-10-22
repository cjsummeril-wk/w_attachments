import 'package:dnd/dnd.dart';
import 'package:w_module/w_module.dart';

import 'package:w_attachments_client/src/payloads/module_events.dart';
import 'package:w_attachments_client/src/attachments_module.dart' show attachmentsModuleDispatchKey;

class AttachmentsEvents extends EventsCollection {
  /// removedAttachment Event is raised when an attachment is removed from its dropdown option 'Remove Attachment'.
  /// This event only gets raised when the attachment gets removed from within the panel.
  final Event<AttachmentRemovedEventPayload> attachmentRemoved = new Event(attachmentsModuleDispatchKey);

  /// attachmentUploadCanceled Event is raised when the active upload of an attachment is selected to be canceled
  /// by the user, and either the cancelUpload or cancelUploads action is called.
  final Event<AttachmentUploadCanceledEventPayload> attachmentUploadCanceled = new Event(attachmentsModuleDispatchKey);

  /// attachmentDragStart Event is raised when an attachment begins getting dragged, specifically the draggable's
  /// onDragStart event
  final Event<DraggableEvent> attachmentDragStart = new Event(attachmentsModuleDispatchKey);

  /// attachmentDragEnd Event is raised when an attachment stops getting dragged, specifically the draggable's
  /// onDragEnd event
  final Event<DraggableEvent> attachmentDragEnd = new Event(attachmentsModuleDispatchKey);

  AttachmentsEvents() : super(attachmentsModuleDispatchKey) {
    [attachmentRemoved, attachmentDragStart, attachmentDragEnd].forEach(manageEvent);
  }
}
