import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../providers/place_provider.dart';
import 'components/floating_card.dart';
import 'models/pick_result.dart';

typedef SelectedPlaceWidgetBuilder = Widget Function(
  BuildContext context,
  PickResult selectedPlace,
  SearchingState state,
  bool isSearchBarFocused,
);

typedef PinBuilder = Widget Function(
  BuildContext context,
  PinState state,
);

class GoogleMapPlacePicker extends StatelessWidget {
  const GoogleMapPlacePicker({
    Key key,
    @required this.initialTarget,
    @required this.appBarKey,
    this.selectedPlaceWidgetBuilder,
    this.onSearchFailed,
    this.onMapCreated,
    this.enableMapTypeButton,
    this.onToggleMapType,
    this.onPlacePicked,
    this.usePlaceDetailSearch,
    this.selectInitialPosition,
    this.language,
    this.forceSearchOnZoomChanged,
    this.hidePlaceDetailsWhenDraggingPin,
  }) : super(key: key);

  final LatLng initialTarget;
  final GlobalKey appBarKey;

  final SelectedPlaceWidgetBuilder selectedPlaceWidgetBuilder;

  final ValueChanged<String> onSearchFailed;
  final MapCreatedCallback onMapCreated;
  final VoidCallback onToggleMapType;
  final ValueChanged<PickResult> onPlacePicked;

  final bool enableMapTypeButton;

  final bool usePlaceDetailSearch;

  final bool selectInitialPosition;

  final String language;

  final bool forceSearchOnZoomChanged;
  final bool hidePlaceDetailsWhenDraggingPin;

  void _searchByCameraLocation(PlaceProvider provider, {LatLng pos}) async {
    //
    // We don't want to search location again if camera location is changed
    // by zooming in/out.
    //
    bool hasZoomChanged = provider.cameraPosition != null &&
        provider.prevCameraPosition != null &&
        provider.cameraPosition.zoom != provider.prevCameraPosition.zoom;

    if (forceSearchOnZoomChanged == false && hasZoomChanged) {
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }

    provider.placeSearchingState = SearchingState.Searching;

    final GeocodingResponse response =
        await provider.geocoding.searchByLocation(
      Location(pos?.latitude ?? provider.cameraPosition.target.latitude,
          pos?.longitude ?? provider.cameraPosition.target.longitude),
      language: language,
    );

    if (response.errorMessage?.isNotEmpty == true ||
        response.status == 'REQUEST_DENIED') {
      if (onSearchFailed != null) {
        onSearchFailed(response.status);
      }
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }

    if (usePlaceDetailSearch) {
      final PlacesDetailsResponse detailResponse =
          await provider.places.getDetailsByPlaceId(
        response.results[0].placeId,
        language: language,
      );

      if (detailResponse.errorMessage?.isNotEmpty == true ||
          detailResponse.status == 'REQUEST_DENIED') {
        if (onSearchFailed != null) {
          onSearchFailed(detailResponse.status);
        }
        provider.placeSearchingState = SearchingState.Idle;
        return;
      }

      provider.selectedPlace =
          PickResult.fromPlaceDetailResult(detailResponse.result);
    } else {
      provider.selectedPlace =
          PickResult.fromGeocodingResult(response.results[0]);
    }

    provider.placeSearchingState = SearchingState.Idle;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildGoogleMap(context),
        _buildFloatingCard(),
        _buildMapIcons(context),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Selector<PlaceProvider, PickResult>(
        selector: (_, provider) => provider.selectedPlace,
        builder: (_, data, __) {
          var provider = PlaceProvider.of(context, listen: false);
          var initialCameraPosition =
              CameraPosition(target: initialTarget, zoom: 15);
          var markers = Set<Marker>.of([]);

          if (provider.selectedPlace != null) {
            var markerUuid = MarkerId(Uuid().v4());

            markers.add(Marker(
              markerId: markerUuid,
              position: LatLng(
                provider.selectedPlace.geometry.location.lat,
                provider.selectedPlace.geometry.location.lng,
              ),
              infoWindow: InfoWindow(
                title: provider.selectedPlace.name ??
                    provider.selectedPlace.formattedAddress,
                snippet: provider.selectedPlace.formattedAddress,
              ),
            ));
          }
          return GoogleMap(
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            initialCameraPosition: initialCameraPosition,
            mapType: provider.mapType,
            myLocationEnabled: true,
            markers: markers,
            onMapCreated: (controller) {
              provider.mapController = controller;
              provider.setCameraPosition(null);

              // When select initialPosition set to true.
              if (selectInitialPosition) {
                provider.setCameraPosition(initialCameraPosition);
                _searchByCameraLocation(provider);
              }
            },

            onTap: (latLng) {
              var newPos = CameraUpdate.newLatLng(latLng);

              provider.mapController.animateCamera(newPos);
              _searchByCameraLocation(provider, pos: latLng);
            },

            // gestureRecognizers make it possible to navigate the map when it's a
            // child in a scroll view e.g ListView, SingleChildScrollView...
            gestureRecognizers: Set()
              ..add(Factory<EagerGestureRecognizer>(
                  () => EagerGestureRecognizer())),
          );
        });
  }

  Widget _buildFloatingCard() {
    return Selector<PlaceProvider, Tuple3<PickResult, SearchingState, bool>>(
      selector: (_, provider) => Tuple3(provider.selectedPlace,
          provider.placeSearchingState, provider.isSearchBarFocused),
      builder: (context, data, __) {
        if ((data.item1 == null && data.item2 == SearchingState.Idle) ||
            data.item3 == true) {
          return Container();
        } else {
          if (selectedPlaceWidgetBuilder == null) {
            return _defaultPlaceWidgetBuilder(context, data.item1, data.item2);
          } else {
            return Builder(
                builder: (builderContext) => selectedPlaceWidgetBuilder(
                    builderContext, data.item1, data.item2, data.item3));
          }
        }
      },
    );
  }

  Widget _defaultPlaceWidgetBuilder(
      BuildContext context, PickResult data, SearchingState state) {
    return FloatingCard(
      bottomPosition: MediaQuery.of(context).size.height * 0.05,
      leftPosition: MediaQuery.of(context).size.width * 0.025,
      rightPosition: MediaQuery.of(context).size.width * 0.025,
      width: MediaQuery.of(context).size.width * 0.9,
      borderRadius: BorderRadius.circular(12.0),
      elevation: 4.0,
      color: Theme.of(context).cardColor,
      child: state == SearchingState.Searching
          ? _buildLoadingIndicator()
          : _buildSelectionDetails(context, data),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 48,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildSelectionDetails(BuildContext context, PickResult result) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            result.formattedAddress,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              'Select here',
              style: TextStyle(fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            onPressed: () {
              onPlacePicked(result);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapIcons(BuildContext context) {
    final RenderBox appBarRenderBox =
        appBarKey.currentContext.findRenderObject();

    return Positioned(
      top: appBarRenderBox.size.height,
      right: 15,
      child: Column(
        children: <Widget>[
          enableMapTypeButton
              ? Container(
                  width: 35,
                  height: 35,
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black54
                        : Colors.white,
                    elevation: 8.0,
                    onPressed: onToggleMapType,
                    child: Icon(Icons.layers),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
