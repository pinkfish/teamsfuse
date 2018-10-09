import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';

class TimeStuff {
  num hour;
  num minute;
  bool am;

  @override
  String toString() => "TimeStuff [$hour:$minute $am]";
}

@Component(
  selector: 'league-team-card',
  directives: const [NgIf, RouterLink],
  templateUrl: 'league-team-card-component.html',
  styleUrls: const [
    'leaguecard-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class LeagueTeamCardComponent implements OnChanges {
  @Input()
  LeagueOrTournamentTeam leagueOrTournamentTeam;
  final Router _router;
  final Location _location;
  Team team;

  String teamUrl;
  WinRecord _cachedRecord;

  LeagueTeamCardComponent(this._router, this._location) {
    teamUrl = _location.normalize("/assets/defaultavatar2.png");
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    if (changes.containsKey('leagueOrTournamentTeam')) {
      if (leagueOrTournamentTeam.teamUid != null) {
        UserDatabaseData.instance.updateModel
            .getPublicTeamDetails(leagueOrTournamentTeam.uid)
            .then((Team t) {
          if (t != null) {
            team = t;
            if (t.photoUrl != null && t.photoUrl.isNotEmpty) {
              teamUrl = t.photoUrl;
            }
          }
        });
      }
    }
  }

  WinRecord get record {
    if (_cachedRecord == null) {
      _cachedRecord = leagueOrTournamentTeam
              .record[leagueOrTournamentTeam.leagueOrTournamentDivisonUid] ??
          WinRecord();
    }
    return _cachedRecord;
  }

  void openDetails() {
    print('Doing exciting stuff');
    _router.navigate("/a/leagueteam/detail/" + leagueOrTournamentTeam.uid);
  }
}
