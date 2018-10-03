import 'package:meta/meta.dart';

import 'package:w_attachments_client/src/models/group.dart';

class Filter {
  String name;
  List<PredicateGroup> predicates;

  Filter({@required this.name, @required this.predicates});

  List<PredicateGroup> applyToContextGroup(ContextGroup group) {
    return new List<PredicateGroup>.from(predicates).map((predicateGroup) {
      predicateGroup.rebuildAndRedrawGroup(group.attachments);
      return predicateGroup;
    }).toList();
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(other) => other is Filter && other.name == name;

  @override
  String toString() => '<name=$name, predicates=$predicates>';
}
