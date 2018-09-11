import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class InputDropdown extends StatelessWidget {
  const InputDropdown(
      {@required this.decoration,
      @required this.valueText,
      Key key,
      this.errorText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);
  final String valueText;
  final String errorText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
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
            new Flexible(
            child: new Text(
              valueText,
              style: valueStyle,
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
            ),
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
