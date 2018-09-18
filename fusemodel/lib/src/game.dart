import 'common.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import 'userdatabasedata.dart';
import 'package:collection/collection.dart';

enum EventType { Game, Practice, Event }
enum GameResult { Win, Loss, Tie, Unknown }
enum Attendance { Yes, No, Maybe }
enum GameInProgress { NotStarted, InProgress, Final }
enum GamePeriodType { Break, Overtime, Penalty, Regulation, OvertimeBreak }
enum GameLogType { ScoreUpdate, Message, PeriodStart, PeriodStop, UpdateScore }
enum GameDivisionsType { Halves, Quarters, Thirds }
enum OfficalResult { HomeTeamWon, AwayTeamWon, Tie, NotStarted, InProgress }

class GamePeriod {
  GamePeriodType type;
  num periodNumber;

  GamePeriod({this.type, this.periodNumber = 0}) : assert(type != null);

  GamePeriod.copy(GamePeriod per) {
    type = per.type;
    periodNumber = per.periodNumber;
  }

  static const String _BREAK = "--";

  bool isEqualTo(GamePeriod cmp) =>
      cmp.periodNumber == periodNumber && cmp.type == type;

  String toIndex() {
    if (periodNumber > 0) {
      return "${type.toString().substring(15)}--$periodNumber";
    }
    return "${type.toString().substring(15)}";
  }

  static GamePeriod fromIndex(String str) {
    GamePeriodType type;
    num periodNumber;
    if (str == null) {
      return null;
    }

    List<String> bits = str.split(_BREAK);
    if (bits.length == 2) {
      if (bits[0] == "FinalRegulation") {
        bits[0] = "Regulation";
      }
      if (bits[0] == "Numbered") {
        bits[0] = "Regulation";
      }
      type = GamePeriodType.values.firstWhere(
          (GamePeriodType val) => val.toString().substring(15) == bits[0]);
      periodNumber = getNum(bits[1]);
      return new GamePeriod(type: type, periodNumber: periodNumber);
    } else {
      // Old style.
      switch (str) {
        case "Final":
          type = GamePeriodType.Regulation;
          periodNumber = 0;
          break;
        case "Overtime":
          type = GamePeriodType.Overtime;
          periodNumber = 0;
          break;
        case "Penalty":
          type = GamePeriodType.Penalty;
          periodNumber = 0;
          break;
        default:
          type = GamePeriodType.Regulation;
          periodNumber = 0;
          break;
      }
      return new GamePeriod(type: type, periodNumber: periodNumber);
    }
  }

  String toString() => "GamePeriod [$type $periodNumber]";
}

class GameLogReturnData {
  StreamSubscription<dynamic> myLogStream;
  Future<List<GameLog>> logs;
}

class GameLog {
  GameLogType type;
  String message;
  GameScore score;
  num _eventTime;
  GamePeriod period;
  String uid;
  String displayName;

  GameLog(
      {this.type,
      this.message,
      this.score,
      this.uid,
      this.period,
      this.displayName,
      num eventTime})
      : _eventTime = eventTime ?? new DateTime.now().millisecondsSinceEpoch,
        assert(displayName != null),
        assert(uid != null);

  GameLog.fromJson(String uid, Map<String, dynamic> data) {
    _fromJSON(uid, data);
  }

  String initials() {
    return displayName.splitMapJoin(" ",
        onNonMatch: (String str) => str.substring(0, 1));
  }

  TZDateTime get eventTime {
    return new TZDateTime.fromMillisecondsSinceEpoch(local, _eventTime);
  }

  set eventTime(TZDateTime time) {
    _eventTime = time.millisecondsSinceEpoch;
  }

  static const String _TYPE = 'type';
  static const String _MESSAGE = 'message';
  static const String _EVENT_TIME = 'time';
  static const String _PERIOD = 'period';

