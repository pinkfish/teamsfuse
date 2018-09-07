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
  static DateFormat dateFormat = new DateFormat(DateFormat.YEAR_MONTH);
  FilterDetails _details = new FilterDetails();
  MonthDetails _curMonth;
  MonthDetails _nextMonth;
  MonthDetails _prevMonth;
  Stream<Iterable<Game>> games;
  StreamController<Iterable<Game>> _gameController =
      new StreamController<Iterable<Game>>();

   String get currentMonth => dateFormat.format(_curMonth.start);

  MonthDetails get currentMonthDetails => _curMonth;

  @override
  void ngOnInit() {
    TZDateTime tmp = new TZDateTime.now(local);
    TZDateTime currentMonth = new TZDateTime(local, tmp.year, tmp.month, 1);
    TZDateTime nextMonth = _getNextMonth(currentMonth);
    TZDateTime prevMonth = _getPrevMonth(currentMonth);
    TZDateTime nextNextMonth = _getNextMonth(nextMonth);

    print('Init stuff');
    _curMonth = new MonthDetails(
        start: currentMonth, end: nextMonth, details: _details);
    _nextMonth = new MonthDetails(
        start: nextMonth, end: nextNextMonth, details: _details);
    _prevMonth = new MonthDetails(
        start: prevMonth, end: currentMonth, details: _details);
    games = _gameController.stream.asBroadcastStream();
    _curMonth.setController(_gameController);
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
    print('Destroy them my robots');
    _curMonth?.dispose();
    _nextMonth?.dispose();
    _prevMonth?.dispose();
    _gameController.close();
  }

  void nextMonth() {
    print('$_curMonth');
    _prevMonth?.dispose();
    _prevMonth = _curMonth;
    _curMonth = _nextMonth;
    TZDateTime next = _getNextMonth(_curMonth.end);
    _nextMonth =
        new MonthDetails(start: _curMonth.end, end: next, details: _details);
    _prevMonth.setController(null);
    _curMonth.setController(_gameController);
  }

  void prevMonth() {
    _nextMonth?.dispose();
    _nextMonth = _curMonth;
    _curMonth = _prevMonth;
    TZDateTime next = _getPrevMonth(_curMonth.start);
    _prevMonth =
        new MonthDetails(start: next, end: _curMonth.start, details: _details);
    _nextMonth.setController(null);
    _curMonth.setController(_gameController);
  }

  bool get loading => !UserDatabaseData.instance.loadedDatabase;
}

class MonthDetails {
  final GameSubscription _curMonthSubscription;
  final TZDateTime start;
  final TZDateTime end;
  StreamSubscription<Iterable<Game>> _curMonthListen;
  Iterable<Game> _games = [];
  StreamController<Iterable<Game>> _controller;

  MonthDetails({this.start, this.end, FilterDetails details})
      : _curMonthSubscription =
            UserDatabaseData.instance.getGames(details, start, end) {
    _games = _curMonthSubscription.initialData;
    _curMonthListen =
        _curMonthSubscription.stream.listen((Iterable<Game> games) {
      _games = games;
      _controller?.add(_games);
      print("Games updated");
    });
  }

  void setController(StreamController<Iterable<Game>> controller) {
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
