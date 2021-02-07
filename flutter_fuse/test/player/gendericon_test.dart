import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/player/gendericon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../util/testable.dart';

void main() {
  testWidgets('Gender icon male', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: GenderIcon(Gender.Male),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 600));

    // Verify that our icon is male.
    expect(find.byIcon(MdiIcons.genderMale), findsOneWidget);
  });
  testWidgets('Gender icon female', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: RepaintBoundary(
            child: GenderIcon(Gender.Female),
          ),
        ),
      ),
    );
    await tester.pump(Duration(milliseconds: 600));

    // Verify that our icon is male.
    expect(find.byIcon(MdiIcons.genderFemale), findsOneWidget);
    //await expectLater(find.byType(GenderIcon),
    //    matchesGoldenFile('golden/gender_icon_female.png'));
  });
  testWidgets('Gender icon coed', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: GenderIcon(Gender.Coed),
      ),
    );

    await tester.pump(Duration(milliseconds: 600));

    // Verify that our icon is male.
    expect(find.byIcon(MdiIcons.genderMaleFemale), findsOneWidget);
  });

  testWidgets('Gender icon na', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: GenderIcon(Gender.NA),
      ),
    );

    await tester.pump(Duration(milliseconds: 600));

    // Verify that our icon is male.
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
