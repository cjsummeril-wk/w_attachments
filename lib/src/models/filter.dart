import 'package:meta/meta.dart';

import 'package:w_attachments_client/src/models/group.dart';

class Filter {
  String name;
  List<PredicateGroup> predicates;

  Filter({@required String this.name, @required List<PredicateGroup> this.predicates});

  List<PredicateGroup> applyToContextGroup(ContextGroup group) {
    return new List<PredicateGroup>.from(predicates).map((predicateGroup) {
      predicateGroup.regroup(group.attachments);
      return predicateGroup;
    }).toList();
  }

  int get hashCode => name.hashCode;
  String toString() => '<name=$name, predicates=$predicates>';
}
