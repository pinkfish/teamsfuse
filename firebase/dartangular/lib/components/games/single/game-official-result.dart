import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
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
class GameOfficialResult implements OnInit {
  @Input()
  GameSharedData game;

  Team homeTeam;
  LeagueOrTournamentTeam homeLeagueTeam;
  Team awayTeam;
  LeagueOrTournamentTeam awayLeagueTeam;
  GameFromOfficial homeTeamResult;

  @override
  void ngOnInit() {
    UserDatabaseData.instance.updateModel
        .getLeagueTeamData(game.officialResults.awayTeamLeagueUid)
        .then((LeagueOrTournamentTeam team) {
      awayLeagueTeam = team;
      UserDatabaseData.instance.updateModel
          .getPublicTeamDetails(team.teamUid)
          .then((Team t) {
        awayTeam = t;
      });
    });
    UserDatabaseData.instance.updateModel
        .getLeagueTeamData(game.officialResults.homeTeamLeagueUid)
        .then((LeagueOrTournamentTeam team) {
      homeLeagueTeam = team;
      UserDatabaseData.instance.updateModel
          .getPublicTeamDetails(team.teamUid)
          .then((Team t) {
        homeTeam = t;
      });
    });
    homeTeamResult =
        GameFromOfficial(game, game.officialResults.awayTeamLeagueUid);
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
}
