// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

const TextStyle _kStepStyle = const TextStyle(
  fontSize: 12.0,
  color: Colors.white,
);
const Color _kErrorLight = Colors.red;
final Color _kErrorDark = Colors.red.shade400;
const Color _kCircleActiveLight = Colors.white;
const Color _kCircleActiveDark = Colors.black87;
const Color _kDisabledLight = Colors.black38;
const Color _kDisabledDark = Colors.white30;
const double _kStepSize = 24.0;
const double _kTriangleHeight =
    _kStepSize * 0.866025; // Triangle height. sqrt(3.0) / 2.0

/// A material stepper widget that displays progress through a sequence of
/// steps. Steppers are particularly useful in the case of forms where one step
/// requires the completion of another one, or where multiple steps need to be
/// completed in order to submit the whole form.
///
/// The widget is a flexible wrapper. A parent class should pass [currentStep]
/// to this widget based on some logic triggered by the three callbacks that it
/// provides.
///
/// See also:
///
///  * [Step]
///  * <https://material.google.com/components/steppers.html>
class StepperAlwaysVisible extends StatefulWidget {
  /// Creates a stepper from a list of steps.
  ///
  /// This widget is not meant to be rebuilt with a different list of steps
  /// unless a key is provided in order to distinguish the old stepper from the
  /// new one.
  ///
  /// The [steps], [type], and [currentStep] arguments must not be null.
  StepperAlwaysVisible({
    @required this.steps,
    Key key,
    this.type: StepperType.vertical,
    this.currentStep: 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
  })  : assert(steps != null),
        assert(type != null),
        assert(currentStep != null),
        assert(0 <= currentStep && currentStep < steps.length),
        super(key: key);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [steps] must not change.
  final List<Step> steps;

  /// The type of stepper that determines the layout. In the case of
  /// [StepperType.horizontal], the content of the current step is displayed
  /// underneath as opposed to the [StepperType.vertical] case where it is
  /// displayed in-between.
  final StepperType type;

  /// The index into [steps] of the current step whose content is displayed.
  final int currentStep;

  /// The callback called when a step is tapped, with its index passed as
  /// an argument.
  final ValueChanged<int> onStepTapped;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback onStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback onStepCancel;

  @override
  _StepperAlwaysVisibleState createState() => new _StepperAlwaysVisibleState();
}