  void _fromJSON(String uid, Map<String, dynamic> data) {
    type = GameLogType.values
        .firstWhere((GameLogType ty) => ty.toString() == data[_TYPE]);
    message = getString(data[_MESSAGE]);
    if (data.containsKey(GameScore._PTS_FOR)) {
      score = new GameScore.fromJSON(data);
    }
    _eventTime = getNum(data[_EVENT_TIME]);
    displayName = getString(data[NAME]);
    GamePeriod newPeriod = GamePeriod.fromIndex(data[_PERIOD]);
    period = newPeriod;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    ret[_TYPE] = type.toString();
    ret[_MESSAGE] = message;
    ret[_EVENT_TIME] = _eventTime;
    ret[NAME] = displayName;
    if (period != null) {
      ret[_PERIOD] = period.toIndex();
    }
    if (score != null) {
      score.toJSON(ret);
    }
    return ret;
  }

  String toString() {
    return "GameLog($uid)[ $type ($eventTime): $message $period $score]";
  }
}

class GameScore {
  GameScore({this.ptsFor, this.ptsAgainst, this.intermediate = true});
  GameScore.copy(GameScore copy) {
    this.ptsFor = copy.ptsFor;
    this.ptsAgainst = copy.ptsAgainst;
  }

  num ptsFor;
  num ptsAgainst;
  bool intermediate;

  static const String _PTS_FOR = 'ptsFor';
  static const String _PTS_AGAINST = 'ptsAgainst';
  static const String _INTERMEDIATE = 'intermediate';

  GameScore.fromJSON(Map<dynamic, dynamic> data) {
    ptsAgainst = getNum(data[_PTS_AGAINST]);
    ptsFor = getNum(data[_PTS_FOR]);
    intermediate = getBool(data[_INTERMEDIATE]);
  }

  void toJSON(Map<String, dynamic> data) {
    data[_PTS_FOR] = ptsFor;
    data[_PTS_AGAINST] = ptsAgainst;
    data[_INTERMEDIATE] = intermediate;
  }

  String toString() {
    return "GameScore[ ptsFor: $ptsFor, ptsAgainst: $ptsAgainst, intermediate $intermediate]";
  }
}

class GameResultPerPeriod {
  GameResultPerPeriod({this.period, this.score});
  GameResultPerPeriod.copy(GameResultPerPeriod res) {
    period = res.period;
    score = new GameScore(
        ptsFor: res.score.ptsFor, ptsAgainst: res.score.ptsAgainst);
  }
  GamePeriod period;
  GameScore score = new GameScore();

  GameResultPerPeriod.fromJSON(GamePeriod period, Map<dynamic, dynamic> data) {
    this.period = period;
    score = new GameScore.fromJSON(data);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    score.toJSON(ret);
    return ret;
  }

  String toString() {
    return "GameResultPerPeriod[ $period, $score]";
  }
}

class GamePeriodTime {
  num _currentPeriodStart; // Start of the current period.
  Duration currentOffset;
  Duration defaultPeriodDuration = new Duration(minutes: 15);
  // If we count up the time, or down the time.  This changes how the
  // duration works in this game.
  bool timeCountUp;

  GamePeriodTime(
      {DateTime currentPeriodStart,
      this.currentOffset,
      this.defaultPeriodDuration,
      this.timeCountUp})
      : _currentPeriodStart = currentPeriodStart?.millisecondsSinceEpoch;

  GamePeriodTime.copy(GamePeriodTime copy) {
    _currentPeriodStart = copy._currentPeriodStart;
    currentOffset = copy.currentOffset;
    timeCountUp = copy.timeCountUp;
    defaultPeriodDuration = copy.defaultPeriodDuration;
  }

  DateTime get currentPeriodStart =>
      _currentPeriodStart != null && _currentPeriodStart != 0
          ? new DateTime.fromMillisecondsSinceEpoch(_currentPeriodStart)
          : null;
  set currentPeriodStart(DateTime tim) => tim != null
      ? _currentPeriodStart = tim.millisecondsSinceEpoch
      : _currentPeriodStart = null;

