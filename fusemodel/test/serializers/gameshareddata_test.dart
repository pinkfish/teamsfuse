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
          ..leagueUid = "none"
          ..uid = "myUid"
          ..name = "WOmble world"
          ..time = 12354
          ..endTime = 12345
          ..timezone = "PDT"
          ..type = EventType.Event
          ..place.name = "frog"
          ..place.latitude = 12
          ..place.longitude = 10
          ..place.address = "unknown"
          ..place.placeId = "frog"
          ..place.unknown = false
          ..place.notes = ""
          ..officialResult.result = OfficialResult.AwayTeamWon
          ..officialResult.scoresInternal[GamePeriod.finalPeriod.toIndex()] =
              resultPerPeriod)
        .build();
    var serializer = GameSharedData.serializer;

    GameSharedData newResult =
        serializers.deserializeWith(serializer, gameSharedData.toMap());

    expect(newResult, equals(gameSharedData));
  });
}