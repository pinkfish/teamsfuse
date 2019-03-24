import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';

@Component(
  selector: 'league-name-and-result',
  directives: const [
    NgIf,
    NgSwitch,
    NgSwitchDefault,
    NgSwitchWhen,
    formDirectives,
    RouterLink,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'leaguenameandresult.html',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    '../games-component.css',
  ],
)
class LeagueNameAndResult implements OnInit, OnDestroy {
  @Input()
  GameSharedData game;
  @Input()
  String leagueTeamUid;
  @Input()
  bool homeTeam;

  final Router _router;
  LeagueOrTournamentTeam _team;
  StreamController<LeagueOrTournamentTeam> _teamController;
  Stream<LeagueOrTournamentTeam> team;
  Team mainTeam;
  GameFromOfficial result;

  LeagueNameAndResult(this._router);

  @override
  void ngOnInit() {
    _teamController = new StreamController();
    team = _teamController.stream.asBroadcastStream();
    result = new GameFromOfficial(game, leagueTeamUid);
    UserDatabaseData.instance.updateModel
        .getLeagueTeamData(leagueTeamUid)
        .then((LeagueOrTournamentTeam team) {
      _team = team;
      _teamController?.add(team);
      UserDatabaseData.instance.updateModel
          .getPublicTeamDetails(team.teamUid)
          .then((Team t) {
        mainTeam = t;
        _teamController?.add(team);
      });
    });
  }

  @override
  void ngOnDestroy() {
    _teamController?.close();
    _teamController = null;
  }

  void openDetails() {
    print('Doing exciting stuff');
    _router.navigate("/a/league/team/" + leagueTeamUid);
  }

  String gameResult() {
    if (result.regulationResult != null) {
      String ret = "${result.regulationResult.score.ptsFor}";
      if (result.overtimeResult != null) {
        ret += " OT: ${result.overtimeResult.score.ptsFor}";
      }
      if (result.penaltyResult != null) {
        ret += " Penalty: ${result.penaltyResult.score.ptsFor}";
      }
      return ret;
    } else {
      return "";
    }
  }

  String get teamUrl {
    if (mainTeam == null) {
      return "assets/defaultavatar2.png";
    }

    if (mainTeam.photoUrl != null) {
      return mainTeam.photoUrl;
    }
    return "assets/" + mainTeam.sport.toString() + ".png";
  }

  String get teamName {
    if (_team != null) {
      return _team.name;
    }
    return "Unknown";
  }

  String get resultclass {
    switch (result.result) {
      case GameResult.Win:
        return "win";
      case GameResult.Loss:
        return "loss";
      case GameResult.Tie:
        return "tie";
      case GameResult.Unknown:
        return "";
    }
    return "";
  }

  String get float {
    if (homeTeam) {
      return "right";
    }
    return "left";
  }
}
