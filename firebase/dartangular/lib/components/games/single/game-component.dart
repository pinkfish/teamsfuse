// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'game-display-component.dart';

@Component(
  selector: 'single-game',
  directives: const [
    routerDirectives,
    NgIf,
    GameDisplayComponent,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'game-component.html',
  styleUrls: const [],
)
class SingleGameComponent implements OnInit, OnActivate, OnDestroy {
  Stream<Game> game;
  String _curGameId;
  final StreamController<Game> _controller = new StreamController<Game>();
  StreamSubscription<UpdateReason> _sub;

  SingleGameComponent() {
    game = _controller.stream.asBroadcastStream();
  }

  Future<Null> ngOnInit() async {
    print('game $game!');
    _sub = UserDatabaseData.instance.teamStream.listen((UpdateReason reason) {
      if (UserDatabaseData.instance.teams.containsKey(_curGameId)) {
        _controller.add(UserDatabaseData.instance.gamesCache[_curGameId]);
      }
    });
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    print('activate! ${current.parameters} ${current.queryParameters}');
    _curGameId = current.parameters['id'];
    if (_curGameId == null) {
      _curGameId = current.queryParameters['id'];
    }
    print('$_curGameId -- ${UserDatabaseData.instance.gamesCache[_curGameId]}');
    if (_curGameId != null) {
      _controller.add(UserDatabaseData.instance.gamesCache[_curGameId]);
    }
  }
}
