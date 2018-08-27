// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:teamfuse/components/games/gamecard-component.dart';
import 'dart:async';

@Component(
  selector: 'season-expansionpanel',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    GameCardComponent,
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

  void ngOnDestroy() {
    print('Destroy them my robots');
    _subscription.dispose();
  }

  Stream<Iterable<Game>> get games => _transformedStream;

  Object trackByGame(int index, dynamic game) => game is Game ? game.uid : "";
}
