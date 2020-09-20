import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// A drop down button with an input section.
///
class InputDropdown extends StatelessWidget {
  /// COnstructor.
  const InputDropdown(
      {@required this.decoration,
      @required this.valueText,
      Key key,
      this.errorText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);

  /// The current value of the button.
  final String valueText;

  /// Error to display if there is an error.
  final String errorText;

  /// The style to use for the value.
  final TextStyle valueStyle;

  /// What to do when the button is pressed.
  final VoidCallback onPressed;

  /// The decoration to use on the input.
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: decoration.copyWith(errorText: errorText),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                valueText,
                style: valueStyle,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ),
            Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }
}
