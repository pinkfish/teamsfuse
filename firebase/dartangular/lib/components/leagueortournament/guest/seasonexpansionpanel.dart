import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'dart:async';
import 'package:teamfuse/components/leagueortournament/guest/divisonexpansionpanel.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'season-expansionpanel',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    DivisonExpansionPanelComponent,
    DeferredContentDirective,
  ],
  templateUrl: 'seasonexpansionpanel.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class SeasonExpansionPanelComponent implements OnDestroy, OnInit, OnActivate {
  @Input()
  LeagueOrTournament league;
  @Input()
  LeagueOrTournamentSeason season;

  bool enabled;

  Iterable<LeagueOrTournamentDivison> divisons;
  StreamSubscription<Iterable<LeagueOrTournamentDivison>> _subscription;

  final Router _router;
  final Location _location;

  SeasonExpansionPanelComponent(this._router, this._location);

  @override
  void onActivate(RouterState previous, RouterState current) {}

  @override
  void ngOnInit() {
    print('Making panel ${_router.current.queryParameters}');
    enabled = _router.current.queryParameters['season'] == season.uid;
    _subscription = season.divisonStream
        .listen((Iterable<LeagueOrTournamentDivison> divison) {
      print('Update divison ${divison.length}');

      divisons = divison;
    });
    divisons = season.cacheDivisions ?? [];
  }

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
    _subscription = null;
  }

  void openPanel() {
    // If we already are in the url, don't rewrite it.
    if (_router.current.queryParameters.containsKey('season')) {
      return;
    }
    List<String> bits = _location.path().split('?');
    _location.replaceState(bits[0], 'season=${season.uid}');

    enabled = true;
  }

  void closePanel() {
    _router.navigate(
        _router.current.path,
        NavigationParams(
          updateUrl: true,
          reload: false,
          replace: true,
          queryParameters: {},
        ));
    enabled = false;
  }

  Object trackByDivison(int index, dynamic divison) =>
      divison is LeagueOrTournamentDivison ? divison.uid : "";
}
