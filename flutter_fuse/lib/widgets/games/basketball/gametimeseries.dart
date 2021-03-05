import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/localutilities.dart';
import '../../../services/messages.dart';
import '../../chart/durationtimeaxisspec.dart';
import '../../chart/stuff/durationserieschart.dart';
import '../../util/loading.dart';
import 'gameeventlist.dart';

///
/// Shows a nice graph of information about the game as a timeseries.
///
class GameTimeseries extends StatefulWidget {
  final SingleGameState state;

  GameTimeseries({@required this.state});

  @override
  State<StatefulWidget> createState() {
    return _GameTimeseriesData();
  }
}

enum _GameTimeseriesType {
  All,
  Points,
  Fouls,
  Turnovers,
  Steals,
  Blocks,
  Assists,
}

class _GameTimeseriesData extends State<GameTimeseries> {
  _GameTimeseriesType type;
  bool _showTimeSeries = false;

  charts.Series<_CumulativeScore, Duration> _getEventSeries(
      GameEventType eventType, Color color, bool opponent,
      {bool assist = false}) {
    var total = 0;
    var first = false;
    return charts.Series<_CumulativeScore, Duration>(
      id: _nameOfSeries(eventType, opponent),
      colorFn: (_, __) =>
          charts.Color(r: color.red, g: color.green, b: color.blue),
      domainFn: (_CumulativeScore e, _) =>
          Duration(milliseconds: e.timestamp.inMilliseconds),
      measureFn: (_CumulativeScore e, _) => e.score,
      data: widget.state.gameEvents
          .where((e) =>
              (e.type == eventType &&
                  e.opponent == opponent &&
                  (!assist || e.assistPlayerUid != null)) ||
              first)
          .map((e) {
        if (first && e.type != eventType) {
          first = false;
          return _CumulativeScore(total, Duration(milliseconds: 0));
        }
        total++;
        return _CumulativeScore(total, e.eventTimeline);
      }).toList(),
    );
  }

  charts.Series<_CumulativeScore, Duration> _getPointSeries() {
    var total = 0;
    var first = false;
    return charts.Series<_CumulativeScore, Duration>(
      id: 'Score',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      domainFn: (_CumulativeScore e, _) =>
          Duration(milliseconds: e.timestamp.inMilliseconds),
      measureFn: (_CumulativeScore e, _) => e.score,
      data: widget.state.gameEvents
          .where((e) => e.type == GameEventType.Made && !e.opponent || first)
          .map((e) {
        if (first && e.type != GameEventType.Made) {
          first = false;
          return _CumulativeScore(total, Duration(milliseconds: 0));
        }
        total += e.points;
        return _CumulativeScore(total, e.eventTimeline);
      }).toList(),
    );
  }

  charts.Series<_CumulativeScore, Duration> _getOpponentPointSeries() {
    var total = 0;
    var first = false;

    return charts.Series<_CumulativeScore, Duration>(
      id: 'Opponent',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (_CumulativeScore e, _) => e.timestamp,
      measureFn: (_CumulativeScore e, _) => e.score,
      data: widget.state.gameEvents
          .where((e) => e.type == GameEventType.Made && e.opponent)
          .map((e) {
        if (first && e.type != GameEventType.Made) {
          first = false;
          return _CumulativeScore(total, e.eventTimeline);
        }

        total += e.points;
        return _CumulativeScore(total, e.eventTimeline);
      }).toList(),
    );
  }

