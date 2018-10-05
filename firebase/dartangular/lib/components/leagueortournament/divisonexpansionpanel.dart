import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'dart:async';
import 'package:teamfuse/components/games/gamesharedcard-component.dart';

@Component(
  selector: 'divison-expansionpanel',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    GameSharedCardComponent
  ],
  templateUrl: 'divisonexpansionpanel.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class DivisonExpansionPanelComponent implements OnDestroy, OnInit {
  @Input()
  LeagueOrTournament league;
  @Input()
  LeagueOrTournamentSeason season;
  @Input()
  LeagueOrTournamentDivison divison;

  Iterable<GameSharedData> games;
  StreamSubscription<Iterable<GameSharedData>> _subscription;
  StreamController<Iterable<GameSharedData>> _gameController;
  Stream<Iterable<GameSharedData>> gameStream;

  @override
  void ngOnInit() {
    print('Making panel');
    games = divison.cachedGames ?? [];
    _gameController = new StreamController();
    gameStream = _gameController.stream.asBroadcastStream();
    _gameController.add(games);
    _subscription =
        divison.gameStream.listen((Iterable<GameSharedData> allGames) {
      _gameController.add(games);
      games = allGames;
    });
  }

  @override
  void ngOnDestroy() {
    _subscription.cancel();
    _gameController.close();
  }

  Object trackByGame(int index, dynamic game) =>
      game is GameSharedData ? game.uid : "";
}
