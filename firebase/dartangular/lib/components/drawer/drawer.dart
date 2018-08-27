// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:teamfuse/components/drawer/teamdraweritem.dart';
import 'package:teamfuse/services/isfirebaseauth.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'teamfuse-drawer',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialPersistentDrawerDirective,
    MaterialListComponent,
    MaterialListItemComponent,
    TeamDrawerItem,
    NgFor,
    IfFirebaseAuthDirective,
  ],
  templateUrl: 'drawer.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'drawer.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class Drawer implements OnInit, OnDestroy {
  bool customWidth = false;
  bool end = false;
  Player player = UserDatabaseData.instance.mePlayer;
  Stream<Iterable<Team>> teams;
  StreamController<Iterable<Team>> _teamController = new StreamController();
  StreamSubscription<UpdateReason> _sub;
  final Router _router;

  Drawer(this._router);

  Object trackByTeams(int index, dynamic team) => team is Team ? team.uid : "";

  void ngOnInit() {
    teams = _teamController.stream.asBroadcastStream();
    _teamController.add(UserDatabaseData.instance.teams.values);
    _sub = UserDatabaseData.instance.teamStream.listen((UpdateReason reason) {
      _teamController.add(UserDatabaseData.instance.teams.values);
    });
  }

  void ngOnDestroy() {
    _sub.cancel();
  }

  String get profileUrl {
    return "assets/defaultavatar2.png";
  }

  void openToday() {
    _router.navigate("a/games");
  }
}
