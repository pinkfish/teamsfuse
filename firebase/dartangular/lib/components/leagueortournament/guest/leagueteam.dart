import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:teamfuse/components/games/gamesharedcard-component.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'dart:async';

@Component(
  selector: 'league-team',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    MaterialButtonComponent,
    GameSharedCardComponent,
    DeferredContentDirective,
  ],
  templateUrl: 'leagueteam.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    'leaguedetails.css',
  ],
)
class LeagueTeamComponent implements OnDestroy, OnInit, OnActivate {
  LeagueOrTournament league;
  LeagueOrTournamentSeason leagueSeason;
  LeagueOrTournamentDivison leagueDivison;
  LeagueOrTournamentTeam leagueTeam;
  Team team;

  Iterable<GameSharedData> games;
  StreamSubscription<Iterable<GameSharedData>> _gameSub;
  StreamSubscription<LeagueOrTournamentTeam> _teamSub;

  final Location _location;
  final Router _router;

  LeagueTeamComponent(this._location, this._router);

  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState previous, RouterState current) {
    // Start with the id and work backwards.  Yay!
    UserDatabaseData.instance.updateModel
        .getLeagueTeamData(current.parameters['id'])
        .then((LeagueOrTournamentTeam t) {
      leagueTeam = t;
      _teamSub = t.thisTeamStream.listen((LeagueOrTournamentTeam newt) {
        leagueTeam = newt;
      });
      games = t.cachedGames ?? [];
      _gameSub = t.games.listen((Iterable<GameSharedData> gs) => games = gs);
      if (t.teamUid != null) {
        UserDatabaseData.instance.updateModel
            .getPublicTeamDetails(t.teamUid)
            .then((Team tt) {
          team = tt;
        });
      }
      UserDatabaseData.instance.updateModel
          .getLeagueDivisionData(t.leagueOrTournamentDivisonUid)
          .then((LeagueOrTournamentDivison d) {
        leagueDivison = d;
        UserDatabaseData.instance.updateModel
            .getLeagueSeasonData(d.leagueOrTournmentSeasonUid)
            .then((LeagueOrTournamentSeason s) {
          leagueSeason = s;
          UserDatabaseData.instance.updateModel
              .getLeagueData(s.leagueOrTournmentUid)
              .then((LeagueOrTournament l) {
            league = l;
          });
        });
      });
    });
  }

  String get sportDetails {
    return league.sport.toString().substring(6);
  }

  String get genderIcon {
    switch (league.gender) {
      case Gender.Coed:
        return "gender-male-female";
      case Gender.Female:
        return "gender-female";
      case Gender.Male:
        return "gender-male";
      case Gender.NA:
        return "help";
    }
    return "help";
  }

  String get gender {
    switch (league.gender) {
      case Gender.Coed:
        return "Coed";
      case Gender.Female:
        return "Female";
      case Gender.Male:
        return "Male";
      case Gender.NA:
        return "N/A";
    }
    return "Unknown";
  }

  String get leagueUrl {
    if (league == null) {
      return _location.normalizePath("/assets/defaultavatar2.png");
    }
    if (league.photoUrl != null && !league.photoUrl.isEmpty) {
      return league.photoUrl;
    }
    // Default asset.
    return _location
        .normalizePath("/assets/" + league.sport.toString() + ".png");
  }

  String get leagueTeamUrl {
    if (team != null) {
      if (team.photoUrl != null && !team.photoUrl.isEmpty) {
        return team.photoUrl;
      }
    }
    if (league != null) {
      return _location.normalizePath("/assets/defaultavatar2.png");
    }
    // Default asset.
    return _location
        .normalizePath("/assets/" + league.sport.toString() + ".png");
  }

  @override
  void ngOnDestroy() {
    _teamSub?.cancel();
    _teamSub = null;
    _gameSub?.cancel();
    _gameSub = null;
  }

  void openTeam() {
    _router.navigate("/a/team/" + team.uid);
  }

  void openLeague() {
    _router.navigate("/a/league/detail/" + league.uid);
  }

  Object trackByGame(int index, dynamic game) =>
      game is GameSharedData ? game.uid : "";
}
