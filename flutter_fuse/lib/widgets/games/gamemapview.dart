import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Displays the map associated with the game on the screen.
///
class GameMapView extends StatefulWidget {
  /// The game to display the map for.
  final GameSharedData game;

  /// Construct a game map view.
  GameMapView(this.game);

  @override
  State<GameMapView> createState() => _GameMapViewState();
}

class _GameMapViewState extends State<GameMapView> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.game.place.latitude.toDouble(),
          widget.game.place.longitude.toDouble(),
        ),
        zoom: 14.4746,
      ),
      markers: <Marker>{
        Marker(
            markerId: MarkerId(widget.game.uid),
            infoWindow: InfoWindow(
                title: widget.game.place.name,
                snippet: widget.game.place.address + widget.game.place.notes),
            position: LatLng(widget.game.place.latitude.toDouble(),
                widget.game.place.longitude.toDouble())),
      },
      myLocationButtonEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
