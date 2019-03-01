import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'dart:async';
import 'package:teamfuse/components/games/gamesharedcard-component.dart';
import 'package:angular_components/material_tab/material_tab_panel.dart';
import 'package:angular_components/material_tab/material_tab.dart';
import 'package:angular_components/material_tab/tab_change_event.dart';
import 'package:angular_components/content/deferred_content.dart';
import '../common/league-team-card-component.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'divison-expansionpanel',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    MaterialTabComponent,
    MaterialTabPanelComponent,
    GameSharedCardComponent,
    LeagueTeamCardComponent,
    DeferredContentDirective,
  ],
  templateUrl: 'divisonexpansionpanel.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    '../../../util/grid.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class DivisonExpansionPanelComponent implements OnDestroy, OnInit {
  @Input()
  LeagueOrTournament league;
  @Input()
  LeagueOrTournamentSeason season;
  @Input()
  LeagueOrTournamentDivison divison;

  bool expanded;

  List<GameDouble<GameSharedData>> games;
  StreamSubscription<Iterable<GameSharedData>> _subscription;
  StreamController<Iterable<GameDouble<GameSharedData>>> _gameController;
  Stream<Iterable<GameDouble<GameSharedData>>> gameStream;
  int tabIndex = 0;

  List<LeagueOrTournamentTeam> teams;
  StreamSubscription<Iterable<LeagueOrTournamentTeam>> _teamSubscription;
  StreamController<Iterable<LeagueOrTournamentTeam>> _teamController;
  Stream<Iterable<LeagueOrTournamentTeam>> teamsStream;

  final Router _router;
  final Location _location;

  DivisonExpansionPanelComponent(this._router, this._location);

  @override
  void ngOnInit() {
    print('Making panel ${divison.uid} ${_router.current.queryParameters}');

    // Games
    _gameController = new StreamController();
    gameStream = _gameController.stream.asBroadcastStream();
    _updateGames(divison.cachedGames?.toList() ?? []);
    _subscription =
        divison.gameStream.listen((Iterable<GameSharedData> allGames) {
      _updateGames(allGames);
    });

    // Teams
    _teamController = new StreamController();
    teamsStream = _teamController.stream.asBroadcastStream();
    _updateTeams(divison.cachedTeams?.toList() ?? []);
    _teamSubscription =
        divison.teamStream.listen((Iterable<LeagueOrTournamentTeam> allTeams) {
      _updateTeams(allTeams);
    });

    expanded = _router.current.queryParameters['divison'] == divison.uid;
    tabIndex = int.tryParse(_router.current.queryParameters['t']) ?? 0;
    print('Making panel $expanded ${_router.current.queryParameters}');
  }

  void _updateGames(Iterable<GameSharedData> newGames) {
    List<GameSharedData> stuff = newGames.toList();
    stuff.sort(
        (GameSharedData g1, GameSharedData g2) => (g1.time - g2.time).toInt());

    List<GameDouble<GameSharedData>> doubles = [];
    for (int i = 0; i < stuff.length; i += 2) {
      doubles.add(GameDouble<GameSharedData>(
          stuff[i], i + 1 < stuff.length ? stuff[i + 1] : null));
    }
    games = doubles;
    _gameController.add(doubles);
  }

  void _updateTeams(Iterable<LeagueOrTournamentTeam> newTeams) {
    teams = newTeams.toList();
    teams.sort((LeagueOrTournamentTeam t1, LeagueOrTournamentTeam t2) {
      WinRecord record1 =
          t1.record[t1.leagueOrTournamentDivisonUid] ?? WinRecord();
      WinRecord record2 =
          t2.record[t2.leagueOrTournamentDivisonUid] ?? WinRecord();
      if (record1.win != record2.win) {
        return (record1.win - record2.win).toInt();
      }
      if (record1.loss != record2.loss) {
        return (record2.loss - record1.loss).toInt();
      }
      if (record1.tie != record2.tie) {
        return (record1.tie - record2.tie).toInt();
      }
      return t1.name.compareTo(t2.name);
    });
    _teamController.add(teams);
  }

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
    _subscription = null;
    _gameController?.close();
    _gameController = null;
    _teamController?.close();
    _teamController = null;
    _teamSubscription?.cancel();
    _teamSubscription = null;
  }

  void onTabChange(TabChangeEvent event) {
    tabIndex = event.newIndex;
    print('Updated index to $tabIndex');
    updateUrl();
  }

  void openPanel() {
    updateUrl();
    expanded = true;
  }

  void updateUrl() {
    List<String> bits = _location.path().split('?');
    _location.replaceState(
        bits[0], 'season=${season.uid}&divison=${divison.uid}&t=${tabIndex}');
  }


  void closePanel() {
    print('closePanel');
    List<String> bits = _location.path().split('?');
    expanded = false;
    _location.replaceState(bits[0], 'season=${season.uid}');
  }

  void tabChange(TabChangeEvent e) {
    tabIndex = e.newIndex;
    updateUrl();
  }

  List<String> get tabLabels => ["Games", "Teams"];

  Object trackByGame(int index, dynamic game) =>
      game is GameDouble<GameSharedData> ? game.item1.uid : "";

  Object trackByTeam(int index, dynamic team) =>
      team is LeagueOrTournamentTeam ? team.uid : "";
}

class GameDouble<T> {
  final T item1;
  final T item2;

  GameDouble(this.item1, this.item2);
}
