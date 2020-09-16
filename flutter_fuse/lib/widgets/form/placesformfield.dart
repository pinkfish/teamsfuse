import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/inputdropdown.dart';

class PlacesFormField extends FormField<LocationAndPlace> {
  PlacesFormField(
      {@required LocationAndPlace initialValue,
      Key key,
      InputDecoration decoration: const InputDecoration(),
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
            builder: (FormFieldState<LocationAndPlace> state) {
              PlacesFormFieldState field = state as PlacesFormFieldState;

              final TextStyle valueStyle =
                  Theme.of(field.context).textTheme.title;
              final InputDecoration effectiveDecoration = (decoration ??
                      InputDecoration(labelText: labelText))
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme)
                  .copyWith(labelText: labelText);

              List<Widget> children = <Widget>[];
              children.add(const SizedBox(width: 12.0));
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

  final String labelText;

  @override
  PlacesFormFieldState createState() => PlacesFormFieldState();
}

class PlacesFormFieldState extends FormFieldState<LocationAndPlace> {
  Future<Null> _selectPlace(
      ValueChanged<LocationAndPlace> onFieldSubmitted) async {
    final LocationAndPlace picked =
        await MapData.instance.getPlaceAndLocation();
    if (picked != null) {
      didChange(picked);
      if (onFieldSubmitted != null) {
        onFieldSubmitted(picked);
      }
    }
  }
}
