// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:teamfuse/components/games/gamecard-component.dart';
import 'dart:async';

import 'seasonexpansionpanel.dart';

@Component(
  selector: 'team-details',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    GameCardComponent,
    SeasonExpansionPanelComponent,
  ],
  templateUrl: 'teamdetails.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class TeamDetailsComponent implements OnDestroy, OnInit {
  @Input()
  Team team;

  TeamDetailsComponent();

  @override
  void ngOnInit() {
    print('New details');
  }

  String get sportDetails {
    return team.sport.toString().substring(6);
  }

  String get genderIcon {
    switch (team.gender) {
      case Gender.Coed:
        return "gender-male-female";
      case Gender.Female:
        return "gender-female";
      case Gender.Male:
        return "gender-male";
      case Gender.NA:
        return "help";
    }
  }

  String get gender {
    switch (team.gender) {
      case Gender.Coed:
        return "Coed";
      case Gender.Female:
        return "Female";
      case Gender.Male:
        return "Male";
      case Gender.NA:
        return "N/A";
    }
  }

  String get teamUrl {
    if (team.photoUrl != null && !team.photoUrl.isEmpty) {
      return team.photoUrl;
    }
    // Default asset.
    return "assets/" + team.sport.toString() + ".png";
  }

  void ngOnDestroy() {
    print('Destroy them my robots');
  }

  Object trackBySeason(int index, dynamic season) => season is Season ? season.uid : "";
}