  Duration currentStopwatch() {
    if (_currentPeriodStart != null) {
      if (timeCountUp) {
        return new Duration(
            milliseconds: new DateTime.now().millisecondsSinceEpoch -
                _currentPeriodStart +
                currentOffset.inMilliseconds);
      } else {
        int diff = new DateTime.now().millisecondsSinceEpoch -
            _currentPeriodStart +
            currentOffset.inMilliseconds;
        if (diff > currentOffset.inMilliseconds) {
          // Out of time, show as 0.
          return new Duration();
        }
        return new Duration(milliseconds: currentOffset.inMilliseconds - diff);
      }
    }
    if (currentOffset == null) {
      if (timeCountUp) {
        currentOffset = new Duration();
      } else {
        currentOffset = defaultPeriodDuration;
      }
    }
    return currentOffset;
  }

  static const String _START_TIME = 'start';
  static const String _OFFSET = 'offset';
  static const String _TIMECOUNTUP = 'countUp';
  static const String _DEFAULTDURATION = 'defaultDuration';

  void fromJSON(Map<dynamic, dynamic> data) {
    _currentPeriodStart = getNum(data[_START_TIME]);
    currentOffset = new Duration(milliseconds: getNum(data[_OFFSET]));
    timeCountUp = getBool(data[_TIMECOUNTUP]);
    defaultPeriodDuration =
        new Duration(milliseconds: getNum(data[_DEFAULTDURATION]));
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};

    ret[_START_TIME] = _currentPeriodStart;
    ret[_DEFAULTDURATION] = defaultPeriodDuration?.inMilliseconds;
    ret[_TIMECOUNTUP] = timeCountUp;
    ret[_OFFSET] = currentOffset?.inMilliseconds;
    return ret;
  }

  String toString() {
    return "GamePeriodTime {start: $_currentPeriodStart offset: $currentOffset  countUp: $timeCountUp defaultDuration: $defaultPeriodDuration}";
  }
}

///
/// The offical results we have for this game.  This only exists when the
/// game is in a tournament or a league.
///
class GameOfficalResults {
  final CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> scores =
      new CanonicalizedMap((GamePeriod p) => p.toIndex());

  /// The team uid, this pointed to a leagueortourneamentteam data.
  String homeTeamLeagueUid;
  /// The team uid, this pointed to a leagueortourneamentteam data.
  String awayTeamLeagueUid;

  final OfficalResult result;

  static const String _OFFICALRESULT = 'officalResult';
  static const String _SCORES = 'scores';
  static const String _INPROGRESS = 'inProgress';
  static const String _HOMETEAMUID = 'homeTeamUid';
  static const String _AWAYTEAMUID = 'awayTeamUid';

  GameOfficalResults(this.homeTeamLeagueUid, this.awayTeamLeagueUid,
      {this.result});

  GameOfficalResults.copy(GameOfficalResults copy)
      : homeTeamLeagueUid = copy.homeTeamLeagueUid,
        awayTeamLeagueUid = copy.awayTeamLeagueUid,
        result = copy.result {
    for (GamePeriod p in copy.scores.keys) {
      scores[p] = GameResultPerPeriod.copy(copy.scores[p]);
    }
  }

  GameOfficalResults.fromJSON(Map<dynamic, dynamic> data)
      : result = OfficalResult.values.firstWhere((e) =>
            e.toString() == data[_OFFICALRESULT] ??
            OfficalResult.NotStarted.toString(), orElse: () => OfficalResult.NotStarted),
        homeTeamLeagueUid = data[_HOMETEAMUID],
        awayTeamLeagueUid = data[_AWAYTEAMUID] {
    if (data.containsKey(_SCORES)) {
      Map<dynamic, dynamic> scoreData = data[_SCORES];
      CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> newResults =
          new CanonicalizedMap((GamePeriod p) => p.toIndex());
      scoreData.forEach((dynamic periodStd, dynamic data) {
        GamePeriod period = GamePeriod.fromIndex(periodStd);
        GameResultPerPeriod newResult =
            new GameResultPerPeriod.fromJSON(period, data);

        newResults[period] = newResult;
      });
      scores.addAll(newResults);
    }
    ;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    Map<String, dynamic> retScores = {};
    for (GameResultPerPeriod p in scores.values) {
      Map<String, dynamic> periodExtra = p.toJSON();
      retScores[p.period.toIndex()] = periodExtra;
    }
    ret[_SCORES] = retScores;
    ret[_OFFICALRESULT] = result.toString();
    ret[_AWAYTEAMUID] = awayTeamLeagueUid;
    ret[_AWAYTEAMUID] = homeTeamLeagueUid;
    return ret;
  }
}

