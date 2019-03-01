import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_places_dialog/flutter_places_dialog.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import 'map_view/staticmapprovider.dart';

class LocationAndPlace {
  LocationAndPlace(this.details, this.loc);

  LocationAndPlace.fromGame(GamePlace place, String tz)
      : details = new PlaceDetails(
            name: place.name,
            address: place.address,
            placeid: place.placeId,
            location: new PlaceLatLong(
                latitude: place.latitude, longitude: place.longitude)),
        loc = Future<Location>.value(getLocation(tz));

  PlaceDetails details;
  Future<Location> loc;
}

class MapData {
  MapData() {
    _providerData = new StaticMapProvider(apiKey);
    FlutterPlacesDialog.setGoogleApiKey(iosApiKey);
  }

  static const String apiKey = "AIzaSyC0nzXvh-NqEV5c1Qoa-DCUY6iVXG0HcGQ";
  static const String iosApiKey = "AIzaSyBVJ6DGEqQv4lRicySx0siZTCk-9lXY6lY";
  static const String urlAuth = "maps.googleapis.com";
  static const String urlPath = "/maps/api/timezone/json";

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

  Future<Location> getTimezoneFromLocation(PlaceLatLong loc, num ms) async {
    Map<String, String> query = <String, String>{
      'location': loc.latitude.toString() + "," + loc.longitude.toString(),
      'timestamp': ms.toString(),
      'key': apiKey
    };
    Uri uri = new Uri.https(urlAuth, urlPath, query);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(uri);
    HttpClientResponse response = await request.close();
    print("Response $response");
    if (response.statusCode == HttpStatus.ok) {
      String responseBody = await response.transform(utf8.decoder).join();
      Map<String, dynamic> data =
          json.decode(responseBody) as Map<String, dynamic>;
      print("ResponseBody $data");
      return getLocation(data['timeZoneId'].toString());
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