class _StepperAlwaysVisibleState extends State<StepperAlwaysVisible>
    with TickerProviderStateMixin {
  List<GlobalKey> _keys;
  final Map<int, StepState> _oldStates = <int, StepState>{};

  @override
  void initState() {
    super.initState();
    _keys = new List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => new GlobalKey(),
    );

 
    for (int i = 0; i < widget.steps.length; i += 1) {
      _oldStates[i] = widget.steps[i].state;
    }
  }

  @override
  void didUpdateWidget(StepperAlwaysVisible oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.steps.length == oldWidget.steps.length);

    for (int i = 0; i < oldWidget.steps.length; i += 1) {
      _oldStates[i] = oldWidget.steps[i].state;
    }

    if (oldWidget.currentStep != widget.currentStep) {
      // Make sure we scroll the list view to make this step
      // visible.

    }
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return widget.currentStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget _buildLine(bool visible) {
    return new Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildCircleChild(int index, bool oldState) {
    final StepState state =
        oldState ? _oldStates[index] : widget.steps[index].state;
    final bool isDarkActive = _isDark() && widget.steps[index].isActive;
    assert(state != null);
    switch (state) {
      case StepState.indexed:
      case StepState.disabled:
        return new Text(
          '${index + 1}',
          style: isDarkActive
              ? _kStepStyle.copyWith(color: Colors.black87)
              : _kStepStyle,
        );
      case StepState.editing:
        return new Icon(
          Icons.edit,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
        );
      case StepState.complete:
        return new Icon(
          Icons.check,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
        );
      case StepState.error:
        return const Text('!', style: _kStepStyle);
    }
    return null;
  }

  Color _circleColor(int index) {
    final ThemeData themeData = Theme.of(context);
    if (!_isDark()) {
      return widget.steps[index].isActive
          ? themeData.primaryColor
          : Colors.black38;
    } else {
      return widget.steps[index].isActive
          ? themeData.accentColor
          : themeData.backgroundColor;
    }
  }

  Widget _buildCircle(int index, bool oldState) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: new AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        decoration: new BoxDecoration(
          color: _circleColor(index),
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: _buildCircleChild(
              index, oldState && widget.steps[index].state == StepState.error),
        ),
      ),
    );
  }

  Widget _buildTriangle(int index, bool oldState) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: new Center(
        child: new SizedBox(
          width: _kStepSize,
          height:
              _kTriangleHeight, // Height of 24dp-long-sided equilateral triangle.
          child: new CustomPaint(
            painter: new _TrianglePainter(
              color: _isDark() ? _kErrorDark : _kErrorLight,
            ),
            child: new Align(
              alignment: const Alignment(
                  0.0, 0.8), // 0.8 looks better than the geometrical 0.33.
              child: _buildCircleChild(index,
                  oldState && widget.steps[index].state != StepState.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    if (widget.steps[index].state != _oldStates[index]) {
      return new AnimatedCrossFade(
        firstChild: _buildCircle(index, true),
        secondChild: _buildTriangle(index, true),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState: widget.steps[index].state == StepState.error
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    } else {
      if (widget.steps[index].state != StepState.error)
        return _buildCircle(index, false);
      else
        return _buildTriangle(index, false);
    }
  }

  Widget _buildVerticalControls() {
    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    assert(cancelColor != null);

    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return new Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: new ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 48.0),
        child: new Row(
          children: <Widget>[
            new FlatButton(
              onPressed: widget.onStepContinue,
              color: _isDark()
                  ? themeData.backgroundColor
                  : themeData.primaryColor,
              textColor: Colors.white,
              textTheme: ButtonTextTheme.normal,
              child: new Text(localizations.continueButtonLabel),
            ),
            new Container(
              margin: const EdgeInsetsDirectional.only(start: 8.0),
              child: new FlatButton(
                onPressed: widget.onStepCancel,
                textColor: cancelColor,
                textTheme: ButtonTextTheme.normal,
                child: new Text(localizations.cancelButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case StepState.indexed:
      case StepState.editing:
      case StepState.complete:
        return textTheme.body2;
      case StepState.disabled:
        return textTheme.body2
            .copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case StepState.error:
        return textTheme.body2
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  TextStyle _subtitleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case StepState.indexed:
      case StepState.editing:
      case StepState.complete:
        return textTheme.caption;
      case StepState.disabled:
        return textTheme.caption
            .copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case StepState.error:
        return textTheme.caption
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  Widget _buildHeaderText(int index) {
    final List<Widget> children = <Widget>[
      new AnimatedDefaultTextStyle(
        style: _titleStyle(index),
        duration: kThemeAnimationDuration,
        curve: Curves.fastOutSlowIn,
        child: widget.steps[index].title,
      ),
    ];

    if (widget.steps[index].subtitle != null)
      children.add(
        new Container(
          margin: const EdgeInsets.only(top: 2.0),
          child: new AnimatedDefaultTextStyle(
            style: _subtitleStyle(index),
            duration: kThemeAnimationDuration,
            curve: Curves.fastOutSlowIn,
            child: widget.steps[index].subtitle,
          ),
        ),
      );

    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children);
  }

  Widget _buildVerticalHeader(int index) {
    return new Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: new SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: new Row(children: <Widget>[
              new Column(children: <Widget>[
                // Line parts are always added in order for the ink splash to
                // flood the tips of the connector lines.
                _buildLine(!_isFirst(index)),
                _buildIcon(index),
                _buildLine(!_isLast(index)),
              ]),
              new Container(
                  margin: const EdgeInsetsDirectional.only(start: 12.0),
                  child: _buildHeaderText(index))
            ])));
  }

  Widget _buildVerticalBody(int index) {
    return new Stack(
      children: <Widget>[
        new PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: new SizedBox(
            width: 24.0,
            child: new Center(
              child: new SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: new Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        new AnimatedCrossFade(
          firstChild: new Container(height: 0.0),
          secondChild: new Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: new Column(
              children: <Widget>[
                widget.steps[index].content,
                _buildVerticalControls(),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isCurrent(index)
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(new Column(key: _keys[i], children: <Widget>[
        new InkWell(
            onTap: widget.steps[i].state != StepState.disabled
                ? () {
                    // In the vertical case we need to scroll to the newly tapped
                    // step.
                    Scrollable.ensureVisible(
                      _keys[i].currentContext,
                      curve: Curves.fastOutSlowIn,
                      duration: kThemeAnimationDuration,
                    );

                    if (widget.onStepTapped != null) {
                      widget.onStepTapped(i);
                    }
                  }
                : null,
            child: _buildVerticalHeader(i)),
        _buildVerticalBody(i)
      ]));
    }

    return new ListView(
      shrinkWrap: true,
      children: children,
    );
  }

  Widget _buildHorizontal() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(
        new InkResponse(
          onTap: widget.steps[i].state != StepState.disabled
              ? () {
                  if (widget.onStepTapped != null) {
                    widget.onStepTapped(i);
                  }
                }
              : null,
          child: new Row(
            children: <Widget>[
              new Container(
                height: 72.0,
                child: new Center(
                  child: _buildIcon(i),
                ),
              ),
              new Container(
                margin: const EdgeInsetsDirectional.only(start: 12.0),
                child: _buildHeaderText(i),
              ),
            ],
          ),
        ),
      );

      if (!_isLast(i)) {
        children.add(
          /*new Expanded(
            child: */new Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 1.0,
              color: Colors.grey.shade400,
            ),
          //),
        );
      }
    }

    return new Column(
      children: <Widget>[
        new Material(
          elevation: 2.0,
          child: new Container(
            height: 72.0,
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: new ListView(
              scrollDirection: Axis.horizontal,
              children: children,
            ),
          ),
        ),
        new Expanded(
          child: new Scrollbar(
            child:new ListView(

            padding: const EdgeInsets.all(24.0),
            children: <Widget>[
              new AnimatedSize(
                curve: Curves.fastOutSlowIn,
                duration: kThemeAnimationDuration,
                vsync: this,
                child: widget.steps[widget.currentStep].content,
              ),
            ],
          ),
        ),),
        _buildVerticalControls(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(() {
      if (context.ancestorWidgetOfExactType(Stepper) != null)
        throw new FlutterError(
            'Steppers must not be nested. The material specification advises '
            'that one should avoid embedding steppers within steppers. '
            'https://material.google.com/components/steppers.html#steppers-usage\n');
      return true;
    }());
    assert(widget.type != null);
    switch (widget.type) {
      case StepperType.vertical:
        return _buildVertical();
      case StepperType.horizontal:
        return _buildHorizontal();
    }
    return null;
  }
}

// Paints a triangle whose base is the bottom of the bounding rectangle and its
// top vertex the middle of its top.
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({this.color});

  final Color color;

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double base = size.width;
    final double halfBase = size.width / 2.0;
    final double height = size.height;
    final List<Offset> points = <Offset>[
      new Offset(0.0, height),
      new Offset(base, height),
      new Offset(halfBase, 0.0),
    ];

    canvas.drawPath(
      new Path()..addPolygon(points, true),
      new Paint()..color = color,
    );
  }
}