class GameResultDetails {
  CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> scores =
      new CanonicalizedMap((GamePeriod p) => p.toIndex());
  GameResult result;
  GameInProgress inProgress;
  GamePeriod currentPeriod; // Null until the game started.
  GameDivisionsType divisions = GameDivisionsType.Halves;
  GamePeriodTime time = new GamePeriodTime();

  GameResultDetails() {
    result = GameResult.Unknown;
    inProgress = GameInProgress.NotStarted;
    GamePeriod per =
        new GamePeriod(type: GamePeriodType.Regulation, periodNumber: 0);
    scores[per] = new GameResultPerPeriod(
        period: per, score: new GameScore(ptsAgainst: 0, ptsFor: 0));
  }

  GameResultDetails.copy(GameResultDetails copy) {
    copy.scores.values.forEach((GameResultPerPeriod per) {
      this.scores[new GamePeriod.copy(per.period)] =
          new GameResultPerPeriod.copy(per);
    });
    result = copy.result;
    inProgress = copy.inProgress;
    divisions = copy.divisions;
    if (divisions == null) {
      divisions = GameDivisionsType.Halves;
    }
    currentPeriod = copy.currentPeriod;
    time = new GamePeriodTime.copy(copy.time);
  }

  static const String _SCORES = 'scores';
  static const String _RESULT = 'result';
  static const String _INPROGRESS = 'inProgress';
  static const String _PERIOD = 'period';
  static const String _DIVISIONS = 'divisions';
  static const String _TIME_DETAILS = 'timeDetails';

  void fromJSON(Map<dynamic, dynamic> data) {
    if (data.containsKey(_SCORES)) {
      Map<dynamic, dynamic> scoreData = data[_SCORES];
      CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> newResults =
          new CanonicalizedMap((GamePeriod p) => p.toIndex());
      scoreData.forEach((dynamic periodStd, dynamic data) {
        GamePeriod period = GamePeriod.fromIndex(periodStd);
        GameResultPerPeriod newResult =
            new GameResultPerPeriod.fromJSON(period, data);

        newResults[period] = newResult;
      });
      scores = newResults;
    }
    if (data[_INPROGRESS] == null) {
      inProgress = GameInProgress.NotStarted;
    } else {
      String str = data[_INPROGRESS];
      if (!str.startsWith('GameInProgress')) {
        inProgress = GameInProgress.NotStarted;
      } else {
        inProgress = GameInProgress.values
            .firstWhere((e) => e.toString() == data[_INPROGRESS]);
      }
    }
    result = GameResult.values.firstWhere((e) => e.toString() == data[_RESULT]);
    if (result == null) {
      result = GameResult.Unknown;
    }
    if (data[_PERIOD] is String) {
      currentPeriod = GamePeriod.fromIndex(data[_PERIOD]);
    }
    if (data.containsKey(_DIVISIONS) && data[_DIVISIONS] != null) {
      divisions = GameDivisionsType.values
          .firstWhere((e) => e.toString() == data[_DIVISIONS]);
    }
    if (data.containsKey(_TIME_DETAILS)) {
      time.fromJSON(data[_TIME_DETAILS]);
    } else {
      time.fromJSON({});
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    Map<String, dynamic> retScores = {};
    for (GameResultPerPeriod p in scores.values) {
      Map<String, dynamic> periodExtra = p.toJSON();
      retScores[p.period.toIndex()] = periodExtra;
    }
    ret[_SCORES] = retScores;
    ret[_RESULT] = result.toString();
    ret[_INPROGRESS] = inProgress.toString();
    ret[_PERIOD] = currentPeriod?.toIndex() ?? "";
    ret[_TIME_DETAILS] = time.toJSON();
    ret[_DIVISIONS] =
        divisions?.toString() ?? GameDivisionsType.Halves.toString();
    return ret;
  }

  @override
  String toString() {
    return 'GameResultDetails{scores: $scores, result: $result, '
        'inProgress: $inProgress, period: $currentPeriod, time: $time}';
  }
}

class GamePlace {
  String name;
  String placeId;
  String address;
  String notes;
  num latitude;
  num longitude;
  bool unknown;

