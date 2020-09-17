import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_places_dialog/flutter_places_dialog.dart';
import 'package:timezone/timezone.dart';

import 'map_view/staticmapprovider.dart';

///
/// Location and place information for dealing with the maps.
///
class LocationAndPlace {
  /// Constrcutor.
  LocationAndPlace(this.details, this.loc);

  /// Create a place from a game, working out the pieces needed to work with the
  /// maps ux.
  LocationAndPlace.fromGame(place, tz)
      : details = PlaceDetails(
            name: place.name,
            address: place.address,
            placeid: place.placeId,
            location: PlaceLatLong(
                latitude: place.latitude, longitude: place.longitude)),
        loc = Future<Location>.value(getLocation(tz));

  /// The details for the place.
  PlaceDetails details;

  /// The location for the place.
  Future<Location> loc;
}

///
/// The map data associated with the maps.
///
class MapData {
  /// Constructor for the map data.
  MapData() {
    _providerData = StaticMapProvider(_apiKey);
    FlutterPlacesDialog.setGoogleApiKey(_iosApiKey);
  }

  static const String _apiKey = "AIzaSyC0nzXvh-NqEV5c1Qoa-DCUY6iVXG0HcGQ";
  static const String _iosApiKey = "AIzaSyBVJ6DGEqQv4lRicySx0siZTCk-9lXY6lY";
  static const String _urlAuth = "maps.googleapis.com";
  static const String _urlPath = "/maps/api/timezone/json";

  static MapData _instance;
  StaticMapProvider _providerData;

  ///
  /// The map data for the instance.
  ///
  static MapData get instance {
    if (_instance == null) {
      _instance = MapData();
    }
    return _instance;
  }

  ///
  /// Gets the map provider for use in the system.
  ///
  StaticMapProvider get provider {
    return _providerData;
  }

  /// Gets the timezone from the location with an api call.
  Future<Location> getTimezoneFromLocation(PlaceLatLong loc, num ms) async {
    var query = <String, String>{
      'location': "${loc.latitude.toString()},${loc.longitude.toString()}",
      'timestamp': ms.toString(),
      'key': _apiKey
    };
    var uri = Uri.https(_urlAuth, _urlPath, query);
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      var responseBody = await response.transform(utf8.decoder).join();
      var data = json.decode(responseBody) as Map<String, dynamic>;
      return getLocation(data['timeZoneId'].toString());
    } else {
      print(await response.transform(utf8.decoder).join());
    }
    return null;
  }

  /// Gets the place and the location for this, doing the lookups to fill in
  /// details.
  Future<LocationAndPlace> getPlaceAndLocation() async {
    var details = await FlutterPlacesDialog.getPlacesDialog();
    var tz = getTimezoneFromLocation(
        details.location, DateTime.now().millisecondsSinceEpoch / 1000);
    return LocationAndPlace(details, tz);
  }
}
