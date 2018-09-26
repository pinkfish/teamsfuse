import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
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
class TeamDetailsComponent implements OnDestroy, OnInit {
  @Input()
  Team team;
  @Input()
  bool noDefaultIcon = false;

  TeamDetailsComponent();

  @override
  void ngOnInit() {
    print('New team details ${team?.seasons}');
  }

  String get sportDetails {
    return team.sport.toString().substring(6);
  }

  String get genderIcon {
    switch (team.gender) {
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
    switch (team.gender) {
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
    if (team.photoUrl != null && !team.photoUrl.isEmpty) {
      return team.photoUrl;
    }
    // Default asset.
    return "assets/" + team.sport.toString() + ".png";
  }

  bool get displayIcon {
    return (team.photoUrl != null && !team.photoUrl.isEmpty) || !noDefaultIcon;
  }

  @override
  void ngOnDestroy() {
    print('Destroy them my robots');
  }

  Object trackBySeason(int index, dynamic season) =>
      season is Season ? season.uid : "";
}
