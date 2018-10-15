import 'package:intl/intl.dart';
import 'package:w_attachments_client/src/w_annotations_service/src/w_annotations_models.dart';

timestampStringFromMsSinceEpoch(int msSinceEpoch) {
  var newDateTime = new DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
  return new DateFormat.jm().format(newDateTime);
}

Map merge(Map map1, Map map2) {
  Map merged = new Map.from(map1);
  map2.forEach((k, v) => merged[k] = v);
  return merged;
}

List<E> removeAndAddType<E extends AnnotationModel>(List<E> incoming, List<E> stores, [bool keepExisting = false]) {
  List<E> _newList = new List<E>.from(stores);

  for (E e in incoming) {
    if (keepExisting) {
      E _found = _newList.firstWhere((E _e) => _e.id == e.id, orElse: () => null);
      if (_found != null) {
        _newList.remove(_found);
      }
    }
    _newList.add(e);
  }

  return _newList;
}
