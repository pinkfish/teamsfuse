import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:google_maps/google_maps_places.dart';
import 'package:google_maps/google_maps.dart';
import 'dart:js';
import 'dart:js_util';
import 'dart:html';
import 'package:angular_components/material_button/material_button.dart';
import 'package:csv/csv.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

class TimeStuff {
  num hour;
  num minute;
  bool am;

  @override
  String toString() => "TimeStuff [$hour:$minute $am]";
}

@Component(
  selector: 'league-or-tournament-display',
  directives: const [
    routerDirectives,
    MaterialButtonComponent,
    NgIf,
    NgFor,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'home.html',
  styleUrls: const [],
)
class HomeComponent implements OnInit, OnDestroy, OnChanges {
  Stream<Team> team;
  String _curLeagueUid = '-LMdBLCjTPrwNFee4acy';
  String _curLeagueSeasonUid = '-LMdkTIOgXWlFIEMq51n';
  LeagueOrTournamentDivisonSubscription _subSeason;
  Iterable<LeagueOrTournamentDivison> _divisons;
  Map<String, LeagueOrTournmentTeamSubscription> _teamSubs = {};
  Map<String, List<LeagueOrTournamentTeam>> _teamsForDiv = {};
  Map<String, List<GameSharedData>> _gamesForDiv = {};
  Map<String, LeagueOrTournamentDivison> _divisonNameToUid = {};
  Map<String, LeagueOrTournamentTeam> _divisonTeamNameToUid = {};
  @ViewChild('mapArea')
  ElementRef mapAreaRef;
  Map<String, PlaceResult> placesResults = {};

  Set<String> newDivisionsToGenerate;
  Set<String> newTeamsToGenerate;
  List<GameToGenerate> newGames;
  int currentlyProcessing = 0;

  String travellingLeague =
      '''Date,Start Time,End Time,Away Team,Home Team,Event Type,Location,Division
12/2/17,2:00 PM,3:00 PM,Woodinville 4th,Cedar Park Christian 4th,Game,Cedar Park Christian School Aux Gym,4th Grade
12/2/17,3:15 PM,4:00 PM,Woodinville 5th,Cedar Park Christian 5th,Game,Cedar Park Christian School Aux Gym,5th Grade
12/2/17,11:30 AM,12:30 PM,Woodinville 6th,Cedar Park Christian 6th,Game,Cedar Park Christian School Aux Gym,6th Grade
12/2/17,12:45 PM,1:45 PM,Woodinville 8th,Cedar Park Christian 8th,Game,Cedar Park Christian School Aux Gym,8th Grade
12/2/17,1:30 PM,2:30 PM,Tahoma 4th,Newport 4th,Game,Newport High School Aux Gym,4th Grade
12/2/17,2:45 PM,3:45 PM,Tahoma 5th,Newport 5th,Game,Newport High School Aux Gym,5th Grade
12/2/17,3:30 PM,4:30 PM,Tahoma 6th,Newport 6th,Game,Newport High School Main Gym,6th Grade
12/2/17,4:45 PM,5:45 PM,Tahoma 8th,Newport 8th,Game,Newport High School Main Gym,8th Grade
12/2/17,2:00 PM,3:00 PM,Puyallup 4th,Bellevue 4th,Game,Bellevue High School Aux Gym,4th Grade
12/2/17,3:15 PM,4:15 PM,Puyallup 5th,Bellevue 5th,Game,Bellevue High School Aux Gym,5th Grade
12/2/17,2:00 PM,3:00 PM,Puyallup 6th,Bellevue 6th,Game,Bellevue High School Main Gym,6th Grade
12/2/17,3:15 PM,4:15 PM,Puyallup 7th,Bellevue 7th,Game,Bellevue High School Main Gym,7th Grade
12/2/17,1:00 PM,2:00 PM,Skyline 4th,Mt. Si 4th,Game,Mt. Si High School,4th Grade
12/2/17,2:15 PM,3:15 PM,Skyline 5th,Mt. Si 5th,Game,Mt. Si High School,5th Grade
12/2/17,3:30 PM,4:30 PM,Skyline 6th,Mt. Si 6th,Game,Mt. Si High School,6th Grade
12/2/17,4:45 PM,5:45 PM,Skyline 7th,Mt. Si 7th,Game,Mt. Si High School,7th Grade
12/2/17,6:00 PM,7:00 PM,Skyline 8th,Mt. Si 8th,Game,Mt. Si High School,8th Grade
12/2/17,2:30 PM,3:30 PM,Mercer Island 5th,Juanita 5th,Game,Juanita High School,5th Grade
12/2/17,3:45 PM,4:45 PM,Mercer Island 6th,Juanita 6th,Game,Juanita High School,6th Grade
12/2/17,5:00 PM,6:00 PM,Mercer Island 7th,Juanita 7th,Game,Juanita High School,7th Grade
12/2/17,6:15 PM,7:15 PM,Mercer Island 8th,Juanita 8th,Game,Juanita High School,8th Grade
12/2/17,3:30 PM,4:30 PM,Hazen 4th,Inglemoor 4th,Game,Inglemoor High School,4th Grade
12/2/17,4:45 PM,5:45 PM,Hazen 5th,Inglemoor 5th,Game,Inglemoor High School,5th Grade
12/2/17,6:00 PM,7:00 PM,Hazen 6th,Inglemoor 6th,Game,Inglemoor High School,6th Grade
12/2/17,7:15 PM,8:15 PM,Hazen 7th,Inglemoor 7th,Game,Inglemoor High School,7th Grade
12/2/17,6:45 PM,7:45 PM,Liberty 5th,North Creek 5th,Game,North Creek High School Main Gym,5th Grade
12/2/17,5:30 PM,6:30 PM,Liberty 6th,North Creek 6th,Game,North Creek High School Main Gym,6th Grade
12/2/17,4:15 PM,5:15 PM,Liberty 7th,North Creek 7th,Game,North Creek High School Main Gym,7th Grade
12/2/17,3:00 PM,4:00 PM,Liberty 8th,North Creek 8th,Game,North Creek High School Main Gym,8th Grade
12/2/17,6:30 PM,7:30 PM,Issaquah 4th,Redmond 4th,Game,Redmond High School Main Gym,4th Grade
12/2/17,5:15 PM,6:15 PM,Issaquah 5th,Redmond 5th,Game,Redmond High School Main Gym,5th Grade
12/2/17,4:00 PM,5:00 PM,Issaquah 6th,Redmond 6th,Game,Redmond High School Main Gym,6th Grade
12/2/17,2:45 PM,3:45 PM,Issaquah 7th,Redmond 7th,Game,Redmond High School Main Gym,7th Grade
12/2/17,1:30 PM,2:30 PM,Issaquah 8th,Redmond 8th,Game,Redmond High School Main Gym,8th Grade
12/2/17,7:15 PM,8:15 PM,Lake Washington 4th,Bothell 4th,Game,Bothell High School Aux Gym,4th Grade
12/2/17,6:00 PM,7:00 PM,Lake Washington 5th,Bothell 5th,Game,Bothell High School Aux Gym,5th Grade
12/2/17,4:45 PM,5:45 PM,Lake Washington 6th,Bothell 6th,Game,Bothell High School Main Gym,6th Grade
12/2/17,3:30 PM,4:30 PM,Lake Washington 7th,Bothell 7th,Game,Bothell High School Main Gym,7th Grade
12/03/17,2:00 PM,3:00 PM,Cedar Park Christian 4th,Bellevue 4th,Game,Bellevue High School Aux Gym,4th Grade
12/03/17,3:15 PM,4:15 PM,Cedar Park Christian 5th,Bellevue 5th,Game,Bellevue High School Aux Gym,5th Grade
12/03/17,2:00 PM,3:00 PM,Cedar Park Christian 6th,Bellevue 6th,Game,Bellevue High School Main Gym,6th Grade
12/03/17,3:15 PM,4:15 PM,Cedar Park Christian 7th,Bellevue 7th,Game,Bellevue High School Main Gym,7th Grade
12/03/17,4:30 PM,5:30 PM,Cedar Park Christian 8th,Bellevue 8th,Game,Bellevue High School Main Gym,8th Grade
12/03/17,10:00 AM,11:00 AM,Redmond 4th,Skyline 4th,Game,Skyline High School Main Gym,4th Grade
12/03/17,11:15 AM,12:15 PM,Redmond 5th,Skyline 5th,Game,Skyline High School Main Gym,5th Grade
12/03/17,12:30 PM,1:30 PM,Redmond 6th,Skyline 6th,Game,Skyline High School Main Gym,6th Grade
12/03/17,1:45 PM,2:45 PM,Redmond 7th,Skyline 7th,Game,Skyline High School Main Gym,7th Grade
12/03/17,3:00 PM,4:00 PM,Redmond 8th,Skyline 8th,Game,Skyline High School Main Gym,8th Grade
12/03/17,4:00 PM,5:00 PM,North Creek 5th,Puyallup 5th,Game,Puyallup High School,5th Grade
12/03/17,2:45 PM,3:45 PM,North Creek 6th,Puyallup 6th,Game,Puyallup High School,6th Grade
12/03/17,1:30 PM,2:30 PM,North Creek 7th,Puyallup 7th,Game,Puyallup High School,7th Grade
12/03/17,10:30 AM,11:30 AM,Inglemoor 4th,Eastlake 4th,Game,Eastlake High School Main Gym,4th Grade
12/03/17,11:45 AM,12:45 PM,Inglemoor 5th,Eastlake 5th,Game,Eastlake High School Main Gym,5th Grade
12/03/17,1:00 PM,2:00 PM,Inglemoor 6th,Eastlake 6th,Game,Eastlake High School Main Gym,6th Grade
12/03/17,2:15 PM,3:15 PM,Inglemoor 7th,Eastlake 7th,Game,Eastlake High School Main Gym,7th Grade
12/03/17,2:45 PM,3:45 PM,Eastlake 4th,Mt. Si 4th,Game,EBC Redmond,4th Grade
12/03/17,4:00 PM,5:00 PM,Eastlake 5th,Mt. Si 5th,Game,EBC Redmond,5th Grade
12/03/17,5:15 PM,6:15 PM,Eastlake 6th,Mt. Si 6th,Game,EBC Redmond,6th Grade
12/03/17,6:30 PM,7:30 PM,Eastlake 7th,Mt. Si 7th,Game,EBC Redmond,7th Grade
12/03/17,1:30 PM,2:30 PM,Eastlake 8th,Mt. Si 8th,Game,EBC Redmond,8th Grade
12/03/17,2:00 PM,3:00 PM,Newport 4th,Issaquah 4th,Game,Issaquah High School Main Gym,4th Grade
12/03/17,12:45 PM,1:45 PM,Newport 5th,Issaquah 5th,Game,Issaquah High School Main Gym,5th Grade
12/03/17,11:30 AM,12:30 PM,Newport 6th,Issaquah 6th,Game,Issaquah High School Main Gym,6th Grade
12/03/17,10:15 AM,11:15 AM,Newport 7th,Issaquah 7th,Game,Issaquah High School Main Gym,7th Grade
12/03/17,9:00 AM,10:00 AM,Newport 8th,Issaquah 8th,Game,Issaquah High School Main Gym,8th Grade
12/03/17,10:00 AM,11:00 AM,Woodinville 4th,Lake Washington 4th,Game,Lake Washington High School Aux Gym,4th Grade
12/03/17,11:15 AM,12:15 PM,Woodinville 5th,Lake Washington 5th,Game,Lake Washington High School Aux Gym,5th Grade
12/03/17,11:15 AM,12:15 PM,Woodinville 6th,Lake Washington 6th,Game,Lake Washington High School Main Gym,6th Grade
12/03/17,12:30 PM,1:30 PM,Woodinville 8th,Lake Washington 8th,Game,Lake Washington High School Main Gym,8th Grade
12/03/17,2:15 PM,3:15 PM,Bothell 5th,Mercer Island 5th,Game,Mercer Island High School,5th Grade
12/03/17,1:00 PM,2:00 PM,Bothell 6th,Mercer Island 6th,Game,Mercer Island High School,6th Grade
12/03/17,11:45 AM,12:45 PM,Bothell 7th,Mercer Island 7th,Game,Mercer Island High School,7th Grade
12/03/17,10:30 AM,11:30 AM,Tahoma 4th,Liberty 4th,Game,Liberty High School Aux Gym,4th Grade
12/03/17,9:00 AM,10:00 AM,Tahoma 5th,Liberty 5th,Game,Liberty High School Aux Gym,5th Grade
12/03/17,12:00 PM,1:00 PM,Tahoma 6th,Liberty 6th,Game,Liberty High School Main Gym,6th Grade
12/03/17,10:30 AM,11:30 AM,Tahoma 8th,Liberty 8th,Game,Liberty High School Main Gym,8th Grade
12/03/17,9:30 AM,10:30 AM,Juanita 4th,Hazen 4th,Game,Hazen Senior High School,4th Grade
12/03/17,10:45 AM,11:45 AM,Juanita 5th,Hazen 5th,Game,Hazen Senior High School,5th Grade
12/03/17,12:00 PM,1:00 PM,Juanita 6th,Hazen 6th,Game,Hazen Senior High School,6th Grade
12/03/17,1:15 PM,2:15 PM,Juanita 7th,Hazen 7th,Game,Hazen Senior High School,7th Grade
12/03/17,2:30 PM,3:30 PM,Juanita 8th,Hazen 8th,Game,Hazen Senior High School,8th Grade''';

  HomeComponent() {}

  @override
  Future<Null> ngOnInit() async {
    _subSeason = UserDatabaseData.instance.updateModel
        .getLeagueDivisonsForSeason(_curLeagueSeasonUid);
    _subSeason.subscriptions.add(
        _subSeason.stream.listen((Iterable<LeagueOrTournamentDivison> div) {
      _divisons = div;
      print(div);
      for (LeagueOrTournamentDivison myDiv in div) {
        _teamSubs[myDiv.uid] = UserDatabaseData.instance.updateModel
            .getLeagueDivisionTeams(myDiv.uid);
        _teamSubs[myDiv.uid].subscriptions.add(_teamSubs[myDiv.uid]
                .stream
                .listen((Iterable<LeagueOrTournamentTeam> teams) {
              print(teams);
              _teamsForDiv[myDiv.uid] = teams.toList();
            }));
        SharedGameSubscription fluff = UserDatabaseData.instance.updateModel
            .getLeagueGamesForDivison(myDiv.uid);
        fluff.stream.listen((Iterable<GameSharedData> games) {
          _gamesForDiv[myDiv.uid] = games.toList();
        });
      }
    }));
  }

  @override
  void ngOnDestroy() {
    _subSeason?.dispose();
    for (LeagueOrTournmentTeamSubscription teamSubscription
        in _teamSubs.values) {
      teamSubscription?.dispose();
    }
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    print('on team changed $changes');
  }

  static PlaceResult makePlaceResult(Map<String, dynamic> data) {
    PlaceResult tmp = new PlaceResult.created(new JsObject.jsify(data));
    tmp.geometry.location = new LatLng(
        data['geometry']['location']['lat'] as num,
        data['geometry']['location']['lng'] as num);
    return tmp;
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

  LeagueOrTournamentDivison findDivisonUid(String name) {
    for (LeagueOrTournamentDivison div in _divisons) {
      if (div.name.toLowerCase().trim() == name.toLowerCase().trim()) {
        _divisonNameToUid[name.toLowerCase().trim()] = div;
        return div;
      }
    }
    _divisonNameToUid[name.toLowerCase().trim()] = null;
    return null;
  }

  LeagueOrTournamentTeam findTeamUid(
      String name, LeagueOrTournamentDivison div) {
    if (_teamsForDiv.containsKey(div.uid)) {
      for (LeagueOrTournamentTeam t in _teamsForDiv[div.uid]) {
        if (t.name.toLowerCase().trim() == name.toLowerCase().trim()) {
          _divisonTeamNameToUid[div.uid + name.toLowerCase().trim()] = t;
          return t;
        }
      }
    }
    _divisonTeamNameToUid[div.uid + name.toLowerCase().trim()] = null;
    return null;
  }

  void onGenerate() async {
    tz.Location loc = tz.getLocation("America/Los_Angeles");
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter(eol: '\n').convert(travellingLeague);
    GMap map = new GMap(
        mapAreaRef.nativeElement,
        new MapOptions()
          ..center = new LatLng(47.4979, 19.0402)
          ..zoom = 15);
    PlacesService placesService = new PlacesService(map);
    List<GameToGenerate> games = [];
    Set<String> newTeams = Set<String>();
    Set<String> newDivisons = Set<String>();
    // Start from 1.  First row is a header.
    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      currentlyProcessing = i;
      List<dynamic> d = rowsAsListOfValues[i];
      String startDate = d[0].trim();
      String startTime = d[1].trim();
      String endTime = d[2].trim();
      String awayTeam = d[3].trim();
      String homeTeam = d[4].trim();
      String eventType = d[5];
      String address = d[6].trim();
      String placeName = address;
      String divison = d[7].trim();

      print(d);

      List<int> bits =
          startDate.split("/").map((String s) => int.parse(s)).toList();

      TimeStuff stuff = getTime(startTime);
      tz.TZDateTime startTZTime = new tz.TZDateTime(loc, bits[2], bits[0],
          bits[1], stuff.hour.toInt(), stuff.minute.toInt());

      tz.TZDateTime endTZTime;
      if (endTime.length > 1) {
        TimeStuff endStuff = getTime(endTime);
        endTZTime = new tz.TZDateTime(loc, bits[2], bits[0], bits[1],
            endStuff.hour.toInt(), endStuff.minute.toInt());
      } else {
        endTZTime = startTZTime;
      }

      // Lookup the divison and teams.
      LeagueOrTournamentDivison div = findDivisonUid(divison);
      if (div == null) {
        newDivisons.add(divison.trim());
      }

      String homeTeamUid;
      String awayTeamUid;
      if (div != null) {
        LeagueOrTournamentTeam home = findTeamUid(homeTeam, div);
        if (home == null) {
          newTeams.add(divison + " --- " + homeTeam.trim());
        }
        homeTeamUid = home?.uid;
        LeagueOrTournamentTeam away = findTeamUid(awayTeam, div);
        if (away == null) {
          newTeams.add(divison + " --- " + awayTeam.trim());
        }
        awayTeamUid = away?.uid;
      } else {
        newTeams.add(divison + " --- " + homeTeam.trim());

        newTeams.add(divison + " --- " + awayTeam.trim());
      }

      // Lookup the places
      PlaceResult place;
      if (address.length > 5) {
        // Address to lookup
        String addressToLookup = address;
        if (addressToLookup.toLowerCase().endsWith(" aux gym")) {
          addressToLookup =
              addressToLookup.substring(0, addressToLookup.length - 8).trim();
        }
        if (addressToLookup.toLowerCase().endsWith(" main gym")) {
          addressToLookup =
              addressToLookup.substring(0, addressToLookup.length - 9).trim();
        }
        if (placesResults.containsKey(addressToLookup.toLowerCase())) {
          place = placesResults[addressToLookup.toLowerCase()];
          address = place.formattedAddress;
        } else {
          Completer<List<PlaceResult>> completeResults =
              new Completer<List<PlaceResult>>();
          TextSearchRequest req = new TextSearchRequest();
          req.query = addressToLookup;

          placesService.textSearch(req, (List<PlaceResult> results,
              PlacesServiceStatus status, PlaceSearchPagination pag) {
            print("In here $results $status $pag");
            completeResults.complete(results);
          });
          List<PlaceResult> results = await completeResults.future;
          print("Results $results");
          if (results != null && results.length > 0) {
            placesResults[addressToLookup.toLowerCase()] = results[0];
            place = results[0];
          }
          if (place != null) {
            address = place.formattedAddress;
          }
        }
      }

      games.add(GameToGenerate(
          start: startTZTime,
          end: endTZTime,
          eventType: EventType.Game,
          homeTeamName: homeTeam,
          homeTeamUid: homeTeamUid,
          awayTeamName: awayTeam,
          awayTeamUid: awayTeamUid,
          where: place,
          address: address,
          divison: div,
          divisonName: divison,
          placeName: placeName));
    }
    newTeamsToGenerate = newTeams;
    newDivisionsToGenerate = newDivisons;
    newGames = games;
    print(newTeamsToGenerate);
    print(newDivisionsToGenerate);
    print(newGames);

    // Make stuff.  Yay!
    for (String divison in newDivisionsToGenerate) {
      currentlyProcessing++;
      LeagueOrTournamentDivison div =
          new LeagueOrTournamentDivison(null, divison, _curLeagueSeasonUid);
      await div.updateFirestore();
      _teamsForDiv[div.uid] = [];
      print('Created $div');
    }

    // Make the teams in the divison too.
    for (String team in newTeamsToGenerate) {
      currentlyProcessing++;
      List<String> bits = team.split(" --- ");
      LeagueOrTournamentDivison div =
          _divisonNameToUid[bits[0].toLowerCase().trim()];

      LeagueOrTournamentTeam teamData = new LeagueOrTournamentTeam(
          leagueOrTournamentDivisonUid: div.uid, name: bits[1]);
      await teamData.firebaseUpdate();
      print('Created $teamData');
      _teamsForDiv[div.uid].add(teamData);
    }

    // Now the games.
    for (GameToGenerate gen in newGames) {
      currentlyProcessing++;
      LeagueOrTournamentDivison divison =
          _divisonNameToUid[gen.divisonName.toLowerCase()];
      LeagueOrTournamentTeam awayTeamUid =
          findTeamUid(gen.awayTeamName, divison);
      LeagueOrTournamentTeam homeTeamUid =
          findTeamUid(gen.homeTeamName, divison);
      // See if we can find the game, if we already have it.
      bool found = false;
      for (GameSharedData g in _gamesForDiv[divison.uid]) {
        if (g.time == gen.start.millisecondsSinceEpoch) {
          print('Time match ${g.officalResults.homeTeamLeagueUid} ${g.officalResults.awayTeamLeagueUid}');
          if (g.officalResults.homeTeamLeagueUid == homeTeamUid &&
              g.officalResults.awayTeamLeagueUid == awayTeamUid) {
            // Found it, update the data and save this instead.
            g.timezone = "America/Los_Angeles";
            g.officalResults.awayTeamLeagueUid = awayTeamUid.uid;
            g.officalResults.homeTeamLeagueUid= homeTeamUid.uid;
            await g.updateFirestore();
            found = true;
          }
        }
      }
      if (!found) {
        GamePlace place = GamePlace(name: gen.placeName, address: gen.address);
        if (gen.where != null) {
          place.placeId = gen.where.placeId;
          place.name = gen.where.name;
          place.longitude = gen.where.geometry.location.lng;
          place.latitude = gen.where.geometry.location.lat;
        }
        GameOfficialResults results =
        GameOfficialResults(homeTeamUid.uid, awayTeamUid.uid);
        GameSharedData newGame = new GameSharedData(
            homeTeamUid.uid, awayTeamUid.uid,
            officalResults: results,
            time: gen.start.millisecondsSinceEpoch,
            endTime: gen.end.millisecondsSinceEpoch,
            timezone: "America/Los_Angeles",
            leagueUid: _curLeagueUid,
            leagueDivisionUid: divison.uid,
            place: place,
            type: EventType.Game);
        await newGame.updateFirestore();
      }
    }
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    /*
    _curTeamId = current.parameters['id'];
    if (_curTeamId == null) {
      _curTeamId = current.queryParameters['id'];
    }
    print('$_curTeamId -- ${UserDatabaseData.instance.teams[_curTeamId]}');
    if (_curTeamId != null) {
      _controller.add(UserDatabaseData.instance.teams[_curTeamId]);
    }
    */
  }

  String mercerIslandHighSchool = '''
  {
         "formatted_address" : "9100 SE 42nd St, Mercer Island, WA 98040, USA",
         "geometry" : {
            "location" : {
               "lat" : 47.5719538,
               "lng" : -122.2181026
            },
            "viewport" : {
               "northeast" : {
                  "lat" : 47.57352667989272,
                  "lng" : -122.2170865201073
               },
               "southwest" : {
                  "lat" : 47.57082702010728,
                  "lng" : -122.2197861798927
               }
            }
         },
         "icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/school-71.png",
         "id" : "403bdbd24b2a6498e887f3a6d87e17522c84dbef",
         "name" : "Mercer Island High School",
         "photos" : [
            {
               "height" : 3036,
               "html_attributions" : [
                  "\u003ca href=\"https://maps.google.com/maps/contrib/110560881475848185014/photos\"\u003eEvan Liang\u003c/a\u003e"
               ],
               "photo_reference" : "CmRaAAAA8as3juhKOmxovl-KuCQxbM2Stpoe3s2dEiiIV1AAeXX7Gkv89Hiw1A4hwEEmBPvK0_Z2F1c-evrP7SCig-GaV3u2NxsT9QpT1fcPkguORYomfv6Oz1QL5iJTIgu5nDXlEhCaFiPi1y_3AzF_So-U3EM9GhQmAFIssEjRsOW8yqWxP3lRd35Syg",
               "raw_reference" : {
                  "fife_url" : "https://lh3.googleusercontent.com/p/AF1QipOxaSvQnn1mlrPS-F4ywOBPPznrXbi211IZ7KaU=k"
               },
               "width" : 4048
            }
         ],
         "place_id" : "ChIJnRqW59prkFQR6z9ST_PK5gY",
         "plus_code" : {
            "compound_code" : "HQCJ+QQ Mercer Island, Washington",
            "global_code" : "84VVHQCJ+QQ"
         },
         "rating" : 4,
         "reference" : "ChIJnRqW59prkFQR6z9ST_PK5gY",
         "types" : [ "school", "point_of_interest", "establishment" ]
      }''';
}

class GameToGenerate {
  GameToGenerate(
      {this.start,
      this.end,
      this.eventType,
      this.homeTeamName,
      this.homeTeamUid,
      this.awayTeamName,
      this.awayTeamUid,
      this.where,
      this.address,
      this.divison,
      this.divisonName,
      this.placeName});
  final tz.TZDateTime start;
  final tz.TZDateTime end;
  final EventType eventType;
  final String homeTeamName;
  final String homeTeamUid;
  final String awayTeamName;
  final String awayTeamUid;
  final PlaceResult where;
  final String address;
  final LeagueOrTournamentDivison divison;
  final String divisonName;
  final String placeName;

  @override
  String toString() {
    return 'GameToGenerate{start: $start, end: $end, eventType: $eventType, homeTeamName: $homeTeamName, homeTeamUid: $homeTeamUid, awayTeamName: $awayTeamName, awayTeamUid: $awayTeamUid, where: $where, placeName: $placeName, address: $address, divison: $divison, divisonName: $divisonName}';
  }
}
