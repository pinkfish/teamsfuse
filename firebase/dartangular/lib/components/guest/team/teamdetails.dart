import 'package:angular/angular.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_router/angular_router.dart';
import 'package:teamfuse/components/common/constants.dart';
import 'package:teamfuse/util/algolia/algolia.dart';

@Component(
  selector: 'team',
  templateUrl: 'teamdetails.html',
  directives: [
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    NgIf,
  ],
  styleUrls: const [],
)
class TeamDetailsComponent implements OnActivate {
  String _curTeamId;
  Algolia _algolia;

  bool needLogin;
  String teamName;
  String photoUrl;
  Gender gender;
  Sport sport;

  Location _location;
  Router _router;

  TeamDetailsComponent(this._location, this._router)
      : needLogin = false,
        _algolia =
            new Algolia(Constants.kAlgoliaAppId, Constants.kAlgoliaKey) {}

  @override
  void onActivate(RouterState previous, RouterState current) async {
    _curTeamId = current.parameters['id'];
    if (_curTeamId == null) {
      _curTeamId = current.queryParameters['id'];
    }
    print('$_curTeamId -- ${UserDatabaseData.instance.teams[_curTeamId]}');
    String objectId = current.queryParameters[Constants.kObjectId];
    if (objectId == null) {
      needLogin = true;
    } else {
      // Lookup this specific object id on algolia.
      Map<String, dynamic> data = await _algolia.get('teams', objectId);
      teamName = data['name'] as String;
      photoUrl = data['photourl'] as String;
      sport = Sport.values.firstWhere(
          (Sport s) => s.toString() == data['sport'],
          orElse: () => Sport.Other);
      gender = Gender.values.firstWhere(
          (Gender s) => s.toString() == data['gender'],
          orElse: () => Gender.NA);
    }
  }

  String get genderIcon {
    if (gender == null) {
      return "help";
    }
    switch (gender) {
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

  String get sportDetails {
    if (sport == null) {
      return "Unknown";
    }
    return sport.toString().substring(6);
  }

  String getPhotoUrl() {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return photoUrl;
    }
    if (sport != null) {
      return _location.normalizePath("/assets/" + sport.toString() + ".png");
    }
    return _location.normalizePath("/assets/defaultavatar2.png");
  }

  void signIn() {
    _router.navigate("/login");
  }
}
