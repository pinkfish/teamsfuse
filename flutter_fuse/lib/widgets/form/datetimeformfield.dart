import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/inputdropdown.dart';

class DateTimeFormField extends FormField<TZDateTime> {
  DateTimeFormField(
      {Key key,
      TZDateTime initialValue,
      InputDecoration decoration: const InputDecoration(),
      ValueChanged<TZDateTime> onFieldSubmitted,
      ValueChanged<Duration> onFieldChanged,
      FormFieldSetter<TZDateTime> onSaved,
      FormFieldValidator<TZDateTime> validator,
      this.hideDate = false,
      this.hideTime = false,
      this.labelText})
      : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (FormFieldState<TZDateTime> state) {
              DateTimeFormFieldState field = state;

              final TextStyle valueStyle =
                  Theme.of(field.context).textTheme.title;
              final InputDecoration effectiveDecoration = (decoration ??
                      new InputDecoration(labelText: labelText))
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme)
                  .copyWith(labelText: labelText);
              print('label ${effectiveDecoration.labelText} $labelText');

              List<Widget> children = new List<Widget>();
              if (!hideDate && !hideTime) {
                children.add(new Expanded(
                  flex: 4,
                  child: new InputDropdown(
                    decoration: effectiveDecoration,
                    errorText: field.errorText,
                    valueText: MaterialLocalizations
                        .of(field.context)
                        .formatMediumDate(field.value),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectDate(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
                children.add(const SizedBox(width: 12.0));
                children.add(new Expanded(
                  flex: 3,
                  child: new InputDropdown(
                    valueText: new TimeOfDay(
                            hour: field.value.hour, minute: field.value.minute)
                        .format(field.context),
                    decoration: new InputDecoration(),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectTime(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
              } else if (hideTime) {
                children.add(new Expanded(
                  flex: 1,
                  child: new InputDropdown(
                    decoration: effectiveDecoration,
                    errorText: field.errorText,
                    valueText: MaterialLocalizations
                        .of(field.context)
                        .formatMediumDate(field.value),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectDate(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
              } else {
                children.add(new Expanded(
                  flex: 1,
                  child: new InputDropdown(
                    decoration: effectiveDecoration,
                    valueText: new TimeOfDay(
                            hour: field.value.hour, minute: field.value.minute)
                        .format(field.context),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectTime(onFieldSubmitted, onFieldChanged);
                    },
                  ),
                ));
              }

              return new Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: children);
            });

  final String labelText;
  final bool hideDate;
  final bool hideTime;

  @override
  DateTimeFormFieldState createState() => new DateTimeFormFieldState();
}

class DateTimeFormFieldState extends FormFieldState<TZDateTime> {
  @override
  DateTimeFormField get widget => super.widget;

  void updateValue(TZDateTime val) {
    setValue(val);
  }

  Future<Null> _selectDate(ValueChanged<TZDateTime> onFieldSubmitted,
      ValueChanged<Duration> onFieldChanged) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime(value.year, value.month, value.day),
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101));
    if (picked != null &&
        (picked.day != value.day ||
            picked.month != value.month ||
            picked.year != value.year)) {
      TZDateTime newTime = new TZDateTime(value.location, picked.year,
          picked.month, picked.day, value.hour, value.minute);
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

  Future<Null> _selectTime(ValueChanged<TZDateTime> onFieldSubmitted,
      ValueChanged<Duration> onFieldChanged) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: new TimeOfDay.fromDateTime(value),
    );
    if (picked != null &&
        (picked.minute != this.value.minute || picked.hour != value.hour)) {
      TZDateTime newTime = new TZDateTime(value.location, value.year,
          value.month, value.day, picked.hour, picked.minute);
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
