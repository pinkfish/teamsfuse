import 'map_view/staticmapprovider.dart';
import 'package:flutter_places_dialog/flutter_places_dialog.dart';
import 'package:timezone/timezone.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class LocationAndPlace {
  LocationAndPlace(this.details, this.loc);

  LocationAndPlace.fromGame(GamePlace place, String tz)
      : details = new PlaceDetails(
            name: place.name,
            address: place.address,
            placeid: place.placeId,
            location: new PlaceLatLong(
                latitude: place.latitude, longitude: place.longitude)),
        loc = Future.value(getLocation(tz));

  PlaceDetails details;
  Future<Location> loc;
}

class MapData {
  static const String APIKEY = "AIzaSyC0nzXvh-NqEV5c1Qoa-DCUY6iVXG0HcGQ";
  static const String IOS_APIKEY = "AIzaSyBVJ6DGEqQv4lRicySx0siZTCk-9lXY6lY";
  static const String URL_AUTH = "maps.googleapis.com";
  static const String URL_PATH = "/maps/api/timezone/json";

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
     _providerData = new StaticMapProvider(APIKEY);
     FlutterPlacesDialog.setGoogleApiKey(IOS_APIKEY);
  }

  Future<Location> getTimezoneFromLocation(PlaceLatLong loc, num ms) async {
    Map<String, String> query = {
      'location': loc.latitude.toString() + "," + loc.longitude.toString(),
      'timestamp': ms.toString(),
      'key': APIKEY
    };
    Uri uri = new Uri.https(URL_AUTH, URL_PATH, query);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(uri);
    HttpClientResponse response = await request.close();
    print("Response $response");
    if (response.statusCode == HttpStatus.OK) {
      String responseBody = await response.transform(utf8.decoder).join();
      Map<String, dynamic> data = json.decode(responseBody);
      print("ResponseBody $data");
      return getLocation(data['timeZoneId']);
    } else {
      print(await response.transform(utf8.decoder).join());
    }
    return null;
  }

  Future<LocationAndPlace> getPlaceAndLocation() async {
    PlaceDetails details = await FlutterPlacesDialog.getPlacesDialog();
    print("Looking up timezone for $details.location");
    Future<Location> tz = getTimezoneFromLocation(
        details.location, new DateTime.now().millisecondsSinceEpoch / 1000);
    print('tz $tz');
    return new LocationAndPlace(details, tz);
  }
}

