import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

///
/// Makes a happy little testable widget with a wrapper.
///
Widget makeTestableWidget(Widget child, {NavigatorObserver observer}) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: [
        MessagesTestDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorObservers: observer != null ? [observer] : [],
      color: Colors.green,
      home: child,
    ),
  );
}
