import 'package:fusemodel/fusemodel.dart';

Game makeTestGame(
    {String gameUid = 'game123',
    String sharedGameUid = 'shared1234',
    String seasonUid = 'season123',
    String teamUid = 'team123',
    DateTime start,
    DateTime end}) {
  var result = GameResultDetailsBuilder()
    ..inProgress = GameInProgress.NotStarted
    ..result = GameResult.Win
    ..time.currentOffsetInternal = 0
    ..currentPeriod = GamePeriod.notStarted.toBuilder()
    ..divisons = GameDivisionsType.Quarters;
  var shared = GameSharedDataBuilder()
    ..uid = sharedGameUid
    ..time = start ?? DateTime.now().toUtc()
    ..name = 'Work of waffles'
    ..timezone = 'America/Los_Angeles'
    ..type = EventType.Game
    ..endTime = end ?? DateTime.now().toUtc()
    ..place.name = 'Rabbit hole';
  return Game((b) => b
    ..uid = gameUid
    ..arrivalTime =
        (start ?? DateTime.now()).subtract(Duration(minutes: 30)).toUtc()
    ..sharedDataUid = sharedGameUid
    ..notes = 'No need for fluff'
    ..seasonUid = seasonUid
    ..teamUid = teamUid
    ..uniform = 'Always'
    ..result = result
    ..sharedData = shared);
}

Team makeTestTeam(
    {String seasonUid = 'season123',
    String teamUid = 'team123',
    String userUid = 'user123'}) {
  return Team((b) => b
    ..uid = teamUid
    ..name = 'Fluff World'
    ..trackAttendanceInternal = false
    ..league = ''
    ..currentSeason = seasonUid
    ..arriveEarlyInternal = 10
    ..isPublic = false
    ..gender = Gender.Female
    ..sport = Sport.Basketball
    ..userUid = userUid);
}

Season makeTestSeason(
    {String seasonUid = 'season123', String teamUid = 'team123'}) {
  return Season((b) => b
    ..uid = seasonUid
    ..teamUid = teamUid
    ..name = 'Fluff World'
    ..isPublic = false
    ..record.loss = 0
    ..record.win = 0
    ..record.tie = 0);
}

Opponent makeTestOpponent(
    {String opponentUid = 'opp123', String teamUid = 'team123'}) {
  return Opponent((b) => b
    ..uid = opponentUid
    ..name = 'Red Barron'
    ..teamUid = teamUid
    ..contact = '');
}
