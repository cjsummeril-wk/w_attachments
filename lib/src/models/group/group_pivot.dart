part of w_attachments_client.models.group;

enum GroupPivotType { RESOURCE, DOCUMENT, REGION, SECTION, GRAPH_VERTEX, ALL }

class GroupPivot {
  final GroupPivotType type;
  final String id;
  final String selection; // WURL type?

  const GroupPivot({@required this.type, @required this.id, this.selection});

  @override
  String toString() => '<type=$type, id=$id>';
}
