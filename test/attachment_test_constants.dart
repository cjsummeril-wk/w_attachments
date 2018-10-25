import 'package:w_annotations_api/annotations_api_v1.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';

/// Class designated Attachments service and frugal based test constants.
/// Any other constants not associated with the attachments service should be defined in their own TestConstants file.
class AttachmentTestConstants {
  static int anchorIdOne = 1234;
  static int anchorIdTwo = 4567;
  static int anchorIdThree = 8901;
  static int attachmentUsageIdOne = 1234;
  static int attachmentUsageIdTwo = 4567;
  static int attachmentUsageIdThree = 8901;
  static int attachmentIdOne = 1234;
  static int attachmentIdTwo = 4567;
  static int attachmentIdThree = 8901;

  static String existingWurl = "wurl://scope/existing";
  static String testWurl = "wurl://scope/test";
  static String testScope = "wurl://scope";

  static String label = "This is a test label";

  static Anchor mockAnchor = new Anchor()
    ..id = anchorIdOne
    ..accountResourceId = "crispy-rice-cakes"
    ..disconnected = false
    ..producerWurl = testWurl;
  static Anchor mockChangedAnchor = new Anchor()
    ..id = anchorIdTwo
    ..accountResourceId = "crispy-veggie-straws"
    ..disconnected = false
    ..producerWurl = testWurl;
  static Anchor mockExistingAnchor = new Anchor()
    ..id = anchorIdThree
    ..accountResourceId = "crispy-confit-duck"
    ..disconnected = false
    ..producerWurl = existingWurl;

  static AttachmentUsage mockAttachmentUsage = new AttachmentUsage()
    ..id = attachmentUsageIdOne
    ..anchorId = anchorIdOne
    ..attachmentId = attachmentIdOne
    ..accountResourceId = "crispy-bacon-lettuce-and-tomato-sammich"
    ..label = "crispy-bacon-and-sun-dried-tomato-salad"
    ..parentId = 7890;

  static AttachmentUsage mockAddedAttachmentUsage = new AttachmentUsage()
    ..id = attachmentUsageIdOne
    ..anchorId = 4343
    ..attachmentId = attachmentIdOne
    ..accountResourceId = "crispy-chick-fried-waffles"
    ..label = "crispy-chicken-crispers"
    ..parentId = 4343;

  static AttachmentUsage mockChangedAttachmentUsage = new AttachmentUsage()
    ..id = attachmentUsageIdTwo
    ..anchorId = anchorIdTwo
    ..attachmentId = attachmentIdTwo
    ..accountResourceId = "crispy-bacon-pancakes"
    ..label = "crispy-bacon-and-crispy-chicken-waffles"
    ..parentId = 999;
  static AttachmentUsage mockExistingAttachmentUsage = new AttachmentUsage()
    ..id = attachmentUsageIdThree
    ..anchorId = anchorIdThree
    ..attachmentId = attachmentIdThree
    ..accountResourceId = "crispy-crisps"
    ..label = 'crispy-lasagna'
    ..parentId = 123;

  static Attachment mockAttachment = new Attachment()
    ..id = attachmentIdOne
    ..accountResourceId = "crispy-chicken-fingers"
    ..fsResourceId = "1234"
    ..label = "crispy-salad-toppers"
    ..userName = "crispy-names"
    ..filename = 'crispy-fried-pickles'
    ..uploadStatus = Status.Pending;
  static Attachment mockChangedAttachment = new Attachment()
    ..id = attachmentIdTwo
    ..accountResourceId = "crispy-cereal-crunch"
    ..fsResourceId = "3456"
    ..label = "crispy-crackle-pop"
    ..filename = 'crispy-parmesan-cheese'
    ..userName = "crispy-fighter-jets-like-freals-cool"
    ..uploadStatus = Status.Complete;
  static Attachment mockExistingAttachment = new Attachment()
    ..id = attachmentIdThree
    ..accountResourceId = "crispy-jello"
    ..fsResourceId = "3456"
    ..filemime = "type"
    ..label = "crispy-laundry"
    ..userName = "crispy-smoothie"
    ..uploadStatus = Status.Complete;

  static FAnchor mockFAnchor = mockAnchor.toFAnchor();
  static FAnchor mockChangedFAnchor = mockChangedAnchor.toFAnchor();

  static FAttachmentUsage mockFAttachmentUsage = mockAttachmentUsage.toFAttachmentUsage();
  static FAttachmentUsage mockChangedFAttachmentUsage = mockChangedAttachmentUsage.toFAttachmentUsage();

  static FAttachment mockFAttachment = mockAttachment.toFAttachment();
  static FAttachment mockChangedFAttachment = mockChangedAttachment.toFAttachment();

  static List<Anchor> mockAnchorList = [mockChangedAnchor];
  static List<AttachmentUsage> mockAttachmentUsageList = [mockChangedAttachmentUsage];
  static List<Attachment> mockAttachmentList = [mockChangedAttachment];

  static List<FAnchor> mockFAnchorList = [mockFAnchor, mockChangedFAnchor];
  static List<FAttachmentUsage> mockFAttachmentUsageList = [mockFAttachmentUsage, mockChangedFAttachmentUsage];
  static List<FAttachment> mockFAttachmentList = [mockFAttachment, mockChangedFAttachment];
}
