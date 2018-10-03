part of w_attachments_client.models.group;

abstract class Group {
  final String key = new Uuid().v4();
  String name;
  List<Attachment> _attachments = [];
  List<Group> childGroups = [];
  IconGlyph customIconGlyph;

  Group({@required this.name, this.childGroups, this.customIconGlyph: IconGlyph.FOLDER_ATTACHMENTS_G2});

  Set<Attachment> rebuildAndRedrawGroup(List<Attachment> newAttachments);

  List<Attachment> get attachments => _attachments;

  bool get hasChildren => childGroups?.isNotEmpty == true;

  @override
  String toString() => 'name = $name, attachments = $attachments, children = $childGroups';
}
