import 'package:flutter/material.dart';
import 'dart:async';
import 'inputdropdown.dart';

typedef void OnChangedFunc(DateTime field);

class DateTimeFormField extends FormField<DateTime> {
  DateTimeFormField(
      {Key key,
      DateTime initialValue,
      InputDecoration decoration: const InputDecoration(),
      ValueChanged<DateTime> onFieldSubmitted,
      FormFieldSetter<DateTime> onSaved,
      FormFieldValidator<DateTime> validator,
      this.hideDate,
      this.labelText})
      : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (FormFieldState<DateTime> state) {
              DateTimeFormFieldState field = state;

              final TextStyle valueStyle =
                  Theme.of(field.context).textTheme.title;
              final InputDecoration effectiveDecoration = (decoration ??
                  new InputDecoration(labelText: labelText))
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);

              List<Widget> children = new List<Widget>();
              if (!hideDate) {
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
                      field._selectDate(onFieldSubmitted);
                    },
                  ),
                ));
                children.add(const SizedBox(width: 12.0));
                children.add(new Expanded(
                  flex: 3,
                  child: new InputDropdown(
                    valueText:
                        new TimeOfDay.fromDateTime(field.value).format(field.context),
                    decoration: new InputDecoration(),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectTime(onFieldSubmitted);
                    },
                  ),
                ));
              } else {
                children.add(new Expanded(
                  flex: 1,
                  child: new InputDropdown(
                    decoration: effectiveDecoration,
                    valueText:
                        new TimeOfDay.fromDateTime(field.value).format(field.context),
                    valueStyle: valueStyle,
                    onPressed: () {
                      field._selectTime(onFieldSubmitted);
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

  @override
  DateTimeFormFieldState createState() => new DateTimeFormFieldState();
}

class DateTimeFormFieldState extends FormFieldState<DateTime> {
  @override
  DateTimeFormField get widget => super.widget;

  Future<Null> _selectDate(ValueChanged<DateTime> onFieldSubmitted) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101));
    if (picked != null &&
        (picked.day != value.day ||
            picked.month != value.month ||
            picked.year != value.year)) {
      DateTime newTime = new DateTime(
          picked.year, picked.month, picked.day, value.hour, value.minute);

      onChanged(newTime);
      onFieldSubmitted(newTime);
    }
  }

  Future<Null> _selectTime(ValueChanged<DateTime> onFieldSubmitted) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: new TimeOfDay.fromDateTime(value),
    );
    if (picked != null &&
        (picked.minute != this.value.minute || picked.hour != value.hour)) {
      DateTime newTime = new DateTime(
          value.year, value.month, value.day, picked.hour, picked.minute);
      onChanged(newTime);
      if (onFieldSubmitted != null) {
        onFieldSubmitted(newTime);
      }
    }
  }
}
