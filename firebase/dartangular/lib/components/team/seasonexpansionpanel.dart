import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:teamfuse/components/games/gamecard-component.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'dart:async';

@Component(
  selector: 'season-expansionpanel',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    GameCardComponent,
    DeferredContentDirective
  ],
  templateUrl: 'seasonexpansionpanel.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class SeasonExpansionPanelComponent implements OnDestroy, OnInit {
  @Input()
  Team team;
  @Input()
  Season season;
  GameSubscription _subscription;
  Iterable<Game> games;
  StreamSubscription<Iterable<Game>> _transformedStream;

  @override
  void ngOnInit() {
    print('Making panel');
    _subscription = season.getGames();
    games = _subscription.initialData;
    _transformedStream = _subscription.stream.map((Iterable<Game> games) {
      Iterable<Game> ret =
          games.where((Game g) => g.sharedData.type == EventType.Game);
      return ret;
    }).listen((Iterable<Game> allGames) => games = allGames);
  }

  @override
  void ngOnDestroy() {
    _subscription.dispose();
    _transformedStream.cancel();
  }

  Object trackByGame(int index, dynamic game) => game is Game ? game.uid : "";
}
