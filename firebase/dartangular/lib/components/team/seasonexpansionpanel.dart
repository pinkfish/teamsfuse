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
  Stream<Iterable<Game>> _transformedStream;

  @override
  void ngOnInit() {
    print('Making panel');
    _subscription = season.getGames();
    _transformedStream = _subscription.stream.map((Iterable<Game> games) {
      Iterable<Game> ret = games.where((Game g) => g.sharedData.type == EventType.Game);
      return ret;
    });
  }

  @override
  void ngOnDestroy() {
    _subscription.dispose();
  }

  Stream<Iterable<Game>> get games => _transformedStream;

  Object trackByGame(int index, dynamic game) => game is Game ? game.uid : "";
}
