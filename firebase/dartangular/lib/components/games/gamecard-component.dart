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
import 'package:google_maps/google_maps_places.dart';
import 'inputdata.dart';
import 'dart:html';

class TimeStuff {
  num hour;
  num minute;
  bool am;

  @override
  String toString() => "TimeStuff [$hour:$minute $am]";
}

@Component(
  selector: 'game-card',
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
  templateUrl: 'gamecard-component.html',
  styleUrls: const [
    'games-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class GameCardComponent {
  @Input()
  Game game;
  List<String> files;
  static DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  static DateFormat dateWithTimeFormat =
      new DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY);
  static DateFormat justTimeFormat = new DateFormat(DateFormat.HOUR_MINUTE);
  static const String API_KEY = "AIzaSyCP22ZMhWoQuzH9qIEnxYL7C_XfjWjo6tI";
  static Uri GOOGLE_PLACE_SEARCH =
      Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json");
  Map<String, PlaceResult> placesResults = InputData.getDefaultPlaceResult();
  @ViewChild('mapArea')
  ElementRef mapAreaRef;
  final Router _router;

  GameCardComponent(this._router);

  Opponent get opponent {
    return UserDatabaseData
        .instance.teams[game.teamUid].opponents[game.opponentUids[0]];
  }

  Team get team {
    return UserDatabaseData.instance.teams[game.teamUid];
  }

  String get teamName => team?.name ?? "Unknown";

  String get teamUrl {
    if (team.photoUrl != null && !team.photoUrl.isEmpty) {
      return team.photoUrl;
    }
    // Default asset.
    return "assets/" + team.sport.toString() + ".png";
  }

  void openDetails() {
    print('Doing exciting stuff');
    _router.navigate("/a/game/" + game.uid);
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


    if (finalResult != null) {
      String ret = "${finalResult.score.ptsFor} - ${finalResult.score
          .ptsAgainst}";
      if (overtimeResult != null) {
        ret += " OT: ${overtimeResult.score.ptsFor} - ${overtimeResult.score
            .ptsAgainst}";
      }
      if (penaltyResult != null) {
        ret += " Penalty: ${penaltyResult.score.ptsFor} - ${penaltyResult.score
            .ptsAgainst}";
      }
      return ret;
    } else {
      return "Unknown score";
    }
  }

  /*
  void doLoadCsv() async {
    // Date,Start Time,End Time,Arrival Time,Game / Event Name,Location,Address,Result

    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter(eol: '\n').convert(InputData.PINNACLE_2017);
    String myTeamUid = "-LAZR50FSouk68mNwHY-";
    String mySeasonUid = "-LAgNoEB9kbvzZ03NePp";
    print("${rowsAsListOfValues.length} ${local.name}");
    Map<String, Opponent> createdOpponents = {};
    GMap map = new GMap(
        mapAreaRef.nativeElement,
        new MapOptions()
          ..center = new LatLng(47.4979, 19.0402)
          ..zoom = 15);
    PlacesService placesService = new PlacesService(map);
    print(placesResults["redmond high school"].geometry.location.lat);
    for (int i = 0; i < rowsAsListOfValues.length; i++) {
      List<dynamic> d = rowsAsListOfValues[i];
      String startDate = d[0].trim();
      String startTime = d[1].trim();
      String endTime = d[2].trim();
      String arrivalTime = d[3].trim();
      String eventName = d[4];
      String locStr = d[5];
      String address = d[6].trim();
      String result = d[7].trim();
      Location loc = getLocation("America/Los_Angeles");
      List<int> bits =
          startDate.split("/").map((String s) => int.parse(s)).toList();

      TimeStuff stuff = getTime(startTime);
      TZDateTime startTZTime = new TZDateTime(
          loc, bits[2], bits[0], bits[1], stuff.hour, stuff.minute);

      TZDateTime endTZTime;
      if (endTime.length > 1) {
        TimeStuff endStuff = getTime(endTime);
        endTZTime = new TZDateTime(
            loc, bits[2], bits[0], bits[1], endStuff.hour, endStuff.minute);
      } else {
        endTZTime = startTZTime;
      }
      TimeStuff arrivalStuff = getTime(arrivalTime);
      TZDateTime arriveTZTime = new TZDateTime(loc, bits[2], bits[0], bits[1],
          arrivalStuff.hour, arrivalStuff.minute);

      // Parse result.
      // Skip the L/W
      int ptsFor = 0;
      int ptsAgainst = 0;
      int penaltyPtsFor = 0;
      int penaltyPtsAgainst = 0;
      bool pentalty = false;
      bool finalRes = false;
      if (result.length > 2) {
        if (result.contains("(PK ")) {
          List<String> parts = result.split("(PK ");
          parts[1] = parts[1].substring(0, parts[1].length - 1);
          result = parts[0].trim();
          List<int> pts =
              parts[1].split("-").map((String s) => int.parse(s)).toList();
          penaltyPtsFor = pts[0];
          penaltyPtsAgainst = pts[1];
          pentalty = true;
        }
        finalRes = true;
        List<int> pts = result
            .substring(2)
            .split("-")
            .map((String s) => int.parse(s))
            .toList();
        ptsFor = pts[0];
        ptsAgainst = pts[1];
        print("$ptsFor - $ptsAgainst (PK $penaltyPtsFor - $penaltyPtsAgainst)");
      }

      // Lookup the address in the places search.
      PlaceResult place;
      if (address.isEmpty && location.length > 5) {
        address = location;
      }
      if (address.length > 5) {
        if (placesResults.containsKey(address.toLowerCase())) {
          place = placesResults[address.toLowerCase()];
          address = place.formattedAddress;
        } else {
          Completer<List<PlaceResult>> completeResults =
              new Completer<List<PlaceResult>>();
          TextSearchRequest req = new TextSearchRequest();
          req.query = address;

          placesService.textSearch(req, (List<PlaceResult> results,
              PlacesServiceStatus status, PlaceSearchPagination pag) {
            print("In here $results $status $pag");
            completeResults.complete(results);
          });
          List<PlaceResult> results = await completeResults.future;
          print("Results $results");
          if (results != null && results.length > 0) {
            placesResults[address.toLowerCase()] = results[0];
            place = results[0];
          }
          address = place.formattedAddress;
        }
      }

      Game game = new Game();
      game.time = startTZTime.millisecondsSinceEpoch;
      game.arriveTime = arriveTZTime.millisecondsSinceEpoch;
      game.endTime = endTZTime.millisecondsSinceEpoch;
      game.timezone = loc.name;
      game.place = new GamePlace();
      game.place.address = address;
      game.place.name = location;
      if (place != null) {
        game.place.placeId = place.placeId;
        game.place.name = place.name;
        game.place.longitude = place.geometry.location.lng;
        game.place.latitude = place.geometry.location.lat;
      }
      if (location.toLowerCase() == "tbd") {
        game.place.unknown = true;
      }
      game.homegame = false;
      game.teamUid = myTeamUid;
      game.seasonUid = mySeasonUid;
      game.trackAttendance = true;
      game.uniform = "";
      game.attendance = {};
      game.seriesId = null;
      if (eventName.startsWith("Training") ||
          eventName.startsWith("Team Practice") ||
          eventName.contains("Training") ||
          eventName.startsWith("Practice")) {
        List<String> splits = eventName.split("(");
        if (splits.length > 1) {
          game.uniform = splits[1].split(")")[0];
        } else {
          game.uniform = '';
        }
        game.type = EventType.Practice;
        game.notes = "";
      } else if (eventName.contains("vs. ") || eventName.contains("at ")) {
        // Game.
        game.type = EventType.Game;
        List<String> bits;
        if (eventName.contains("vs. ")) {
          bits = eventName.split("vs. ");
          game.homegame = true;
        } else {
          bits = eventName.split("at ");
        }
        String opponent = bits[1].trim();
        game.notes = bits[0].trim();
        // Lets see if we can find an opponent of this name.
        String foundOpponentUid = null;
        UserDatabaseData.instance.teams[myTeamUid].opponents
            .forEach((String opponentUid, Opponent op) {
          if (op.name.toLowerCase().compareTo(opponent.toLowerCase()) == 0) {
            foundOpponentUid = opponentUid;
          }
        });
        if (foundOpponentUid == null &&
            createdOpponents.containsKey(opponent.toLowerCase())) {
          foundOpponentUid = createdOpponents[opponent.toLowerCase()].uid;
        }
        if (foundOpponentUid == null) {
          Opponent op = new Opponent();
          op.teamUid = myTeamUid;
          op.name = opponent;
          op.contact = "";
          foundOpponentUid = await op.updateFirestore();
        }
        print("Found opponent $foundOpponentUid $opponent");
        game.opponentUid = foundOpponentUid;
      } else {
        print("Event $eventName");
        game.notes = eventName;
        game.type = EventType.Event;
      }
      game.result = new GameResultDetails();
      if (finalRes) {
        game.type = EventType.Game;
        game.result.inProgress = GameInProgress.Final;
        GamePeriod period =
            new GamePeriod(periodNumber: 0, type: GamePeriodType.Regulation);
        game.result.scores[period] = new GameResultPerPeriod(
          period: period,
          score: new GameScore(ptsFor: ptsFor, ptsAgainst: ptsAgainst),
        );

        if (pentalty) {
          GamePeriod period =
              new GamePeriod(periodNumber: 0, type: GamePeriodType.Penalty);
          game.result.scores[period] = new GameResultPerPeriod(
            period: period,
            score: new GameScore(
                ptsFor: penaltyPtsFor, ptsAgainst: penaltyPtsAgainst),
          );
        }
        print("${game.result.scores}");
        if (ptsFor > ptsAgainst || penaltyPtsFor > penaltyPtsAgainst) {
          game.result.result = GameResult.Win;
        } else if (ptsFor == ptsAgainst && penaltyPtsFor == penaltyPtsAgainst) {
          game.result.result = GameResult.Tie;
        } else {
          game.result.result = GameResult.Loss;
        }
      } else {
        game.result.result = GameResult.Unknown;
        game.result.inProgress = GameInProgress.NotStarted;
      }
      game.uid = null;
      await game.updateFirestore();
    }
    print("$placesResults");
  }
  */

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

  /*
  void onSubmit() {
    doLoadCsv();
  }
  */
}
