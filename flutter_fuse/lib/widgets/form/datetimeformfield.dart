import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/util/inputdropdown.dart';

class DateTimeFormField extends FormField<DateTime> {
  DateTimeFormField(
      {@required DateTime initialValue,
      Key key,
      InputDecoration decoration: const InputDecoration(),
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
            builder: (FormFieldState<DateTime> state) {
              DateTimeFormFieldState field = state as DateTimeFormFieldState;

              final TextStyle valueStyle =
                  Theme.of(field.context).textTheme.title;
              final InputDecoration effectiveDecoration = (decoration ??
                      InputDecoration(labelText: labelText))
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme)
                  .copyWith(labelText: labelText);
              print('label ${effectiveDecoration.labelText} $labelText');

              List<Widget> children = <Widget>[];
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

  final String labelText;
  final bool hideDate;
  final bool hideTime;

  @override
  DateTimeFormFieldState createState() => DateTimeFormFieldState();
}

class DateTimeFormFieldState extends FormFieldState<DateTime> {
  @override
  DateTimeFormField get widget {
    DateTimeFormField val = super.widget as DateTimeFormField;
    return val;
  }

  void updateValue(DateTime val) {
    setValue(val);
  }

  Future<Null> _selectDate(ValueChanged<DateTime> onFieldSubmitted,
      ValueChanged<Duration> onFieldChanged) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime(value.year, value.month, value.day),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null &&
        (picked.day != value.day ||
            picked.month != value.month ||
            picked.year != value.year)) {
      DateTime newTime = DateTime(
          picked.year, picked.month, picked.day, value.hour, value.minute);
      Duration diff = value.difference(newTime);

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
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (picked != null &&
        (picked.minute != value.minute || picked.hour != value.hour)) {
      DateTime newTime = DateTime(
          value.year, value.month, value.day, picked.hour, picked.minute);
      Duration diff = value.difference(newTime);
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
