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
  StreamSubscription<Iterable<LeagueOrTournamentSeason>> _seasonSub;
  StreamController<Iterable<LeagueOrTournamentSeason>> _seasonController;
  Stream<Iterable<LeagueOrTournamentSeason>> seasonStream;

  LeagueDetailsComponent();

  @override
  void ngOnInit() {
    _seasonController =
        new StreamController<Iterable<LeagueOrTournamentSeason>>();
    seasonStream = _seasonController.stream.asBroadcastStream();
  }

  @override
  void onActivate(RouterState previous, RouterState current) {}

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    if (changes.containsKey('league')) {
      LeagueOrTournament league = changes['league'].currentValue;
      _seasonController.add(league.cacheSeasons ?? []);
      _seasonSub?.cancel();
      _seasonSub = league.seasonStream
          .listen((Iterable<LeagueOrTournamentSeason> newSeasons) {
        _seasonController.add(newSeasons);
      });
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
    return "assets/" + league.sport.toString() + ".png";
  }

  @override
  void ngOnDestroy() {
    _seasonController?.close();
    _seasonSub?.cancel();
  }

  Object trackBySeason(int index, dynamic season) =>
      season is LeagueOrTournamentSeason ? season.uid : "";
}
