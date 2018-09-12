import 'package:intl/intl.dart';

timestampStringFromMsSinceEpoch(int msSinceEpoch) {
  var newDateTime = new DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
  return new DateFormat.jm().format(newDateTime);
}

Map merge(Map map1, Map map2) {
  Map merged = new Map.from(map1);
  map2.forEach((k, v) => merged[k] = v);
  return merged;
}
