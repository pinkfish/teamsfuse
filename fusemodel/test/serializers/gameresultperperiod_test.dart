import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/serializer.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  tearDown(() {});

  test('serialize/deserialize', () {
    var resultPerPeriod = (GameResultPerPeriodBuilder()
          ..period = GamePeriod.finalPeriod.toBuilder()
          ..score.ptsAgainst = 12
          ..score.ptsFor = 0
          ..score.intermediate = true)
        .build();
    var serializer = GameResultPerPeriod.serializer;

    var newResult =
        dataSerializers.deserializeWith(serializer, resultPerPeriod.toMap());

    expect(newResult.period, equals(GamePeriod.finalPeriod));
  });
}
