import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:google_maps/google_maps.dart';
import 'package:intl/intl.dart';

import 'attendence.dart';

@Component(
  selector: 'game-display',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    NgIf,
    NgSwitch,
    NgSwitchDefault,
    NgSwitchWhen,
    NgFor,
    RouterLink,
    AttendenceComponent,
  ],
  templateUrl: 'game-display-component.html',
  styleUrls: const [
    'game-display-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class GameDisplayComponent implements AfterViewInit, OnInit, OnDestroy {
  @Input()
  Game game;
  String opponent = "";
  String result;
  String officialResult;
  String resultclass = "";
  String officialResultClass = "";
  List<SeasonPlayer> players;
  Season currentSeason;

  static DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  static DateFormat dateWithTimeFormat =
      new DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY);
  static DateFormat timeFormat = new DateFormat(DateFormat.HOUR_MINUTE);

  GMap map;
  Marker marker;
  @ViewChild('mapArea')
  HtmlElement mapAreaRef;

  Router _router;

  StreamSubscription<Iterable<Opponent>> _teamSub;
  DatabaseUpdateModel _db;

  GameDisplayComponent(this._router, this._db);

  @override
  @override
  void ngAfterViewInit() {
    map = GMap(
        mapAreaRef,
        new MapOptions()
          ..zoom = 15
          ..center = new LatLng(
              game.sharedData.place.latitude, game.sharedData.place.longitude));
    marker = new Marker(new MarkerOptions()
      ..map = map
      ..draggable = true
      ..label = game.sharedData.place.name
      ..position = new LatLng(
          game.sharedData.place.latitude, game.sharedData.place.longitude));
  }

  @override
  void ngOnInit() {
    _teamSub = _db
        .getTeamOpponents(game.teamUid)
        .listen((Iterable<Opponent> op) => updateGame(opponents: op));
    updateGame();
  }

  @override
  void ngOnDestroy() {
    _teamSub?.cancel();
  }

  void updateGame({Iterable<Opponent> opponents}) {
    if (opponents != null) {
      var check = opponents.firstWhere((o) => o.uid == game.opponentUid,
          orElse: () => null);
      if (check != null) {
        opponent = check.name;
      }
    }
    result = _gameResult();
    officialResult = _officialResult();
    /*
    String seasonId =
        UserDatabaseData.instance.teams[game.teamUid]?.currentSeason;
    if (seasonId != null) {
      currentSeason =
          UserDatabaseData.instance.teams[game.teamUid].seasons[seasonId];
      print('Season $currentSeason');
      if (currentSeason != null) {
        players = currentSeason.players
            .where((SeasonPlayer play) =>
                UserDatabaseData.instance.players.containsKey(play.playerUid))
            .toList();
        print('Players $players');
      }
    }

     */
  }

  String iconFromAttendance(Attendance attend) {
    switch (attend) {
      case Attendance.Maybe:
        return "help";
      case Attendance.No:
        return "no";
      case Attendance.Yes:
        return "tick";
    }
    return "help_outline";
  }

  Team get team {
    return null; //UserDatabaseData.instance.teams[game.teamUid];
  }

  String get teamUrl {
    if (team.photoUrl != null && !team.photoUrl.isEmpty) {
      return team.photoUrl;
    }
    // Default asset.
    return "assets/" + team.sport.toString() + ".png";
  }

  String _gameResult() {
    if (game.result.inProgress == GameInProgress.NotStarted) {
      return null;
    }
    String ret = "${game.result.regulationResult.score.ptsFor} - "
        "${game.result.regulationResult.score.ptsAgainst}";
    if (game.result.overtimeResult != null) {
      ret += " OT: ${game.result.overtimeResult.score.ptsFor} - "
          "${game.result.overtimeResult.score.ptsAgainst}";
    }
    if (game.result.penaltyResult != null) {
      ret += " Penalty: ${game.result.penaltyResult.score.ptsFor} - "
          "${game.result.penaltyResult.score.ptsAgainst}";
    }
    return ret;
  }

  String _officialResult() {
    if (game.sharedData.officialResult.result == OfficialResult.NotStarted) {
      return null;
    }
    GameFromOfficial results =
        new GameFromOfficial(game.sharedData, game.leagueOpponentUid);
    String ret = "${results.regulationResult.score.ptsFor} - "
        "${results.regulationResult.score.ptsAgainst}";
    if (results.overtimeResult != null) {
      ret += " OT: ${results.overtimeResult.score.ptsFor} - "
          "${results.overtimeResult.score.ptsAgainst}";
    }
    if (results.penaltyResult != null) {
      ret += " Penalty: ${results.penaltyResult.score.ptsFor} - "
          "${results.penaltyResult.score.ptsAgainst}";
    }
    return ret;
  }

  void openDirections() {
    String navTo = "https://www.google.com/maps/dir/?api=1&destination=" +
        game.sharedData.place.address;
    if (game.sharedData.place.placeId != null &&
        game.sharedData.place.placeId.isNotEmpty) {
      navTo += "&destination_place_id=" + game.sharedData.place.placeId;
    }
    window.open(navTo, '_top');
  }

  void openTeam() {
    _router.navigate("/a/team/" + game.teamUid);
  }

  void openLeague() {
    _router.navigate("/a/league/home/" + game.sharedData.leagueUid);
  }

  Object trackByPlayer(int index, dynamic player) =>
      player is SeasonPlayer ? player.playerUid : "";
}
