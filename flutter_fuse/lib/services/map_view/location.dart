class MapLocation {
  factory MapLocation.fromMap(Map<String, double> map) {
    return MapLocation(map["latitude"], map["longitude"]);
  }

  const MapLocation(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  Map<String, double> toMap() {
    return <String, double>{"latitude": latitude, "longitude": longitude};
  }

  @override
  String toString() {
    return 'MapLocation{latitude: $latitude, longitude: $longitude}';
  }
}

class MapLocations {
  static MapLocation portland = MapLocation(45.512794, -122.679565);
  static MapLocation centerOfUSA = MapLocation(37.0902, -95.7192);
}
