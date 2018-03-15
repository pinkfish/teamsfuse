import 'package:flutter/material.dart';

class InputDropdown extends StatelessWidget {
  const InputDropdown(
      {Key key,
      this.decoration,
      this.child,
      this.errorText,
      this.valueText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);
  final String valueText;
  final String errorText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: decoration.copyWith(errorText: errorText),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }
}
