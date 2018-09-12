part of w_attachments_client.models.group;

class ContextGroup extends Group {
  String filterName;
  bool displayAsHeaderless;
  Function sortMethod;
  List<GroupPivot> _pivots;
  String uploadSelection;

  ContextGroup(
      {String name,
      List<GroupPivot> pivots,
      this.uploadSelection,
      this.filterName,
      this.displayAsHeaderless: false,
      this.sortMethod: FilenameGroupSort.compare,
      List<Group> childGroups,
      IconGlyph customIconGlyph})
      : _pivots = pivots ?? <GroupPivot>[],
        super(
            name: name, childGroups: childGroups, customIconGlyph: customIconGlyph ?? IconGlyph.FOLDER_ATTACHMENTS_G2);

  List<GroupPivot> get pivots => _pivots;

  @override
  Set<Attachment> regroup(List<Attachment> newAttachments) {
    // filter the given attachments to match this context group
    // all attachments for this group and its child groups will initially be in this list
    Set<Attachment> filteredAttachments = new Set<Attachment>();
    if (newAttachments?.isNotEmpty == true) {
      if (pivots?.isNotEmpty == true) {
        for (GroupPivot pivot in pivots) {
          filteredAttachments.addAll(filterAttachments(newAttachments, pivot: pivot));
        }
      } else {
        filteredAttachments.addAll(filterAttachments(newAttachments));
      }
    }

    //provide the filtered results to each child group for its own filtering
    Set<Attachment> claimedAttachments = new Set<Attachment>();
    if (childGroups?.isNotEmpty == true) {
      claimedAttachments = childGroups.fold(<Attachment>[], (List<Attachment> result, group) {
        result.addAll(group.regroup(filteredAttachments.toList()));
        return result;
      }).toSet();
    }

    // remove attachments that child groups have claimed and set the rendered list of attachments to the remainder
    _attachments = filteredAttachments.difference(claimedAttachments).toList()..sort((a, b) => sortMethod(a, b));

    // return all claimed attachments (ones now residing within this or a child group) so that parent groups can process them
    return filteredAttachments;
  }

  Set<Attachment> filterAttachments(List<Attachment> unfiltered, {GroupPivot pivot: null}) {
    return unfiltered?.where((Attachment attachment) {
          if (pivot == null) return true;
//          if (attachment?.selection == null) return false;
          switch (pivot.type) {
//            case GroupPivotType.RESOURCE:
//              return pivot.id == attachment?.selection?.resourceId;
//            case GroupPivotType.DOCUMENT:
//              return pivot.id == attachment?.selection?.documentId;
//            case GroupPivotType.REGION:
//              return pivot.id == attachment?.selection?.regionId;
//            case GroupPivotType.SECTION:
//              return pivot.id == attachment?.selection?.sectionId;
//            case GroupPivotType.GRAPH_VERTEX:
//              return pivot.id == attachment?.selection?.resourceId &&
//                  pivot.selection.edgeName == attachment?.selection?.edgeName;
            case GroupPivotType.ALL:
              return true;
            default:
              return false;
          }
        })?.toSet() ??
        new Set<Attachment>();
  }

  @override
  int get hashCode => hash2(name.hashCode, displayAsHeaderless);

  @override
  bool operator ==(other) =>
      other is ContextGroup && other.name == name && other.displayAsHeaderless == displayAsHeaderless;

  @override
  String toString() => '<${super.toString()}, pivots=$pivots, displayAsHeaderless=$displayAsHeaderless>';
}
