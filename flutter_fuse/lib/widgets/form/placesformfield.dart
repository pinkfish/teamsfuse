import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/apikeys.dart';
import '../../services/messages.dart';
import '../../util/placepicker/google_maps_place_picker.dart';
import '../../util/webservices/timezone.dart';
import '../util/inputdropdown.dart';

///
/// The place and timezone for use in the place picked.
///
class PlaceAndTimezone {
  final String timeZone;
  final GamePlace place;

  PlaceAndTimezone(this.place, this.timeZone);
}

///
/// The places form field to use to select a specific place
///
class PlacesFormField extends FormField<PlaceAndTimezone> {
  /// Constructor.
  PlacesFormField(
      {@required PlaceAndTimezone initialValue,
      Key key,
      InputDecoration decoration = const InputDecoration(),
      ValueChanged<PlaceAndTimezone> onFieldSubmitted,
      FormFieldSetter<PlaceAndTimezone> onSaved,
      FormFieldValidator<PlaceAndTimezone> validator,
      this.labelText})
      : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (var state) {
              var field = state as _PlacesFormFieldState;

              var valueStyle = Theme.of(field.context).textTheme.headline6;
              var effectiveDecoration = (decoration ??
                      InputDecoration(labelText: labelText))
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme)
                  .copyWith(labelText: labelText);

              var children = <Widget>[];
              children.add(SizedBox(width: 12.0));
              children.add(Expanded(
                flex: 1,
                child: InputDropdown(
                  decoration: effectiveDecoration,
                  errorText: field.errorText,
                  valueText: _renderPlaceName(field.context, field.value),
                  valueStyle: valueStyle,
                  onPressed: () {
                    field._selectPlace(onFieldSubmitted);
                  },
                ),
              ));

              return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: children);
            });

  static String _renderPlaceName(BuildContext context, PlaceAndTimezone loc) {
    if (loc.place.name == null || loc.place.name.isEmpty) {
      if (loc.place.address == null || loc.place.address.isEmpty) {
        return Messages.of(context).selectplace;
      }
      return loc.place.address;
    }
    return loc.place.name;
  }

  /// The label text for the form field.
  final String labelText;

  @override
  _PlacesFormFieldState createState() => _PlacesFormFieldState();
}

class _PlacesFormFieldState extends FormFieldState<PlaceAndTimezone> {
  static final _initialPosition = LatLng(47.6740, 122.1215);
  Future<Null> _selectPlace(
      ValueChanged<PlaceAndTimezone> onFieldSubmitted) async {
    PickResult myResult;
    LatLng loc;
    if (value != null && value.place != null) {
      loc = LatLng(
          value.place.latitude.toDouble(), value.place.longitude.toDouble());
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: googleMapsApiKey, // Put YOUR OWN KEY here.
          onPlacePicked: (result) {
            myResult = result;
            Navigator.of(context).pop();
          },
          initialPosition: loc ?? _initialPosition,
          initialPlaceId: value?.place?.placeId,
          initialAddress: value?.place?.address,
          selectInitialPosition: false,
          searchForInitialValue: loc != null,
          useCurrentLocation: true,
          enableMapTypeButton: true,
          initialMapType: MapType.normal,
        ),
      ),
    );
    if (myResult != null) {
      var newPlace = GamePlace((b) => b
        ..name = myResult.name ?? ''
        ..address = myResult.formattedAddress
        ..placeId = myResult.placeId ?? ''
        ..notes = value?.place?.notes ?? ''
        ..latitude = myResult.geometry.location.lat
        ..longitude = myResult.geometry.location.lng);
      // Get the timezone name for the location.
      var tzReader = GoogleMapsTimezone(
        apiKey: googleMapsApiKey,
      );
      var result = await tzReader.getByLocation(myResult.geometry.location);
      var tzId = result.result.timeZoneId;
      didChange(PlaceAndTimezone(newPlace, tzId));
      if (onFieldSubmitted != null) {
        onFieldSubmitted(PlaceAndTimezone(newPlace, tzId));
      }
    }
  }
}
