import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_router/angular_router.dart';
import 'dart:async';

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

  int numTeams = 0;
  bool loadedTeams = false;

  final Router _router;

  StreamSubscription<Iterable<Team>> _teamSub;

  ClubDrawerItem(this._router);

  @override
  void ngOnInit() {
    if (club.cachedTeams != null) {
      numTeams = club.cachedTeams.length;
      loadedTeams = true;
    }
    _teamSub = club.teamStream.listen((Iterable<Team> teams) {
      numTeams = teams.length;
      loadedTeams = true;
    });
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
