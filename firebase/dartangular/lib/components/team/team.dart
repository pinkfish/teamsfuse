// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'teamdetails.dart';

@Component(
  selector: 'team-display',
  directives: const [
    routerDirectives,
    NgIf,
    TeamDetailsComponent,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'team.html',
  styleUrls: const [],
)
class TeamComponent implements OnInit, OnActivate, OnDestroy {
  Stream<Team> team;
  String _curTeamId;
  final StreamController<Team> _controller = new StreamController<Team>();
  StreamSubscription<UpdateReason> _sub;

  TeamComponent() {
    team = _controller.stream.asBroadcastStream();
  }

  Future<Null> ngOnInit() async {
    print('team $team!');
    _sub = UserDatabaseData.instance.teamStream.listen((UpdateReason reason) {
      if (UserDatabaseData.instance.teams.containsKey(_curTeamId)) {
        _controller.add(UserDatabaseData.instance.teams[_curTeamId]);
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
    _curTeamId = current.parameters['id'];
    if (_curTeamId == null) {
      _curTeamId = current.queryParameters['id'];
    }
    print('$_curTeamId -- ${UserDatabaseData.instance.teams[_curTeamId]}');
    if (_curTeamId != null) {
      _controller.add(UserDatabaseData.instance.teams[_curTeamId]);
    }
  }
}
