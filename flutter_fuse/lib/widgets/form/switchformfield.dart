import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class SwitchFormField extends FormField<bool> {
  SwitchFormField({
    Key key,
    bool initialValue: false,
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<bool> onFieldSubmitted,
    FormFieldSetter<bool> onSaved,
    FormFieldValidator<bool> validator,
  })
      : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (FormFieldState<bool> field) {
              final _SwitchFormFieldState state = field;
              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return new InputDecorator(
                  decoration:
                      effectiveDecoration.copyWith(errorText: field.errorText),
                  child: new Switch(
                      value: state.value,
                      onChanged: (bool value) {
                        field.onChanged(value);
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted(value);
                        }
                      }));
            });

  @override
  _SwitchFormFieldState createState() => new _SwitchFormFieldState();
}

class _SwitchFormFieldState extends FormFieldState<bool> {
  @override
  SwitchFormField get widget => super.widget;
}
