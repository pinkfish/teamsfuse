import 'package:map_view/map_view.dart';
import 'package:flutter_timezone/timezone.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class LocationAndPlace {
  LocationAndPlace(this.details, this.loc);

  PlaceDetails details;
  Location loc;
}

class MapData {
  static const String APIKEY = "AIzaSyC0nzXvh-NqEV5c1Qoa-DCUY6iVXG0HcGQ";
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
    MapView.setApiKey(APIKEY);

    _providerData = new StaticMapProvider(APIKEY);
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
    if (response.statusCode == HttpStatus.OK) {
      String responseBody = await response.transform(UTF8.decoder).join();
      Map<String, String> data = JSON.decode(responseBody);
      return await getLocation(data['timeZoneId']);
    } else {
      print(await response.transform(UTF8.decoder).join());
    }
    return null;
  }

  Future<LocationAndPlace> getPlaceAndLocation() async {
    PlaceDetails details = await Timezone.getPlacesDialog();
    Location tz = await getTimezoneFromLocation(
        details.location, new DateTime.now().millisecondsSinceEpoch / 1000);
    print('tz $tz');
    return new LocationAndPlace(details, tz);
  }
}