  GamePlace() {
    latitude = 0;
    longitude = 0;
    address = '';
    placeId = '';
    notes = '';
    unknown = true;
  }

  GamePlace.copy(GamePlace copy) {
    name = copy.name;
    placeId = copy.placeId;
    address = copy.address;
    notes = copy.notes;
    latitude = copy.latitude;
    longitude = copy.longitude;
    unknown = copy.unknown;
  }

  static const String _PLACEID = 'placeId';
  static const String _ADDRESS = 'address';
  static const String _LONGITUDE = 'long';
  static const String _LATITUDE = 'lat';
  static const String _UNKNOWN = 'unknown';

  GamePlace.fromJSON(Map<dynamic, dynamic> data) {
    name = getString(data[NAME]);
    placeId = getString(data[_PLACEID]);
    address = getString(data[_ADDRESS]);
    notes = getString(data[NOTES]);
    longitude = getNum(data[_LONGITUDE]);
    latitude = getNum(data[_LATITUDE]);
    unknown = getBool(data[_UNKNOWN]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[_PLACEID] = placeId;
    ret[_ADDRESS] = address;
    ret[NOTES] = notes;
    ret[_LATITUDE] = latitude;
    ret[_LONGITUDE] = longitude;
    ret[_UNKNOWN] = unknown;
    return ret;
  }

  @override
  String toString() {
    return 'GamePlace{name: $name, placeId: $placeId, address: $address, '
        'notes: $notes, latitude: $latitude, longitude: $longitude, '
        'unknown: $unknown}';
  }
}

///
/// In the case of league games, this is the bit that is shared across all
/// the games.
///
class GameSharedData {
  // This is only valid in a special event.
  String name;
  String uid;
  num time;
  String _timezone;
  num endTime;
  EventType type;
  GamePlace place;
  GameOfficalResults officalResults;
  String leagueUid;
  String leagueDivisionUid;

  // Derived data
  Location _location;

  GameSharedData(String homeTeamUid, String awayTeamUid,
      {this.name = "",
      this.uid,
      num time,
      num endTime,
      GamePlace place,
      GameResultDetails officalResults,
      String timezone,
      this.type,
      this.leagueUid,
      this.leagueDivisionUid})
      : this.place = place ?? new GamePlace(),
        this.officalResults =
            officalResults ?? new GameOfficalResults(homeTeamUid, awayTeamUid),
        this.time = time ?? new DateTime.now().millisecondsSinceEpoch,
        this.endTime = endTime ?? new DateTime.now().millisecondsSinceEpoch,
        _timezone = timezone ?? local.toString();

  GameSharedData.copy(GameSharedData copy) {
    uid = copy.uid;
    time = copy.time;
    _timezone = copy._timezone;
    _location = copy._location;
    leagueUid = copy.leagueUid;
    endTime = copy.endTime;
    type = copy.type;
    place = new GamePlace.copy(copy.place);
    name = copy.name;
    leagueDivisionUid = copy.leagueDivisionUid;
    officalResults = new GameOfficalResults.copy(copy.officalResults);
  }

