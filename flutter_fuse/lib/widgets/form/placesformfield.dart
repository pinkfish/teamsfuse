import 'package:flutter/material.dart';
import 'dart:async';
import 'inputdropdown.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/messages.dart';

class PlacesFormField extends FormField<LocationAndPlace> {
  PlacesFormField(
      {Key key,
      LocationAndPlace initialValue,
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
              PlacesFormFieldState field = state;

              final TextStyle valueStyle =
                  Theme.of(field.context).textTheme.title;
              final InputDecoration effectiveDecoration = (decoration ??
                      new InputDecoration(labelText: labelText))
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme)
                  .copyWith(labelText: labelText);

              List<Widget> children = new List<Widget>();
              children.add(const SizedBox(width: 12.0));
              children.add(new Expanded(
                flex: 1,
                child: new InputDropdown(
                  decoration: effectiveDecoration,
                  errorText: field.errorText,
                  valueText: _renderPlaceName(field.context, field.value),
                  valueStyle: valueStyle,
                  onPressed: () {
                    field._selectPlace(onFieldSubmitted);
                  },
                ),
              ));

              return new Row(
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
  PlacesFormFieldState createState() => new PlacesFormFieldState();
}

class PlacesFormFieldState extends FormFieldState<LocationAndPlace> {
  @override
  PlacesFormField get widget => super.widget;

  Future<Null> _selectPlace(
      ValueChanged<LocationAndPlace> onFieldSubmitted) async {
    final LocationAndPlace picked =
        await MapData.instance.getPlaceAndLocation();
    if (picked != null) {
      onChanged(picked);
      if (onFieldSubmitted != null) {
        onFieldSubmitted(picked);
      }
    }
  }
}
