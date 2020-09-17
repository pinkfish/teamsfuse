import 'dart:ui';

import 'package:flutter/cupertino.dart';

///
/// Marker to trace things to display on the map.
///
@immutable
class Marker {
  /// Marker to display on the map.
  Marker(this.id, this.title, this.latitude, this.longitude,
      {this.color = _defaultColor});

  /// Id for the marker.
  final String id;

  /// Title of the marker.
  final String title;

  /// Latitude of the marker.
  final double latitude;

  /// Longitude of the marker.
  final double longitude;

  /// Color to display for the marker.
  final Color color;

  static const Color _defaultColor = Color.fromARGB(1, 255, 0, 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Marker && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Serialize the marker to use in the api.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "title": title,
      "latitude": latitude,
      "longitude": longitude,
      "type": "pin",
      "color": <String, int>{
        "r": color.red,
        "g": color.green,
        "b": color.blue,
        "a": color.alpha
      }
    };
  }
}
