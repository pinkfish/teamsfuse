import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';

@Component(
  selector: 'drawer-club',
  directives: const [
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    RouterLink,
  ],
  templateUrl: 'clubdraweritem.html',
  styleUrls: const [],
)
class ClubDrawerItem implements OnInit, OnDestroy {
  @Input()
  Club club;
  final Router _router;

  int numTeams = 0;
  bool loadedTeams = false;

  StreamSubscription<Iterable<Team>> _teamSub;
  DatabaseUpdateModelImpl _db;

  ClubDrawerItem(this._router, this._db);

  @override
  void ngOnInit() {
    _teamSub = _db.getClubTeams(club, true).listen((e) {
      numTeams = e.length;
      loadedTeams = true;
    });

    /*
    _teamSub = club.teamStream.listen((Iterable<Team> teams) {
      numTeams = teams.length;
      loadedTeams = true;
    });

     */
  }

  @override
  void ngOnDestroy() {
    _teamSub?.cancel();
  }

  void openTeam() {
    print('openTeam()');

    _router.navigate("a/club/" + club.uid);
  }
}
