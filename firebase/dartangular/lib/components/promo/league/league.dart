import 'package:angular/angular.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/content/deferred_content.dart';

@Component(
  selector: 'my-league',
  templateUrl: 'league.html',
  directives: [
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
  ],
  styleUrls: const [
    'league.css',
  ],
)
class LeagueComponent implements OnInit {
  LeagueComponent();

  @override
  void ngOnInit() {}

  void search(String text) {}
}
