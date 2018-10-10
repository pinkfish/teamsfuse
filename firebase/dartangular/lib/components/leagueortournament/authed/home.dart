import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:angular_components/material_button/material_button.dart';
import '../common/leaguecard-component.dart';
import '../../../util/algolia/algolia.dart';
import '../../../util/algolia/searchresult.dart';

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
  Future<Null> ngOnInit() async {
    SearchRequest req = new SearchRequest('leagues', 'eastside');
    Algolia algolia =
        new Algolia('588269MZO8', '32b210cdab0b0eb11b2b1f35a89b7b38');
    algolia.search(req).then((SearchResult result) => print(result));
  }

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
  void onActivate(RouterState previous, RouterState current) {}
}
