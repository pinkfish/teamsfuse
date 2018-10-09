import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:angular_router/angular_router.dart';
import 'dart:async';
import 'seasonexpansionpanel.dart';

@Component(
  selector: 'league-details',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanelSet,
    SeasonExpansionPanelComponent,
  ],
  templateUrl: 'leaguedetails.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    'leaguedetails.css',
  ],
)
class LeagueDetailsComponent
    implements OnDestroy, OnInit, OnActivate, OnChanges {
  @Input()
  LeagueOrTournament league;
  Iterable<LeagueOrTournamentSeason> seasons;
  StreamSubscription<Iterable<LeagueOrTournamentSeason>> _seasonSub;
  String currentSeason;

  final Location _location;

  LeagueDetailsComponent(this._location);

  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState previous, RouterState current) {
    currentSeason = current.parameters['season'];
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    if (changes.containsKey('league')) {
      LeagueOrTournament league = changes['league'].currentValue;
      _seasonSub?.cancel();
      _seasonSub = league.seasonStream
          .listen((Iterable<LeagueOrTournamentSeason> newSeasons) {
        seasons = newSeasons;
      });
      seasons = league.cacheSeasons ?? [];
    }
  }

  String get sportDetails {
    return league.sport.toString().substring(6);
  }

  String get genderIcon {
    switch (league.gender) {
      case Gender.Coed:
        return "gender-male-female";
      case Gender.Female:
        return "gender-female";
      case Gender.Male:
        return "gender-male";
      case Gender.NA:
        return "help";
    }
    return "help";
  }

  String get gender {
    switch (league.gender) {
      case Gender.Coed:
        return "Coed";
      case Gender.Female:
        return "Female";
      case Gender.Male:
        return "Male";
      case Gender.NA:
        return "N/A";
    }
    return "Unknown";
  }

  String get leagueUrl {
    if (league.photoUrl != null && !league.photoUrl.isEmpty) {
      return league.photoUrl;
    }
    // Default asset.
    return _location
        .normalizePath("/assets/" + league.sport.toString() + ".png");
  }

  @override
  void ngOnDestroy() {
    _seasonSub?.cancel();
  }

  Object trackBySeason(int index, dynamic season) =>
      season is LeagueOrTournamentSeason ? season.uid : "";
}