  List<charts.Series<_CumulativeScore, Duration>> _getSeries() {
    switch (type) {
      case _GameTimeseriesType.All:
        return [
          _getPointSeries(),
          _getOpponentPointSeries(),
          _getEventSeries(GameEventType.Block, Colors.blue, false),
          _getEventSeries(GameEventType.Block, Colors.lightBlue, true),
          _getEventSeries(GameEventType.Steal, Colors.deepOrange, false),
          _getEventSeries(GameEventType.Steal, Colors.orange, true),
          _getEventSeries(GameEventType.Turnover, Colors.deepPurple, false),
          _getEventSeries(GameEventType.Turnover, Colors.purple, true),
          _getEventSeries(GameEventType.Foul, Colors.lime, false),
          _getEventSeries(GameEventType.Foul, Colors.limeAccent, true),
        ];
      case _GameTimeseriesType.Points:
        return [
          _getPointSeries(),
          _getOpponentPointSeries(),
        ];
      case _GameTimeseriesType.Fouls:
        return [
          _getEventSeries(GameEventType.Foul, Colors.lime, false),
          _getEventSeries(GameEventType.Foul, Colors.limeAccent, true),
        ];
      case _GameTimeseriesType.Turnovers:
        return [
          _getEventSeries(GameEventType.Turnover, Colors.deepPurple, false),
          _getEventSeries(GameEventType.Turnover, Colors.purple, true),
        ];
      case _GameTimeseriesType.Steals:
        return [
          _getEventSeries(GameEventType.Steal, Colors.deepOrange, false),
          _getEventSeries(GameEventType.Steal, Colors.orange, true),
        ];
      case _GameTimeseriesType.Blocks:
        return [
          _getEventSeries(GameEventType.Block, Colors.blue, false),
          _getEventSeries(GameEventType.Block, Colors.lightBlue, true),
        ];
      case _GameTimeseriesType.Assists:
        return [
          _getEventSeries(GameEventType.Made, Colors.lightGreenAccent, false,
              assist: true),
          _getEventSeries(GameEventType.Made, Colors.lightBlueAccent, true,
              assist: true),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.loadedEvents) {
      return Center(
        child: LoadingWidget(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DropdownButton<_GameTimeseriesType>(
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              value: type,
              onChanged: (_GameTimeseriesType t) => setState(() => type = t),
              items: [
                DropdownMenuItem(
                  value: _GameTimeseriesType.All,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).allEvents,
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: _GameTimeseriesType.Points,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).points,
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: _GameTimeseriesType.Blocks,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).blocks,
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: _GameTimeseriesType.Fouls,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).fouls,
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: _GameTimeseriesType.Turnovers,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).turnovers,
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: _GameTimeseriesType.Assists,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).assistTitle,
                      textScaleFactor: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 20, height: 0),
            Checkbox(
              value: _showTimeSeries,
              onChanged: (v) => setState(() => _showTimeSeries = v),
            ),
            Text('Show Events'),
          ],
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: _middleSectionWidget(),
          ),
        ),
      ],
    );
  }

  String _nameOfSeries(GameEventType type, bool opponent) {
    switch (type) {
      case GameEventType.Foul:
        return Messages.of(context).fouls + (opponent ? ' (op)' : '');
      case GameEventType.Turnover:
        return Messages.of(context).turnovers + (opponent ? ' (op)' : '');
      case GameEventType.Steal:
        return Messages.of(context).steals + (opponent ? ' (op)' : '');
      case GameEventType.Block:
        return Messages.of(context).blocks + (opponent ? ' (op)' : '');
      default:
        return Messages.of(context).unknown + (opponent ? ' (op)' : '');
    }
  }

  Widget _middleSectionWidget() {
    if (_showTimeSeries) {
      return GameEventList(
        eventCheck: (e) => true,
        showName: true,
      );
    }
    var periods =
        widget.state.gameEvents.where((e) => e.type == GameEventType.PeriodEnd);
    var behaviours = <charts.ChartBehavior<dynamic>>[
      charts.SlidingViewport(),
      charts.PanAndZoomBehavior(),
      charts.LinePointHighlighter(),
      charts.SeriesLegend(
        desiredMaxColumns: 3,
        desiredMaxRows: 3,
      ),
    ];

    if (periods.isNotEmpty) {
      behaviours.add(charts.RangeAnnotation(periods
          .map(
            (p) => charts.LineAnnotationSegment(
              p.eventTimeline,
              charts.RangeAnnotationAxisType.domain,
              startLabel: Messages.of(context).getPeriodName(p.period),
            ),
          )
          .toList()));
    }

    return DurationSeriesChart(
      _getSeries(),
      animate: true,
      animationDuration: Duration(milliseconds: 500),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(),
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 18,
            color: LocalUtilities.isDark(context)
                ? charts.Color.white
                : charts.Color.black,
          ),
        ),
      ),
      domainAxis: DurationAxisSpec(
        tickFormatterSpec: AutoDurationTickFormatterSpec(),
        renderSpec: charts.SmallTickRendererSpec<Duration>(
          labelStyle: charts.TextStyleSpec(
            fontSize: 18,
            color: LocalUtilities.isDark(context)
                ? charts.Color.white
                : charts.Color.black,
          ),
        ),
      ),
      behaviors: behaviours,
      // behaviors: _getAnnotations(),
    );
  }

  @override
  void initState() {
    super.initState();
    type = _GameTimeseriesType.All;
  }
}

class _CumulativeScore {
  final int score;
  final Duration timestamp;

  _CumulativeScore(this.score, this.timestamp);
}
