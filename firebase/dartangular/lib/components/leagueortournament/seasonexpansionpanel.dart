import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/content/deferred_content_aware.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'dart:async';
import 'divisonexpansionpanel.dart';

@Component(
  selector: 'season-expansionpanel',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    DivisonExpansionPanelComponent,
  ],
  templateUrl: 'seasonexpansionpanel.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class SeasonExpansionPanelComponent implements OnDestroy, OnInit {
  @Input()
  LeagueOrTournament league;
  @Input()
  LeagueOrTournamentSeason season;

  StreamSubscription<Iterable<LeagueOrTournamentDivison>> _subscription;
  StreamController<Iterable<LeagueOrTournamentDivison>> _divisonController;
  Stream<Iterable<LeagueOrTournamentDivison>> divisonStream;

  @override
  void ngOnInit() {
    print('Making panel');
    _divisonController =
        new StreamController<Iterable<LeagueOrTournamentDivison>>();
    divisonStream = _divisonController.stream.asBroadcastStream();
    _divisonController.add(season.cacheDivisions ?? []);
    _subscription = season.divisonStream
        .listen((Iterable<LeagueOrTournamentDivison> divison) {
      print('Update divison ${divison.length}');

      _divisonController.add(divison);
    });
  }

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
    _subscription = null;
    _divisonController?.close();
    _divisonController = null;
  }


  Object trackByDivison(int index, dynamic divison) =>
      divison is LeagueOrTournamentDivison ? divison.uid : "";
}
