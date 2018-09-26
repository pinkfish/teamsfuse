import 'package:angular/angular.dart';

import 'package:angular_router/angular_router.dart';
import 'routes.dart';
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_tab/fixed_material_tab_strip.dart';
import 'package:angular_components/material_tab/tab_change_event.dart';

@Component(
  selector: 'my-guest',
  templateUrl: 'guest-component.html',
  directives: [
    RouterLink,
    RouterOutlet,
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    FixedMaterialTabStripComponent,
  ],
  providers: [
    const ClassProvider(Routes),
  ],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
  //providers: const [HeroService],
)
class GuestComponent implements OnActivate {
  final Routes routes;
  int tabIndex = 0;
  bool stopChange = false;
  final Router _router;

  @override
  void onActivate(RouterState previous, RouterState current) {
    String testPath = "/" + current.path;
    tabIndex =
        _tabLabelsInner.indexWhere((_LabelStuff l) => l.route == testPath);
  }

  void onTabChange(TabChangeEvent event) {
    tabIndex = event.newIndex;
    _router.navigate(_tabLabelsInner[tabIndex].route);
  }

  void onBeforeTabChange(TabChangeEvent event) {
    if (stopChange) {
      event.preventDefault();
    }
  }

  final _tabLabelsInner = const <_LabelStuff>[
    const _LabelStuff(label: 'Teams', route: '/g/guesthome'),
    const _LabelStuff(label: 'Leagues', route: '/g/guestleague'),
    const _LabelStuff(label: 'Tournaments', route: '/g/guesttournaments'),
  ];

  List<String> get tabLabels =>
      _tabLabelsInner.map((_LabelStuff l) => l.label).toList();

  GuestComponent(this._router, this.routes);
}

class _LabelStuff {
  final String label;
  final String route;

  const _LabelStuff({this.label, this.route});
}