  GameSharedData.fromJSON(String uid, Map<String, dynamic> data) {
    this.uid = uid;
    time = getNum(data[_TIME]);
    endTime = getNum(data[_ENDTIME]);
    _timezone = getString(data[_TIMEZONE]);
    if (endTime == 0) {
      endTime = time;
    }

    type = EventType.values.firstWhere((e) => e.toString() == data[TYPE]);
    GamePlace place =
        new GamePlace.fromJSON(data[_PLACE] as Map<dynamic, dynamic>);
    this.place = place;
    name = getString(data[NAME]);
    if (data.containsKey(_OFFICALRESULT)) {
      officalResults = new GameOfficalResults.fromJSON(data[_OFFICALRESULT]);
    }

    leagueUid = data[_LEAGUEUID];
    leagueDivisionUid = data[LEAGUEDIVISIONUID];
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};
    data[_TIME] = time;
    data[_ENDTIME] = endTime;
    data[_PLACE] = place.toJSON();
    data[TYPE] = type.toString();
    data[NAME] = name;
    data[_TIMEZONE] = _timezone;
    data[_LEAGUEUID] = leagueUid;
    data[LEAGUEDIVISIONUID] = leagueDivisionUid;
    if (officalResults != null) {
      data[_OFFICALRESULT] = officalResults.toJSON();
    }
    return data;
  }

  set timezone(String value) {
    _timezone = value;
    _location = null;
  }

  String get timezone {
    return _timezone;
  }

  Location get location {
    if (_location == null) {
      _location = getLocation(this.timezone);
    }
    return _location;
  }

  void updateFrom(GameSharedData copy) {
    uid = copy.uid;
    time = copy.time;
    _timezone = copy._timezone;
    _location = copy._location;
    endTime = copy.endTime;
    type = copy.type;
    place = new GamePlace.copy(copy.place);
    name = copy.name;
    leagueDivisionUid = copy.leagueDivisionUid;
    leagueUid = copy.leagueUid;
    officalResults = new GameOfficalResults.copy(copy.officalResults);
  }

  TZDateTime get tzTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, time);
  TZDateTime get tzEndTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, time);

  static const String _OFFICALRESULT = 'officialresult';
  static const String _TIME = 'time';
  static const String _ENDTIME = 'endTime';
  static const String TYPE = 'type';
  static const String _PLACE = 'place';
  static const String _TIMEZONE = 'timezone';
  static const String _HOMETEAM = 'hometeam';
  static const String _LEAGUEUID = 'leagueUid';
  static const String LEAGUEDIVISIONUID = 'leagueDivisionUid';

  @override
  String toString() {
    return 'GameSharedData{uid: $uid, time: $tzTime, _timezone: $_timezone, '
        'endTime: $tzEndTime, leagueUid: $leagueUid, '
        'leagueDivisionUid: $leagueDivisionUid, '
        'name: $name, type: $type, officalResults: $officalResults, '
        'officalResult: $officalResults, place: $place}';
  }
}

///
/// This is the game details and it is kept in a team specific format, so that
/// the view of the same game for different teams will look different.
///
class Game {
  String uid;
  String sharedDataUid;
  num arriveTime;
  String notes;
  List<String> opponentUids;
  String seasonUid;
  String teamUid;
  List<String> allTeamUids;
  String uniform;
  String seriesId;
  GameResultDetails result;
  Map<String, Attendance> attendance;
  bool trackAttendance;
  List<GameLog> _gameLogs;
  GameSharedData sharedData;

  Stream<UpdateReason> thisGameStream;
  Stream<List<GameLog>> thisGameLogStream;
  StreamSubscription<dynamic> _gameLogSubcription;
  StreamController<UpdateReason> _updateThisGame =
      new StreamController<UpdateReason>();
  StreamController<List<GameLog>> _updateThisLogGame =
      new StreamController<List<GameLog>>();

  Game(String homeTeamUid, String awayTeamUid,
      {this.uid,
      num arriveTime,
      GameSharedData sharedData,
      this.notes = "",
      this.trackAttendance = true,
      this.uniform = "",
      this.seriesId,
      GameResultDetails result,
      Map<String, Attendance> attendance})
      : this.sharedData =
            sharedData ?? new GameSharedData(homeTeamUid, awayTeamUid),
        this.result = result ?? new GameResultDetails(),
        this.attendance = attendance ?? <String, Attendance>{},
        this.arriveTime =
            arriveTime ?? new DateTime.now().millisecondsSinceEpoch {
    thisGameStream = _updateThisGame.stream.asBroadcastStream();
    thisGameLogStream = _updateThisLogGame.stream.asBroadcastStream();
  }

