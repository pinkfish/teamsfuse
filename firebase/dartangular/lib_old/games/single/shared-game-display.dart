import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:google_maps/google_maps.dart';
import 'package:intl/intl.dart';

@Component(
  selector: 'shared-game-display',
  directives: const [
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    NgIf,
    NgSwitch,
    NgSwitchDefault,
    NgSwitchWhen,
    formDirectives,
    RouterLink
  ],
  templateUrl: 'shared-game-display.html',
  styleUrls: const [
    'game-display-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class SharedGameDisplayComponent implements OnInit, AfterViewInit {
  @Input()
  GameSharedData game;
  List<String> files;
  static DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  static DateFormat timeFormat = new DateFormat(DateFormat.HOUR_MINUTE);

  GMap map;

  SharedGameDisplayComponent();

  Team homeTeam;
  LeagueOrTournamentTeam homeLeagueTeam;
  Team awayTeam;
  LeagueOrTournamentTeam awayLeagueTeam;
  GameFromOfficial homeTeamResult;

  Marker marker;

  @ViewChild('mapArea')
  HtmlElement mapAreaRef;

  @override
  void ngOnInit() {
    UserDatabaseData.instance.updateModel
        .getLeagueTeamData(game.officialResults.awayTeamLeagueUid)
        .then((LeagueOrTournamentTeam team) {
      awayLeagueTeam = team;
      UserDatabaseData.instance.updateModel
          .getPublicTeamDetails(team.teamUid)
          .then((Team t) {
        awayTeam = t;
      });
    });
    UserDatabaseData.instance.updateModel
        .getLeagueTeamData(game.officialResults.homeTeamLeagueUid)
        .then((LeagueOrTournamentTeam team) {
      homeLeagueTeam = team;
      UserDatabaseData.instance.updateModel
          .getPublicTeamDetails(team.teamUid)
          .then((Team t) {
        homeTeam = t;
      });
    });
    homeTeamResult =
        GameFromOfficial(game, game.officialResults.awayTeamLeagueUid);
  }

  @override
  void ngAfterViewInit() {
    print('lat/.long ${game.place.latitude} ${game.place.longitude}');
    map = GMap(
        mapAreaRef,
        new MapOptions()
          ..zoom = 15
          ..center = new LatLng(game.place.latitude, game.place.longitude));
    marker = new Marker(new MarkerOptions()
      ..map = map
      ..draggable = true
      ..label = game.place.name
      ..position = new LatLng(game.place.latitude, game.place.longitude));
  }

  String get homeResultClass {
    switch (homeTeamResult.result) {
      case GameResult.Win:
        return "win";
      case GameResult.Loss:
        return "loss";
      case GameResult.Tie:
        return "tie";
      case GameResult.Unknown:
        return "";
    }
    return "";
  }

  String get awayResultClass {
    switch (homeTeamResult.result) {
      case GameResult.Win:
        return "loss";
      case GameResult.Loss:
        return "win";
      case GameResult.Tie:
        return "tie";
      case GameResult.Unknown:
        return "";
    }
    return "";
  }

  String get mapUrl {
    // Do something in here to show the map.
    return "fluff";
  }

  String get homeTeamUrl {
    if (homeTeam == null) {
      return "assets/defaultavatar2.png";
    }

    if (homeTeam.photoUrl != null) {
      return homeTeam.photoUrl;
    }
    return "assets/" + homeTeam.sport.toString() + ".png";
  }

  String get awayTeamUrl {
    if (awayTeam == null) {
      return "assets/defaultavatar2.png";
    }

    if (awayTeam.photoUrl != null) {
      return awayTeam.photoUrl;
    }
    return "assets/" + awayTeam.sport.toString() + ".png";
  }

  void openDirections() {
    String navTo = "https://www.google.com/maps/dir/?api=1&destination=" +
        game.place.address;
    if (game.place.placeId != null && game.place.placeId.isNotEmpty) {
      navTo += "&destination_place_id=" + game.place.placeId;
    }
    window.open(navTo, '_top');
    //_router.navigateByUrl(navTo, replace: true);
  }
}
