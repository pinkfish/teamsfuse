///
/// The map location to use.
///
class MapLocation {
  /// Create the map from a serialized version of the data.
  factory MapLocation.fromMap(Map<String, double> map) {
    return MapLocation(map["latitude"], map["longitude"]);
  }

  /// Construct a map with the specific lat and long.
  const MapLocation(this.latitude, this.longitude);

  /// Latitude of the map location.
  final double latitude;

  /// Longitude of the map location.
  final double longitude;

  /// Serialize the entry.
  Map<String, double> toMap() {
    return <String, double>{"latitude": latitude, "longitude": longitude};
  }

  @override
  String toString() {
    return 'MapLocation{latitude: $latitude, longitude: $longitude}';
  }
}

/// Location of portland.
const MapLocation portland = MapLocation(45.512794, -122.679565);

/// Location of the middle of the us.
const MapLocation centerOfUSA = MapLocation(37.0902, -95.7192);
