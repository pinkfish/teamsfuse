import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class SwitchFormField extends FormField<bool> {
  SwitchFormField({
    Key key,
    bool initialValue: false,
    IconData icon,
    String label,
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
            InputDecorationTheme theme =
                Theme.of(field.context).inputDecorationTheme;
            return new Row(
              children: <Widget>[
                new Icon(
                  icon,
                  color: _getDefaultIconColor(Theme.of(field.context)),
                ),
                new Expanded(
                  child: new Text(
                    label,
                    style: theme.prefixStyle ?? theme.hintStyle,
                  ),
                ),
                new Switch(
                  value: state.value,
                  onChanged: (bool value) {
                    field.didChange(value);
                    if (onFieldSubmitted != null) {
                      onFieldSubmitted(value);
                    }
                  },
                ),
              ],
            );
          },
        );

  static Color _getDefaultIconColor(ThemeData themeData) {
    switch (themeData.brightness) {
      case Brightness.dark:
        return Colors.white70;
      case Brightness.light:
        return Colors.black45;
      default:
        return themeData.iconTheme.color;
    }
  }

  @override
  _SwitchFormFieldState createState() => new _SwitchFormFieldState();
}

class _SwitchFormFieldState extends FormFieldState<bool> {
  @override
  SwitchFormField get widget => super.widget;
}
