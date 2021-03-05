import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:teamfuse/components/games/gamecard-component.dart';
import 'package:built_collection/built_collection.dart';

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
  StreamSubscription<BuiltList<Game>> _subscription;
  Iterable<Game> games;
  StreamSubscription<Iterable<Game>> _transformedStream;
  DatabaseUpdateModel _db;

  SeasonExpansionPanelComponent(this._db);

  @override
  void ngOnInit() {
    print('Making panel');

    _subscription = _db.getSeasonGames(season).listen((event) {
      games = event;
    });

    games = [];
  }

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
  }

  Object trackByGame(int index, dynamic game) => game is Game ? game.uid : "";
}
