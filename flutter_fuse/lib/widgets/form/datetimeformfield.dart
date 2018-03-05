import 'package:flutter/material.dart';
import 'dart:async';
import 'inputdropdown.dart';
import 'package:tuple/tuple.dart';

class DateTimeUnion extends Tuple2<DateTime, TimeOfDay> {
  DateTimeUnion(DateTime date, TimeOfDay day) : super(date, day);
}

typedef void OnChangedFunc(DateTimeUnion field);

class DateTimeFormField extends FormField<DateTimeUnion> {
  DateTimeFormField({
    Key key,
    DateTimeUnion initialValue: null,
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<DateTimeUnion> onFieldSubmitted,
    FormFieldSetter<DateTimeUnion> onSaved,
    FormFieldValidator<DateTimeUnion> validator,
    this.hideDate,
    this.labelText
  })
      : assert(initialValue != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<DateTimeUnion> state) {
            DateTimeFormFieldState field = state;

            final TextStyle valueStyle = Theme
                .of(field.context)
                .textTheme
                .title;
            List<Widget> children = new List<Widget>();
            if (!hideDate) {
              children.add(new Expanded(
                flex: 4,
                child: new InputDropdown(
                  decoration: new InputDecoration(labelText: labelText),
                  errorText: field.errorText,
                  valueText: MaterialLocalizations.of(field.context).formatMediumDate(
                      field.value.item1),
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
                  valueText: field.value.item2.format(field.context),
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
                  decoration: new InputDecoration(labelText: labelText),
                  valueText: field.value.item2.format(field.context),
                  valueStyle: valueStyle,
                  onPressed: () {
                    field._selectTime(onFieldSubmitted);
                  },
                ),
              ));
            }
            return new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: children
            );
          });

  final String labelText;
  final bool hideDate;

  @override
  DateTimeFormFieldState createState() => new DateTimeFormFieldState();

}


class DateTimeFormFieldState extends FormFieldState<DateTimeUnion> {
  @override
  DateTimeFormField get widget => super.widget;

  Future<Null> _selectDate(ValueChanged<DateTimeUnion> onFieldSubmitted) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: value.item1,
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101)
    );
    if (picked != null && picked != value.item1) {
      onChanged(new DateTimeUnion(picked, value.item2));
      onFieldSubmitted(value);
    }
  }

  Future<Null> _selectTime(ValueChanged<DateTimeUnion> onFieldSubmitted) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: value.item2,
    );
    if (picked != null && picked != value.item2) {
      onChanged(new DateTimeUnion(value.item1, picked));
      onFieldSubmitted(value);
    }
  }
}
