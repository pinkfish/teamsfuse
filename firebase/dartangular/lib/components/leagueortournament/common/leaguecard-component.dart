import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:fusemodel/fusemodel.dart';

class TimeStuff {
  num hour;
  num minute;
  bool am;

  @override
  String toString() => "TimeStuff [$hour:$minute $am]";
}

@Component(
  selector: 'league-card',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    NgIf,
    NgSwitch,
    NgSwitchDefault,
    NgSwitchWhen,
    RouterLink
  ],
  templateUrl: 'leaguecard-component.html',
  styleUrls: const [
    'leaguecard-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class LeagueCardComponent {
  @Input()
  LeagueOrTournament leagueOrTournament;
  final Router _router;

  LeagueCardComponent(this._router);

  String get leagueUrl =>
      leagueOrTournament.photoUrl ?? "assets/" + "Sport.Basketball" + ".png";

  void openDetails() {
    print('Doing exciting stuff');
    if (UserDatabaseData.instance.userAuth.currentUserNoWait() != null) {
      _router.navigate("/a/league/detail/" + leagueOrTournament.uid);
    } else {
      _router.navigate("/g/league/detail/" + leagueOrTournament.uid);
    }
  }
}
