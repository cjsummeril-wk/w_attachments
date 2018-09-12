part of w_attachments_client.models.group;

typedef bool PredicateFunction(Attachment attachment);
typedef int SortFunction(Attachment a, Attachment b);

class PredicateGroup extends Group {
  PredicateFunction predicate;
  SortFunction sortMethod;

  PredicateGroup(
      {@required this.predicate,
      @required String name,
      this.sortMethod: FilenameGroupSort.compare,
      List<Group> childGroups,
      IconGlyph customIconGlyph})
      : super(
            name: name, childGroups: childGroups, customIconGlyph: customIconGlyph ?? IconGlyph.FOLDER_ATTACHMENTS_G2);

  @override
  Set<Attachment> regroup(List<Attachment> newAttachments) {
    // filter the given attachments to match this context group
    // all attachments for this group and its child groups will initially be in this list
    Set<Attachment> filteredAttachments = new Set<Attachment>();
    if (newAttachments?.isNotEmpty == true) {
      filteredAttachments = filterAttachments(newAttachments);
    }
    //provide the filtered results to each child group for its own filtering
    Set<Attachment> claimedAttachments = new Set<Attachment>();
    if (childGroups?.isNotEmpty == true) {
      claimedAttachments = childGroups.fold([], (result, group) {
        result.addAll(group.regroup(filteredAttachments.toList()));
        return result;
      }).toSet();
    }

    // remove attachments that child groups have claimed and set the rendered list of attachments to the remainder
    _attachments = filteredAttachments.difference(claimedAttachments).toList()..sort((a, b) => sortMethod(a, b));

    // return all claimed attachments (ones now residing within a group) so that parent groups can process them
    return filteredAttachments;
  }

  Set<Attachment> filterAttachments(List<Attachment> unfiltered) {
    return unfiltered?.where(predicate)?.toSet() ?? new Set<Attachment>();
  }
}
