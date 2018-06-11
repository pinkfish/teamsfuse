class MapLocation {
  final double latitude;
  final double longitude;

  const MapLocation(this.latitude, this.longitude);
  factory MapLocation.fromMap(Map<String, double> map) {
    return new MapLocation(map["latitude"], map["longitude"]);
  }

  Map<String, double> toMap() {
    return <String, double>{"latitude": latitude, "longitude": longitude};
  }

  @override
  String toString() {
    return 'MapLocation{latitude: $latitude, longitude: $longitude}';
  }
}

class MapLocations {
  static MapLocation portland = new MapLocation(45.512794, -122.679565);
  static MapLocation centerOfUSA = new MapLocation(37.0902, -95.7192);
}
