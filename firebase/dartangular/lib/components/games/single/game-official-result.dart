import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';

@Component(
  selector: 'game-official-result',
  directives: const [
    MaterialIconComponent,
    NgIf,
    NgSwitch,
    NgSwitchDefault,
    NgSwitchWhen,
    formDirectives,
    RouterLink
  ],
  templateUrl: 'game-official-result.html',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class GameOfficialResult implements OnInit, OnDestroy {
  @Input()
  GameSharedData game;

  Team homeTeam;
  LeagueOrTournamentTeam homeLeagueTeam;
  Team awayTeam;
  LeagueOrTournamentTeam awayLeagueTeam;
  GameFromOfficial homeTeamResult;

  DatabaseUpdateModel _db;

  StreamSubscription<LeagueOrTournamentTeam> _subHome;
  StreamSubscription<LeagueOrTournamentTeam> _subAway;

  GameOfficialResult(this._db);

  @override
  void ngOnInit() {
    _subHome = _db
        .getLeagueTeamData(game.officialResult.awayTeamLeagueUid)
        .listen((LeagueOrTournamentTeam team) {
      awayLeagueTeam = team;
      _db.getPublicTeamDetails(teamUid: team.teamUid).listen((Team t) {
        awayTeam = t;
      });
    });
    _subAway = _db
        .getLeagueTeamData(game.officialResult.homeTeamLeagueUid)
        .listen((LeagueOrTournamentTeam team) {
      homeLeagueTeam = team;
      _db.getPublicTeamDetails(teamUid: team.teamUid).listen((Team t) {
        homeTeam = t;
      });
    });
    homeTeamResult =
        GameFromOfficial(game, game.officialResult.awayTeamLeagueUid);
  }

  String get homeResultClass {
    switch (homeTeamResult.result) {
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

  String get awayResultClass {
    switch (homeTeamResult.result) {
      case GameResult.Win:
        return "loss";
      case GameResult.Loss:
        return "win";
      case GameResult.Tie:
        return "tie";
      case GameResult.Unknown:
        return "";
    }
    return "";
  }

  String get homeTeamUrl {
    if (homeTeam == null) {
      return "assets/defaultavatar2.png";
    }

    if (homeTeam.photoUrl != null) {
      return homeTeam.photoUrl;
    }
    return "assets/" + homeTeam.sport.toString() + ".png";
  }

  String get awayTeamUrl {
    if (awayTeam == null) {
      return "assets/defaultavatar2.png";
    }

    if (awayTeam.photoUrl != null) {
      return awayTeam.photoUrl;
    }
    return "assets/" + awayTeam.sport.toString() + ".png";
  }

  @override
  void ngOnDestroy() {
    _subAway?.cancel();
    _subHome?.cancel();
  }
}
