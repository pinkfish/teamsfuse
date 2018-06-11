import 'location.dart';
import 'marker.dart';

class StaticMapProvider {
  final String googleMapsApiKey;
  static const int defaultZoomLevel = 4;
  static const int defaultWidth = 600;
  static const int defaultHeight = 400;

  StaticMapProvider(this.googleMapsApiKey);

  ///
  /// Creates a Uri for the Google Static Maps API
  /// Centers the map on [center] using a zoom of [zoomLevel]
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///

  Uri getStaticUri(MapLocation center, int zoomLevel, {int width, int height}) {
    return _buildUrl(null, center, zoomLevel ?? defaultZoomLevel,
        width ?? defaultWidth, height ?? defaultHeight);
  }

  ///
  /// Creates a Uri for the Google Static Maps API using a list of locations to create pins on the map
  /// [locations] must have at least 1 location
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///

  Uri getStaticUriWithMarkers(List<Marker> markers, {int width, int height}) {
    return _buildUrl(
        markers, null, null, width ?? defaultWidth, height ?? defaultHeight);
  }

  Uri _buildUrl(List<Marker> locations, MapLocation center, int zoomLevel,
      int width, int height) {
    Uri finalUri = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap');

    if (center == null && (locations == null || locations.length == 0)) {
      center = MapLocations.centerOfUSA;
    }

    if (locations == null || locations.length == 0) {
      if (center == null) {
        center = MapLocations.centerOfUSA;
      }
      finalUri = finalUri.replace(queryParameters: <String, dynamic>{
        'center': '${center.latitude},${center.longitude}',
        'zoom': zoomLevel.toString(),
        'size': '${width ?? defaultWidth}x${height ?? defaultHeight}',
        'key': googleMapsApiKey,
      });
    } else {
      List<String> markers = <String>[];
      for (Marker location in locations) {
        num lat = location.latitude;
        num lng = location.longitude;
        String marker = '$lat,$lng';
        markers.add(marker);
      }
      String markersString = markers.join('|');
      finalUri = finalUri.replace(queryParameters: <String, dynamic>{
        'markers': markersString,
        'size': '${width ?? defaultWidth}x${height ?? defaultHeight}',
        'key': googleMapsApiKey,
      });
    }

    return finalUri;
  }
}
