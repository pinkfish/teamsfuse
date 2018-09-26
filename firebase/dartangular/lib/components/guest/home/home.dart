import 'package:angular/angular.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/content/deferred_content.dart';

@Component(
  selector: 'my-home',
  templateUrl: 'home.html',
  directives: [
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
  ],
  styleUrls: const [
     'home.css',
  ],
)
class HomeComponent {

  String get calendarUrl {
    return "assets/screenshot/calendarview.png";
  }

  HomeComponent();
}
