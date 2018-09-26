import 'package:angular/angular.dart';
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:teamfuse/services/isfirebaseauth.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'teamfuse-drawer',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialPersistentDrawerDirective,
    MaterialListComponent,
    MaterialListItemComponent,
    NgFor,
    IfFirebaseAuthDirective,
  ],
  templateUrl: 'drawer.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'drawer.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class Drawer implements OnInit, OnDestroy {
  bool customWidth = false;
  bool end = false;
  final Router _router;

  Drawer(this._router);


  @override
  void ngOnInit() {
  }

  @override
  void ngOnDestroy() {
  }

  String get profileUrl {
    return "assets/defaultavatar2.png";
  }

  void openInfo() {

  }

  void openLogin() {
    _router.navigate("/login");
  }
}
