import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

import 'loadfonts.dart';

///
/// Makes a happy little testable widget with a wrapper.
///
Future<Widget> makeTestableWidget(Widget child,
    {NavigatorObserver observer}) async {
  AsyncHydratedStorage.storageDirectory = Directory("fail");
  await loadFonts();
  initializeTimeZones();

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
      // By default this navigates back to the current route.
      onGenerateRoute: (s) {
        return MaterialPageRoute(builder: (c) => child, settings: s);
      },
    ),
  );
}

///
/// Router name checking class.
///
class HasRouteName extends CustomMatcher {
  HasRouteName(matcher) : super("Route with the nme that is", "name", matcher);
  featureValueOf(actual) => (actual as Route).settings.name;
}
