import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:angular_components/material_button/material_button.dart';
import 'leaguecard-component.dart';

class TimeStuff {
  num hour;
  num minute;
  bool am;

  @override
  String toString() => "TimeStuff [$hour:$minute $am]";
}

@Component(
  selector: 'league-or-tournament-display',
  directives: const [
    routerDirectives,
    MaterialButtonComponent,
    LeagueCardComponent,
    NgIf,
    NgFor,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'home.html',
  styleUrls: const [],
)
class HomeComponent implements OnInit, OnDestroy, OnChanges {
  HomeComponent() {}

  @override
  Future<Null> ngOnInit() async {}

  @override
  void ngOnDestroy() {}

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    print('on league changed $changes');
  }

  List<LeagueOrTournament> get leagues => UserDatabaseData
      .instance.leagueOrTournments.values
      .where((LeagueOrTournament l) => l.type == LeagueOrTournamentType.League)
      .toList();

  List<LeagueOrTournament> get tournaments => UserDatabaseData
      .instance.leagueOrTournments.values
      .where(
          (LeagueOrTournament l) => l.type == LeagueOrTournamentType.Tournament)
      .toList();

  Object trackByTournament(int index, dynamic t) =>
      t is LeagueOrTournament ? t.uid : "";

  @override
  void onActivate(RouterState previous, RouterState current) {
    /*
    _curTeamId = current.parameters['id'];
    if (_curTeamId == null) {
      _curTeamId = current.queryParameters['id'];
    }
    print('$_curTeamId -- ${UserDatabaseData.instance.teams[_curTeamId]}');
    if (_curTeamId != null) {
      _controller.add(UserDatabaseData.instance.teams[_curTeamId]);
    }
    */
  }
}
