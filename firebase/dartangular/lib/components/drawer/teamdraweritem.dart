import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';

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

    _router.navigate("a/team/" + team.uid);
  }
}
