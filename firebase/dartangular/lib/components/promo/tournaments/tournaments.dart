import 'package:angular/angular.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/content/deferred_content.dart';

@Component(
  selector: 'my-tournaments',
  templateUrl: 'tournaments.html',
  directives: [
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
  ],
  styleUrls: const [
    '../league/league.css',
  ],
)
class TournamentsComponent {

  TournamentsComponent();
}
