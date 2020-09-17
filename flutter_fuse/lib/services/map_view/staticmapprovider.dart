import 'location.dart';
import 'marker.dart';

///
/// Static map provider to display google maps in the app.
///
class StaticMapProvider {
  /// Creating the map provider.
  StaticMapProvider(this._googleMapsApiKey);

  final String _googleMapsApiKey;
  static const int _defaultZoomLevel = 4;
  static const int _defaultWidth = 600;
  static const int _defaultHeight = 400;

  ///
  /// Creates a Uri for the Google Static Maps API
  /// Centers the map on [center] using a zoom of [zoomLevel]
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///

  Uri getStaticUri(MapLocation center, int zoomLevel, {int width, int height}) {
    return _buildUrl(null, center, zoomLevel ?? _defaultZoomLevel,
        width ?? _defaultWidth, height ?? _defaultHeight);
  }

  ///
  /// Creates a Uri for the Google Static Maps API using a list of locations to create pins on the map
  /// [locations] must have at least 1 location
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///

  Uri getStaticUriWithMarkers(List<Marker> markers, {int width, int height}) {
    return _buildUrl(
        markers, null, null, width ?? _defaultWidth, height ?? _defaultHeight);
  }

  Uri _buildUrl(List<Marker> locations, MapLocation center, int zoomLevel,
      int width, int height) {
    var finalUri = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap');

    if (center == null && (locations == null || locations.length == 0)) {
      center = centerOfUSA;
    }

    if (locations == null || locations.length == 0) {
      if (center == null) {
        center = centerOfUSA;
      }
      finalUri = finalUri.replace(queryParameters: <String, dynamic>{
        'center': '${center.latitude},${center.longitude}',
        'zoom': zoomLevel.toString(),
        'size': '${width ?? _defaultWidth}x${height ?? _defaultHeight}',
        'key': _googleMapsApiKey,
      });
    } else {
      var markers = <String>[];
      for (var location in locations) {
        num lat = location.latitude;
        num lng = location.longitude;
        var marker = '$lat,$lng';
        markers.add(marker);
      }
      var markersString = markers.join('|');
      finalUri = finalUri.replace(queryParameters: <String, dynamic>{
        'markers': markersString,
        'size': '${width ?? _defaultWidth}x${height ?? _defaultHeight}',
        'key': _googleMapsApiKey,
      });
    }

    return finalUri;
  }
}