  Game.copy(Game copy) {
    uid = copy.uid;
    arriveTime = copy.arriveTime;
    notes = copy.notes;
    opponentUids = copy.opponentUids;
    allTeamUids = copy.allTeamUids;
    seasonUid = copy.seasonUid;
    teamUid = copy.teamUid;
    uniform = copy.uniform;
    seriesId = copy.seriesId;
    result = new GameResultDetails.copy(copy.result);
    attendance = new Map<String, Attendance>.from(copy.attendance);
    trackAttendance = copy.trackAttendance;
    if (_gameLogs != null) {
      _gameLogs = new List.from(copy._gameLogs);
    }
    sharedData = new GameSharedData.copy(copy.sharedData);
    thisGameStream = _updateThisGame.stream.asBroadcastStream();
    thisGameLogStream = _updateThisLogGame.stream.asBroadcastStream();
  }

  Game.fromJSON(String teamContext, String gameUid, Map<String, dynamic> data,
      GameSharedData inputSharedData) {
    assert(inputSharedData != null);
    uid = gameUid;
    sharedDataUid = getString(data[SHAREDDATAUID]);
    if (arriveTime == 0) {
      arriveTime = sharedData.time;
    }
    sharedData = inputSharedData;
    seasonUid = getString(data[SEASONUID]);
    uniform = getString(data[_UNIFORM]);
    teamUid = getString(data[TEAMUID]);
    opponentUids = [getString(data[_OPPONENTUID])];
    allTeamUids = [teamUid, opponentUids[0]];
    arriveTime = getNum(data[ARRIVALTIME]);
    notes = getString(data[NOTES]);
    GameResultDetails details = new GameResultDetails();
    details.fromJSON(data[RESULT] as Map<dynamic, dynamic>);
    result = details;
    trackAttendance =
        data[_TRACKATTENDANCE] == null || getBool(data[_TRACKATTENDANCE]);
    seriesId = getString(data[_SERIESID]);

    // Work out attendance for our team only.
    Map<String, Attendance> newAttendanceData = new Map<String, Attendance>();
    Map<dynamic, dynamic> attendanceData =
        data[ATTENDANCE] as Map<dynamic, dynamic>;
    if (attendanceData != null) {
      for (String key in attendanceData.keys) {
        if (attendanceData[key] is Map &&
            attendanceData[key].containsKey(ATTENDANCEVALUE)) {
          if (attendanceData[key][ATTENDANCEVALUE] is String &&
              attendanceData[key][ATTENDANCEVALUE].startsWith("Attendance")) {
            newAttendanceData[key.toString()] = Attendance.values.firstWhere(
                (e) => e.toString() == attendanceData[key][ATTENDANCEVALUE]);
          }
        }
      }
    }
    attendance = newAttendanceData;
    thisGameStream = _updateThisGame.stream.asBroadcastStream();
    thisGameLogStream = _updateThisLogGame.stream.asBroadcastStream();
  }

  void updateFrom(Game copy) {
    uid = copy.uid;
    arriveTime = copy.arriveTime;
    notes = copy.notes;
    opponentUids = copy.opponentUids;
    allTeamUids = copy.allTeamUids;
    seasonUid = copy.seasonUid;
    teamUid = copy.teamUid;
    uniform = copy.uniform;
    seriesId = copy.seriesId;
    result = new GameResultDetails.copy(copy.result);
    attendance = new Map<String, Attendance>.from(copy.attendance);
    trackAttendance = copy.trackAttendance;
    if (_gameLogs != null) {
      _gameLogs = new List.from(copy._gameLogs);
    }
  }

  bool get homegame => sharedData.officalResults.homeTeamLeagueUid == teamUid;
  set homegame(bool val) => val
      ? sharedData.leagueUid != null
          ? sharedData.officalResults.homeTeamLeagueUid = teamUid
          : null
      : sharedData.leagueUid != null
          ? sharedData.officalResults.homeTeamLeagueUid =
              opponentUids.length > 0 ? opponentUids[0] : ""
          : null;

