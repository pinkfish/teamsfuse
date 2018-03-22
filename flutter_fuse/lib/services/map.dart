import 'package:map_view/map_view.dart';

class MapData {
  static const String APIKEY = "AIzaSyC0nzXvh-NqEV5c1Qoa-DCUY6iVXG0HcGQ";

  static MapData _instance;
  StaticMapProvider _providerData;

  static MapData get instance {
    if (_instance == null) {
      _instance = new MapData();
    }
    return _instance;
}

  StaticMapProvider get provider {
    return _providerData;
  }

  MapData() {
    MapView.setApiKey(APIKEY);

    _providerData = new StaticMapProvider(APIKEY);
  }

  void openPlacesPickerModal() {
    MapView.openPlacePickerModal().then((Map<String, dynamic> val) {
      print('places ret $val');
    }).catchError((Object err) {
      print('$err Error!');
    });
  }
}

