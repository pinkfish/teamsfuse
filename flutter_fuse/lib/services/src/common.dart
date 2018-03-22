String getString(dynamic data) {
  if (data == null) {
    return '';
  }
  return data;
}

bool getBool(dynamic data) {
  if (data == null) {
    return false;
  }
  return data;
}

num getNum(dynamic data) {
  if (data == null) {
    return 0;
  }
  return data;
}

// shared keys.
const String NAME = 'name';
const String ARRIVEEARLY = 'arriveEarly';
const String NOTES = 'notes';
const String ADDED = 'added';
const String PHOTOURL = 'photourl';

enum UpdateReason { Delete, Update }