  List<GameLog> get logs => _gameLogs ?? [];

  TZDateTime get tzArriveTime => new TZDateTime.fromMillisecondsSinceEpoch(
      sharedData.location, arriveTime);

  static const String SEASONUID = 'seasonUid';
  static const String _UNIFORM = 'uniform';
  static const String RESULT = 'result';
  static const String ATTENDANCE = 'attendance';
  static const String ATTENDANCEVALUE = 'value';
  static const String TEAMUID = 'teamUid';
  static const String _SERIESID = 'seriesId';
  static const String _TRACKATTENDANCE = 'trackAttendance';
  static const String _OPPONENTUID = 'opponentUid';
  static const String SHAREDDATAUID = 'sharedDataUid';

  void markGameChanged() {
    _updateThisGame?.add(UpdateReason.Update);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[ARRIVALTIME] = arriveTime;
    ret[NOTES] = notes;
    ret[SEASONUID] = seasonUid;
    ret[_UNIFORM] = uniform;
    // My teamuid.
    ret[TEAMUID] = teamUid;
    // Set the team specific values.
    ret[NOTES] = notes;
    ret[_TRACKATTENDANCE] = trackAttendance;
    ret[RESULT] = result.toJSON();
    ret[SHAREDDATAUID] = sharedDataUid;
    if (opponentUids.length > 0) {
      ret[_OPPONENTUID] = opponentUids[0];
    }

    ret[_SERIESID] = seriesId;
    attendance.forEach((String key, Attendance value) {
      Map<String, dynamic> attendanceInner = new Map<String, dynamic>();
      attendanceInner[ATTENDANCEVALUE] = value.toString();
      // Only update the attendence for our team.
      ret[ATTENDANCE + "." + key] = attendanceInner;
    });

    return ret;
  }

  void close() {
    _updateThisGame?.close();
    _updateThisGame = null;
    _gameLogs?.clear();
    _updateThisGame = null;
    _gameLogSubcription?.cancel();
    _updateThisLogGame?.close();
    _updateThisLogGame = null;
  }

  void updateLogs(List<GameLog> logs) {
    _gameLogs = logs;
    _updateThisLogGame.add(_gameLogs);
  }

  Future<void> updateFirestore(bool sharedData) {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreGame(this, sharedData);
  }

  Future<void> updateFirestoreAttendence(String playerUid, Attendance attend) {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreGameAttendence(this, playerUid, attend);
  }

  Future<void> updateFirestoreResult(GameResultDetails result) {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreGameResult(this, result);
  }

  Future<void> deleteFromFirestore() {
    return UserDatabaseData.instance.updateModel.deleteFirestoreGame(this);
  }

  Future<String> addGameLog(GameLog log) {
    return UserDatabaseData.instance.updateModel.addFirestoreGameLog(this, log);
  }

  Future<List<GameLog>> loadGameLogs() async {
    if (_gameLogs != null) {
      return _gameLogs;
    }
    GameLogReturnData data =
        UserDatabaseData.instance.updateModel.readGameLogs(this);
    _gameLogSubcription = data.myLogStream;
    List<GameLog> logs = await data.logs;
    _gameLogs = logs;
    _updateThisLogGame.add(_gameLogs);
    return logs;
  }

  @override
  String toString() {
    return 'Game{uid: $uid, '
        'arriveTime: $tzArriveTime, '
        'notes: $notes, opponentUids: $opponentUids, seasonUid: $seasonUid, '
        'teamUid: $teamUid, uniform: $uniform, seriesId: $seriesId, '
        'result: $result, attendance: $attendance, sharedData: $sharedData}';
  }

  /// We are hashed based on the uid.
  @override
  int get hashCode => uid.hashCode;

  ///
  /// Equal if the uid is the same.  Compare to string to handle removal from
  /// sets
  ///
  @override
  bool operator ==(Object other) =>
      other is Game && other.uid == uid || other is String && uid == other;
}
