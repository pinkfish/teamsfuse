import 'dart:async';

import 'package:flutter/material.dart';

import '../util/inputdropdown.dart';

///
/// Form field to allow for the date/time to be selected and updated.
///
class DateTimeFormField extends FormField<DateTime> {
  /// Constructor.
  DateTimeFormField(
      {@required DateTime initialValue,
      Key key,
      InputDecoration decoration = const InputDecoration(),
      ValueChanged<DateTime> onFieldSubmitted,
      ValueChanged<Duration> onFieldChanged,
      FormFieldSetter<DateTime> onSaved,
      FormFieldValidator<DateTime> validator,
      this.hideDate = false,
      this.hideTime = false,
      this.labelText})
      : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (state) {
              var field = state as DateTimeFormFieldState;

              var valueStyle = Theme.of(field.context).textTheme.headline6;
              var effectiveDecoration = (decoration ??
                      InputDecoration(labelText: labelText))
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme)
                  .copyWith(labelText: labelText);
              print('label ${effectiveDecoration.labelText} $labelText');

              var children = <Widget>[];
              if (!hideDate && !hideTime) {
                children.add(Expanded(
                  flex: 4,
                  child: InputDropdown(
                    decoration: effectiveDecoration,
                    errorText: field.errorText,
                    valueText: MaterialLocalizations.of(field.context)
                        .formatMediumDate(field.value),
                    valueStyle: valueStyle.copyWith(fontSize: 17.0),
                    onPressed: () {
                      field._selectDate(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
                children.add(const SizedBox(width: 12.0));
                children.add(Expanded(
                  flex: 3,
                  child: InputDropdown(
                    valueText: TimeOfDay(
                      hour: field.value.hour,
                      minute: field.value.minute,
                    ).format(field.context),
                    decoration: InputDecoration(),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectTime(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
              } else if (hideTime) {
                children.add(Expanded(
                  flex: 1,
                  child: InputDropdown(
                    decoration: effectiveDecoration,
                    errorText: field.errorText,
                    valueText: MaterialLocalizations.of(field.context)
                        .formatMediumDate(field.value),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectDate(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
              } else {
                children.add(Expanded(
                  flex: 1,
                  child: InputDropdown(
                    decoration: effectiveDecoration,
                    valueText: TimeOfDay(
                            hour: field.value.hour, minute: field.value.minute)
                        .format(field.context),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectTime(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
              }

              return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: children);
            });

  /// The label to show on the field.
  final String labelText;

  /// If we should hide the date.
  final bool hideDate;

  /// If we shuold hide the time.
  final bool hideTime;

  @override
  DateTimeFormFieldState createState() => DateTimeFormFieldState();
}

///
/// The state to handle the datetime form field.
///
class DateTimeFormFieldState extends FormFieldState<DateTime> {
  @override
  DateTimeFormField get widget {
    var val = super.widget as DateTimeFormField;
    return val;
  }

  ///
  /// Update the value of the date/time to be this.
  ///
  void updateValue(DateTime val) {
    setValue(val);
  }

  Future<Null> _selectDate(ValueChanged<DateTime> onFieldSubmitted,
      ValueChanged<Duration> onFieldChanged) async {
    var picked = await showDatePicker(
        context: context,
        initialDate: DateTime(value.year, value.month, value.day),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null &&
        (picked.day != value.day ||
            picked.month != value.month ||
            picked.year != value.year)) {
      var newTime = DateTime(
          picked.year, picked.month, picked.day, value.hour, value.minute);
      var diff = value.difference(newTime);

      didChange(newTime);
      if (onFieldSubmitted != null) {
        onFieldSubmitted(newTime);
      }
      if (onFieldChanged != null) {
        onFieldChanged(diff);
      }
    }
  }

  Future<Null> _selectTime(ValueChanged<DateTime> onFieldSubmitted,
      ValueChanged<Duration> onFieldChanged) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (picked != null &&
        (picked.minute != value.minute || picked.hour != value.hour)) {
      var newTime = DateTime(
          value.year, value.month, value.day, picked.hour, picked.minute);
      var diff = value.difference(newTime);
      didChange(newTime);
      if (onFieldSubmitted != null) {
        onFieldSubmitted(newTime);
      }
      if (onFieldChanged != null) {
        onFieldChanged(diff);
      }
    }
  }
}
