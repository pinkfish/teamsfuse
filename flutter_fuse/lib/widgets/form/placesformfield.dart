import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/map.dart';
import '../../services/messages.dart';
import '../util/inputdropdown.dart';

///
/// The places form field to use to select a specific place
///
class PlacesFormField extends FormField<LocationAndPlace> {
  /// Constructor.
  PlacesFormField(
      {@required LocationAndPlace initialValue,
      Key key,
      InputDecoration decoration = const InputDecoration(),
      ValueChanged<LocationAndPlace> onFieldSubmitted,
      FormFieldSetter<LocationAndPlace> onSaved,
      FormFieldValidator<LocationAndPlace> validator,
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

  static String _renderPlaceName(BuildContext context, LocationAndPlace loc) {
    if (loc.details.name == null || loc.details.name.isEmpty) {
      if (loc.details.address == null || loc.details.address.isEmpty) {
        return Messages.of(context).selectplace;
      }
      return loc.details.address;
    }
    return loc.details.name;
  }

  /// The label text for the form field.
  final String labelText;

  @override
  _PlacesFormFieldState createState() => _PlacesFormFieldState();
}

class _PlacesFormFieldState extends FormFieldState<LocationAndPlace> {
  Future<Null> _selectPlace(
      ValueChanged<LocationAndPlace> onFieldSubmitted) async {
    var picked = await MapData.instance.getPlaceAndLocation();
    if (picked != null) {
      didChange(picked);
      if (onFieldSubmitted != null) {
        onFieldSubmitted(picked);
      }
    }
  }
}
