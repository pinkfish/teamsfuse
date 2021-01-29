// This is a basic Flutter integration test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/flutter_driver.dart';


import 'package:flutter_fuse/main.dart' as app;

void main() {
  group('Flutter fuse app', () async {
    // Build our app and trigger a frame.
    app.main();

    FlutterDriver driver;

    setupApp(() async {
      driver = await FlutterDriver.connect();
    }
    );

    tearDownAll(() async {
      if (driver != null) {
      driver.close();
      }
    })
  });
}
