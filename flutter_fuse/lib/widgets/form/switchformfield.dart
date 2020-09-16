import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SwitchFormField extends FormField<bool> {
  SwitchFormField({
    Key key,
    bool initialValue: false,
    bool enabled: true,
    IconData icon,
    String label,
    Widget child,
    ValueChanged<bool> onFieldSubmitted,
    FormFieldSetter<bool> onSaved,
    FormFieldValidator<bool> validator,
  })  : assert(initialValue != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<bool> field) {
            final _SwitchFormFieldState state = field as _SwitchFormFieldState;
            InputDecorationTheme theme =
                Theme.of(field.context).inputDecorationTheme;
            ValueChanged<bool> onChanged = enabled
                ? (bool value) {
                    field.didChange(value);
                    if (onFieldSubmitted != null) {
                      onFieldSubmitted(value);
                    }
                  }
                : null;

            TextStyle textStyle = (theme.labelStyle ?? theme.hintStyle);
            if (!enabled) {
              textStyle = textStyle.copyWith(
                  color: Theme.of(field.context).disabledColor);
            }

            return Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 15.0, right: 30.0),
                  child: Icon(
                    icon,
                    color: _getDefaultIconColor(Theme.of(field.context)),
                  ),
                ),
                Expanded(
                  child: child ??
                      Text(
                        label,
                        style: textStyle,
                      ),
                ),
                Switch(
                  value: state.value,
                  onChanged: onChanged,
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
  _SwitchFormFieldState createState() => _SwitchFormFieldState();
}

class _SwitchFormFieldState extends FormFieldState<bool> {}
