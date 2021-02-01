import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:teamfuse/components/games/gamecard-component.dart';

import 'seasonexpansionpanel.dart';

@Component(
  selector: 'team-details',
  directives: const [
    NgIf,
    NgFor,
    GameCardComponent,
    SeasonExpansionPanelComponent,
    MaterialExpansionPanelSet,
  ],
  templateUrl: 'teamdetails.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class TeamDetailsComponent implements OnDestroy, OnInit, OnActivate {
  @Input()
  Team? team;
  @Input()
  bool noDefaultIcon = false;
  StreamController<Iterable<Season>>? _seasonController;
  StreamSubscription<Iterable<Season>>? _seasonSub;
  Stream<Iterable<Season>>? _seasonStream;
  DatabaseUpdateModelImpl _db;

  Location _location;

  TeamDetailsComponent(this._location, this._db);

  @override
  void ngOnInit() {
    _seasonController = new StreamController<Iterable<Season>>();
  }

  @override
  void onActivate(RouterState previous, RouterState current) {}

  String get sportDetails {
    return team!.sport.toString().substring(6);
  }

  Stream<Iterable<Season>> get getAllSeasons {
    if (_seasonStream != null) {
      return _seasonStream!;
    }
    _seasonSub = _db.getSeasonsForTeam(team!.uid).listen((event) {
      _seasonController?.add(event);
    });
    _seasonStream = _seasonController?.stream.asBroadcastStream();
    return _seasonStream!;
  }

  String get genderIcon {
    switch (team!.gender) {
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
    switch (team!.gender) {
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

  String get teamUrl {
    if (team!.photoUrl != null && !team!.photoUrl.isEmpty) {
      return team!.photoUrl;
    }
    // Default asset.
    return _location
        .normalizePath("/assets/" + team!.sport.toString() + ".png");
  }

  bool get displayIcon {
    return (team!.photoUrl != null && !team!.photoUrl.isEmpty) ||
        !noDefaultIcon;
  }

  @override
  void ngOnDestroy() {
    print('Destroy them my robots');
    _seasonController?.close();
    _seasonSub?.cancel();
  }

  Object trackBySeason(int index, dynamic season) =>
      season is Season ? season.uid : "";
}
