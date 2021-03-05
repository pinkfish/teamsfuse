import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/game.dart';
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

    var gameSharedData = (GameSharedDataBuilder()
          ..leagueUid = 'none'
          ..uid = 'myUid'
          ..name = 'WOmble world'
          ..time = DateTime.fromMillisecondsSinceEpoch(12354).toUtc()
          ..endTime = DateTime.fromMillisecondsSinceEpoch(12345).toUtc()
          ..timezone = 'PDT'
          ..type = EventType.Event
          ..place.name = 'frog'
          ..place.latitude = 12
          ..place.longitude = 10
          ..place.address = 'unknown'
          ..place.placeId = 'frog'
          ..place.unknown = false
          ..place.notes = ''
          ..officialResult.result = OfficialResult.AwayTeamWon
          ..officialResult.scoresInternal[GamePeriod.finalPeriod.toIndex()] =
              resultPerPeriod)
        .build();
    var serializer = GameSharedData.serializer;

    var newResult =
        dataSerializers.deserializeWith(serializer, gameSharedData.toMap());

    expect(newResult, equals(gameSharedData));
  });
}
