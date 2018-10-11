import 'package:angular/angular.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'dart:async';
import 'gamecard-component.dart';

@Component(
  selector: 'games-list',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    GameCardComponent,
    NgFor,
    NgIf
  ],
  templateUrl: 'games-component.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'games-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class GamesComponent implements OnInit, OnDestroy {
  static DateFormat dateFormat = DateFormat.MMMMEEEEd();
  static DateFormat timeFormat = DateFormat.jm();
  FilterDetails _details = new FilterDetails();
  MonthDetails curMonth;
  MonthDetails _nextMonth;
  MonthDetails _prevMonth;
  bool loading = true;
  Iterable<Game> games;
  StreamController<Iterable<Game>> _gameController =
      new StreamController<Iterable<Game>>();
  StreamSubscription<Iterable<Game>> _gameSub;

  String get currentMonth => dateFormat.format(curMonth.start);

  MonthDetails get currentMonthDetails => curMonth;

  int numTeams;

  @override
  void ngOnInit() {
    numTeams = UserDatabaseData.instance.teams.length;
    TZDateTime tmp = new TZDateTime.now(local);
    TZDateTime currentMonth = new TZDateTime(local, tmp.year, tmp.month, 1);
    TZDateTime nextMonth = _getNextMonth(currentMonth);
    TZDateTime prevMonth = _getPrevMonth(currentMonth);
    TZDateTime nextNextMonth = _getNextMonth(nextMonth);

    curMonth = new MonthDetails(
        start: currentMonth, end: nextMonth, details: _details);
    _nextMonth = new MonthDetails(
        start: nextMonth, end: nextNextMonth, details: _details);
    _prevMonth = new MonthDetails(
        start: prevMonth, end: currentMonth, details: _details);
    _gameSub = _gameController.stream
        .asBroadcastStream()
        .listen((Iterable<Game> data) {
      games = data;
      loading = !curMonth.cachedLoaded;
    });
    curMonth.setController(_gameController);
    updateLoading();

    UserDatabaseData.instance.teamStream
        .listen((UpdateReason reason) => setupListeners());
  }

  void setupListeners() {
    // only do stuff in here if the team size changes.
    if (numTeams == UserDatabaseData.instance.teams.length &&
        UserDatabaseData.instance.loadedDatabase) {
      return;
    }
    MonthDetails old = curMonth;
    curMonth = new MonthDetails(
        start: curMonth.start, end: curMonth.end, details: _details);
    old.dispose();
    old = _nextMonth;
    _nextMonth = new MonthDetails(
        start: _nextMonth.start, end: _nextMonth.end, details: _details);
    old.dispose();
    old = _prevMonth;
    _prevMonth = new MonthDetails(
        start: _prevMonth.start, end: _prevMonth.end, details: _details);
    old.dispose();
    updateLoading();
  }

  TZDateTime _getNextMonth(TZDateTime time) {
    int month = time.month + 1;
    if (month > 12) {
      return new TZDateTime(time.location, time.year + 1, 1, 1);
    }
    return new TZDateTime(time.location, time.year, month);
  }

  TZDateTime _getPrevMonth(TZDateTime time) {
    int month = time.month - 1;
    if (month < 1) {
      return new TZDateTime(time.location, time.year - 1, 12, 1);
    }
    return new TZDateTime(time.location, time.year, month);
  }

  Object trackByGames(int index, dynamic game) => game is Game ? game.uid : "";

  @override
  void ngOnDestroy() {
    curMonth?.dispose();
    _nextMonth?.dispose();
    _prevMonth?.dispose();
    _gameController.close();
    _gameSub?.cancel();
    _gameSub = null;
  }

  void updateLoading() {
    loading = !curMonth.cachedLoaded;
  }

  void nextMonth() {
    _prevMonth?.dispose();
    _prevMonth = curMonth;
    curMonth.setController(null);
    curMonth = _nextMonth;
    curMonth.setController(_gameController);
    TZDateTime next = _getNextMonth(curMonth.end);
    _nextMonth =
        new MonthDetails(start: curMonth.end, end: next, details: _details);
    updateLoading();
  }

  void prevMonth() {
    _nextMonth?.dispose();
    _nextMonth = curMonth;
    curMonth.setController(null);
    curMonth = _prevMonth;
    curMonth.setController(_gameController);
    TZDateTime next = _getPrevMonth(curMonth.start);
    _prevMonth =
        new MonthDetails(start: next, end: curMonth.start, details: _details);
    updateLoading();
  }
}

class MonthDetails {
  final GameSubscription _curMonthSubscription;
  final TZDateTime start;
  final TZDateTime end;
  StreamSubscription<Iterable<Game>> _curMonthListen;
  Iterable<Game> _games = [];
  StreamController<Iterable<Game>> _controller;
  bool cachedLoaded = false;

  MonthDetails({this.start, this.end, FilterDetails details})
      : _curMonthSubscription =
            UserDatabaseData.instance.getGames(details, start, end) {
    cachedLoaded = _curMonthSubscription.loaded;
    _games = _curMonthSubscription.initialData;
    _curMonthListen =
        _curMonthSubscription.stream.listen((Iterable<Game> games) {
      _games = games.toList();
      _controller?.add(_games);
      cachedLoaded = true;
    });
  }

  void setController(StreamController<Iterable<Game>> controller) {
    cachedLoaded = _curMonthSubscription.loaded;
    _controller = controller;
    if (_controller != null) {
      _controller.add(_games);
    }
  }

  Iterable<Game> get games => _games;

  void dispose() {
    _curMonthSubscription?.dispose();
    _curMonthListen?.cancel();
    _curMonthListen = null;
  }
}
