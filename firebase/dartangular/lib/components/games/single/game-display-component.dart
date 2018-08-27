import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:google_maps/google_maps_places.dart';

class TimeStuff {
  num hour;
  num minute;
  bool am;

  String toString() => "TimeStuff [$hour:$minute $am]";
}

@Component(
  selector: 'game-display',
  directives: const [
    DeferredContentDirective,
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
  templateUrl: 'game-display-component.html',
  styleUrls: const [
    'game-display-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class GameDisplayComponent {
  @Input()
  Game game;
  List<String> files;
  static DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  static DateFormat dateWithTimeFormat =
  new DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY);
  static DateFormat justTimeFormat = new DateFormat(DateFormat.HOUR_MINUTE_TZ);
  static const String API_KEY = "AIzaSyCP22ZMhWoQuzH9qIEnxYL7C_XfjWjo6tI";
  static Uri GOOGLE_PLACE_SEARCH =
  Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json");
  @ViewChild('mapArea')
  ElementRef mapAreaRef;
  final Router _router;

  GameDisplayComponent(this._router);

  Opponent get opponent {
    return UserDatabaseData
        .instance.teams[game.teamUid].opponents[game.opponentUids[0]];
  }

  Team get team {
    return UserDatabaseData.instance.teams[game.teamUid];
  }

  String get teamUrl {
    if (team.photoUrl != null && !team.photoUrl.isEmpty) {
      return team.photoUrl;
    }
    // Default asset.
    return "assets/" + team.sport.toString() + ".png";
  }

  String gameResult() {
    GameResultPerPeriod finalResult;
    GameResultPerPeriod overtimeResult;
    GameResultPerPeriod penaltyResult;
    for (GameResultPerPeriod result in game.result.scores.values) {
      switch (result.period.type) {
        case GamePeriodType.Regulation:
          finalResult = result;
          break;
        case GamePeriodType.Overtime:
          overtimeResult = result;
          break;
        case GamePeriodType.Penalty:
          penaltyResult = result;
          break;
        default:
          break;
      }
    }


    String ret = "${finalResult.score.ptsFor} - ${finalResult.score.ptsAgainst}";
    if (overtimeResult != null) {
      ret += " OT: ${overtimeResult.score.ptsFor} - ${overtimeResult.score.ptsAgainst}";
    }
    if (penaltyResult != null) {
      ret += " Penalty: ${penaltyResult.score.ptsFor} - ${penaltyResult.score.ptsAgainst}";
    }
    return ret;
  }

  TimeStuff getTime(String str) {
    TimeStuff ret = new TimeStuff();
    List<String> place = str.split(":");
    ret.hour = int.parse(place[0]);
    if (place[1].endsWith("AM")) {
      ret.am = true;
    } else {
      ret.am = false;
      ret.hour += 12;
    }
    place[1] = place[1].substring(0, place[1].length - 2).trim();
    ret.minute = int.parse(place[1]);
    print("$str => $ret");
    return ret;
  }
}
