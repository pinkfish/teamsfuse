import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../util/numberpicker.dart';

///
/// Shows a number picker in a form.
///
class NumberPickerFormField extends FormField<num> {
  /// Constructor.
  NumberPickerFormField({
    Key key,
    num initialValue = 0,
    num minValue = 0,
    num maxValue = 1000,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<num> onFieldSubmitted,
    FormFieldSetter<num> onSaved,
    FormFieldValidator<num> validator,
  })  : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (field) {
              var state = field as _NumberPickerFormFieldState;
              var effectiveDecoration = (decoration ?? const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return InputDecorator(
                  decoration:
                      effectiveDecoration.copyWith(errorText: field.errorText),
                  child: NumberPicker.integer(
                      initialValue: state.value.toInt(),
                      minValue: minValue.toInt(),
                      maxValue: maxValue.toInt(),
                      onChanged: (value) {
                        field.didChange(value);
                        onFieldSubmitted(value);
                      }));
            });

  @override
  _NumberPickerFormFieldState createState() => _NumberPickerFormFieldState();
}

class _NumberPickerFormFieldState extends FormFieldState<num> {}
