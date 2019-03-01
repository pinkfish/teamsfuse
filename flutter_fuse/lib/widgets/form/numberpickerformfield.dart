import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fuse/widgets/util/numberpicker.dart';

class NumberPickerFormField extends FormField<num> {
  NumberPickerFormField({
    Key key,
    num initialValue: 0,
    num minValue: 0,
    num maxValue: 1000,
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<num> onFieldSubmitted,
    FormFieldSetter<num> onSaved,
    FormFieldValidator<num> validator,
  })  : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (FormFieldState<num> field) {
              final NumberPickerFormFieldState state =
                  field as NumberPickerFormFieldState;
              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return new InputDecorator(
                  decoration:
                      effectiveDecoration.copyWith(errorText: field.errorText),
                  child: new NumberPicker.integer(
                      initialValue: state.value.toInt(),
                      minValue: minValue.toInt(),
                      maxValue: maxValue.toInt(),
                      onChanged: (num value) {
                        field.didChange(value);
                        onFieldSubmitted(value);
                      }));
            });

  @override
  NumberPickerFormFieldState createState() => new NumberPickerFormFieldState();
}

class NumberPickerFormFieldState extends FormFieldState<num> {}
