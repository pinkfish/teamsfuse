import 'package:angular/angular.dart';

import 'package:angular_router/angular_router.dart';
import 'package:teamfuse/components/promo/routes.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_tab/fixed_material_tab_strip.dart';
import 'package:angular_components/material_tab/tab_change_event.dart';
import 'package:teamfuse/components/guest/pieces/header.dart';
import 'package:teamfuse/components/guest/pieces/footer.dart';

@Component(
  selector: 'promo',
  templateUrl: 'promo-component.html',
  directives: [
    RouterLink,
    RouterOutlet,
    MaterialButtonComponent,
    FixedMaterialTabStripComponent,
    GuestHeaderComponent,
    GuestFooterComponent,
  ],
  providers: [
    const ClassProvider(Routes),
  ],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    'promo-component.css',
  ],
)
class PromoComponent implements OnActivate {
  final Location _location;
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
    _router.navigate(_location.normalizePath(_tabLabelsInner[tabIndex].route));
  }

  void onBeforeTabChange(TabChangeEvent event) {
    if (stopChange) {
      event.preventDefault();
    }
  }

  final _tabLabelsInner = const <_LabelStuff>[
    const _LabelStuff(label: 'Teams', route: 'g/promo/guesthome'),
    const _LabelStuff(label: 'Leagues', route: 'g/promo/guestleague'),
    const _LabelStuff(label: 'Tournaments', route: 'g/promo/guesttournaments'),
  ];

  List<String> get tabLabels =>
      _tabLabelsInner.map((_LabelStuff l) => l.label).toList();

  void signIn() {
    _router.navigate("/login");
  }

  void createAccount() {
    _router.navigate("/createAccount");
  }

  PromoComponent(this._router, this._location, this.routes);
}

class _LabelStuff {
  final String label;
  final String route;

  const _LabelStuff({this.label, this.route});
}
