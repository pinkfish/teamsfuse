import 'package:angular/angular.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:fusemodel/fusemodel.dart';

@Component(
  selector: 'delete-from-team',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    materialInputDirectives,
    formDirectives
  ],
  templateUrl: 'deletegamesfromteam.html',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class DeleteGamesFromTeamComponent  {
  String teamUid;
  bool submitting = false;
  bool error = true;

  DeleteGamesFromTeamComponent();

  void onSubmit() async {
    FilterDetails fd = new FilterDetails();
    fd.allGames = true;
    fd.teamUids.add(teamUid);
    /*
    Iterable<Game> games = UserDatabaseData.instance.teams[teamUid];
    print("Got back ${games.length} games");
    games.forEach((Game g) {
      print("${g.uid} ${g.teamUid} ${g.place.name}");
      g.deleteFromFirestore().then((c) {
        print("Deleted ${g.uid}");
      });
    });
    */
  }

  Map<String, bool> setCssValidityClass(NgControl control) {
    final validityClass = control.valid == true ? 'is-valid' : 'is-invalid';
    return {validityClass: true};
  }
}