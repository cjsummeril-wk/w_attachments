import 'package:w_annotations_api/annotations_api_v1.dart';
import 'package:w_attachments_client/w_attachments_client.dart';

class TestConstants {
  // Test Constants for GetAttachmentUsageByIds Tests
  static int attachmentUsageIdOne = 1234;
  static int attachmentUsageIdTwo = 4567;

  static AttachmentUsage mockAttachmentUsage = new AttachmentUsage()
    ..accountResourceId = 'crispy-bacon-lettuce-and-tomato-sammich'
    ..anchorId = 1234
    ..attachmentId = 3456
    ..id = 5678
    ..label = 'i dont like labels.'
    ..parentId = 7890;
  static List<AttachmentUsage> mockAttachmentUsageList = [mockAttachmentUsage];

  static List<FAttachmentUsage> happyPathAttachmentUsages = [
    new FAttachmentUsage()..id = attachmentUsageIdOne,
    new FAttachmentUsage()..id = attachmentUsageIdTwo,
  ];
}
