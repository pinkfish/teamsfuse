import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:teamfuse/util/algolia/algolia.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'constants.dart';

@Component(
  selector: 'search-item',
  templateUrl: 'searchitem.html',
  directives: [coreDirectives, formDirectives],
  styleUrls: const [
    'searchitem.css',
  ],
)
class SearchItemComponent implements OnInit {
  @Input()
  SearchItem item;

  bool hasPhotoUrl;

  final Router _router;
  final Location _location;

  String genderIcon;

  SearchItemComponent(this._router, this._location);

  @override
  void ngOnInit() {
    hasPhotoUrl = item.data.containsKey('photourl');
    if (!hasPhotoUrl) {
      String id = item.data['objectID'] as String;
      hasPhotoUrl = (id[0] == 'T' || id[0] == 'L');
    }
    String gender = item.data['gender'] as String;
    if (gender != null) {
      Gender ge = Gender.values.firstWhere(
          (Gender g) => g.toString() == gender,
          orElse: () => Gender.NA);
      switch (ge) {
        case Gender.Coed:
          genderIcon = "gender-male-female";
          break;
        case Gender.Female:
          genderIcon = "gender-female";
          break;
        case Gender.Male:
          genderIcon = "gender-male";
          break;
        case Gender.NA:
          genderIcon = "help";
          break;
      }
    }
  }

  String get type {
    if (item == null) {
      return "";
    }
    String sport = item.data['sport'];

    switch ((item.data['objectID'] as String)[0]) {
      case 'T':
        return  "${sport.substring(6)} Team ";
        break;
      case 't':
        return 'Team in league ${item.data["leagueName"]}';
        break;
      case 'L':
        return "${sport.substring(6)} League ";
      default:
        return "";
    }
  }

  String getTitle() {
    if (item.highlightResult.result.containsKey('name')) {
      return item.highlightResult.result['name'].value;
    }
    return item.data['name'] as String;
  }

  String getPhotoUrl() {
    String photoUrl = item.data['photourl'] as String;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return item.data['photourl'] as String;
    }
    String sport = item.data['sport'];
    if (sport != null) {
      return _location.normalizePath('/assets/' + sport + ".png");
    }
    return _location.normalizePath('/assets/defaultavatar2.png');
  }

  String getBody() {
    String leagueSeasonName = item.data['leagueSeasonName'];
    String leagueDivisonName = item.data['leagueDivisonName'];
    if (leagueSeasonName != null && leagueDivisonName != null) {
      return "${leagueSeasonName} - ${leagueDivisonName}";
    }
    if (item.highlightResult.result.containsKey('description')) {
      return item.highlightResult.result['description'].value;
    }
    return item.data['description'] as String;
  }

  void openDetails() {
    String path;
    String objectId = item.data['objectID'] as String;
    String uid = objectId.substring(1);

    switch (objectId[0]) {
      case 't':
        path = 'league/team/' + uid;
        break;
      case 'L':
        path = 'league/detail/' + uid;
        break;
      case 'T':
        path = 'team/' + uid;
        break;
      default:
        // Hmmm.
        return;
    }
    NavigationParams params = new NavigationParams(queryParameters: {
      Constants.kObjectId: objectId
    });
    if (UserDatabaseData.instance.userAuth.currentUserNoWait() != null) {
      // Authed.
      _router.navigate('/a/' + path, params);
    } else {
      _router.navigate('/g/' + path, params);
    }
  }
}
