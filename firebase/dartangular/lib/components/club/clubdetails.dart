import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:fusemodel/fusemodel.dart';

import 'teamexpansionpanel.dart';

@Component(
  selector: 'club-details',
  directives: const [
    NgIf,
    NgFor,
    TeamExpansionPanelComponent,
    MaterialExpansionPanelSet,
  ],
  templateUrl: 'clubdetails.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class ClubDetailsComponent implements OnDestroy, OnInit {
  @Input()
  Club club;

  Iterable<Team> teamsCached;
  StreamSubscription<Iterable<Team>> _sub;
  DatabaseUpdateModel _db;

  ClubDetailsComponent(this._db);

  @override
  void ngOnInit() {
    print('New details $club');

    _sub = _db.getClubTeams(club, true).listen((Iterable<Team> teams) {
      teamsCached = teams;
    });
  }

  String get clubUrl {
    if (club.photoUrl != null && !club.photoUrl.isEmpty) {
      return club.photoUrl;
    }
    if (club.sport == null) {
      club = club.rebuild((b) => b..sport = Sport.Basketball);
    }
    // Default asset.
    return "assets/" + club.sport.toString() + ".png";
  }

  String get sportDetails {
    return club.sport.toString().substring(6);
  }

  String get trackAttendence {
    switch (club.trackAttendence) {
      case Tristate.Unset:
        return "Set by team";
      case Tristate.Yes:
        return "Always";
      case Tristate.No:
        return "Never";
    }
    return "Unknown";
  }

  String get arriveEarly {
    if (club.arriveBeforeGame == null) {
      return "Set by team";
    }
    return "${club.arriveBeforeGame} minutes";
  }

  bool get isAttendenceVisible {
    return club.trackAttendence != Tristate.Unset;
  }

  Object trackByTeam(int index, dynamic team) => team is Team ? team.uid : "";

  @override
  void ngOnDestroy() {
    print('Destroy them my club robots');
    _sub.cancel();
  }
}
