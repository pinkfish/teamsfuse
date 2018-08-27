// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'drawer-team',
  directives: const [
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    RouterLink,
  ],
  templateUrl: 'teamdraweritem.html',
  styleUrls: const [],
)
class TeamDrawerItem {
  @Input()
  Team team;

  final Router _router;

  TeamDrawerItem(this._router);

  void openTeam() {
    print('openTeam()');

    _router.navigate("a/teams/" + team.uid);
  }
}
