import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:clock/clock.dart';
import 'package:timezone/timezone.dart';

import '../serializer.dart';

part 'repeatdata.g.dart';

///
/// The repeat period to use for the event.
///
class RepeatPeriod extends EnumClass {
  static Serializer<RepeatPeriod> get serializer => _$repeatPeriodSerializer;

  /// No repeat,
  static const RepeatPeriod None = _$None;

  /// Weekly repeat.
  static const RepeatPeriod Weekly = _$Weekly;

  /// Monthly repeat.
  static const RepeatPeriod Monthly = _$Monthly;

  const RepeatPeriod._(String name) : super(name);

  static BuiltSet<RepeatPeriod> get values => _$RepeatPeriodValues;

  static RepeatPeriod valueOf(String name) => _$RepeatPeriodValueOf(name);
}

///
/// Data associated with the repeat information.
///
abstract class RepeatData implements Built<RepeatData, RepeatDataBuilder> {
  RepeatData._();

  factory RepeatData([Function(RepeatDataBuilder b) updates]) =>
      _$RepeatData((b) => b
        ..period = RepeatPeriod.None
        ..endRepeat = clock.now()
        ..dayRepeats =
            ListBuilder([false, false, false, false, false, false, false])
        ..repeatUntil = false
        ..repeatInterval = 1);

  RepeatPeriod get period;
  num get repeatInterval;
  bool get repeatUntil;
  DateTime get endRepeat;
  BuiltList<bool> get dayRepeats;

  //// List of date times that are based around the start point
  //// given the current repeat stuff.
  List<TZDateTime> repeatTimes(final TZDateTime start) {
    var newDates = <TZDateTime>[];
    // Normalize to 0.
    var startOfWeek = start.subtract(Duration(days: start.weekday));
    if (period != RepeatPeriod.None) {
      if (repeatUntil || period == RepeatPeriod.Monthly) {
        print('Interval $repeatInterval');
        for (var i = 0; i < repeatInterval; i++) {
          if (period == RepeatPeriod.Monthly) {
            newDates.add(TZDateTime(start.location, start.year, start.month + i,
                start.day, start.hour, start.minute));
          } else {
            var newWeek = startOfWeek.add(Duration(days: i * 7));
            for (var dayNum = 0; dayNum < dayRepeats.length; dayNum++) {
              if (dayRepeats[dayNum]) {
                newDates.add(newWeek.add(Duration(days: dayNum)));
              }
            }
          }
        }
      } else {
        var i = 0;
        var curSpins = 0;
        var end = TZDateTime(
                start.location, endRepeat.year, endRepeat.month, endRepeat.day)
            .add(Duration(days: 1));
        while (
            startOfWeek.millisecondsSinceEpoch < end.millisecondsSinceEpoch &&
                curSpins < 100) {
          var newWeek = startOfWeek.add(Duration(days: i * 7));
          for (var dayNum = 0; dayNum < dayRepeats.length; dayNum++) {
            if (dayRepeats[dayNum]) {
              var newTime = newWeek.add(Duration(days: dayNum));
              if (newTime.millisecondsSinceEpoch < end.millisecondsSinceEpoch) {
                newDates.add(newTime);
              }
            }
            curSpins++;
          }
        }
      }
    } else {
      newDates.add(start);
    }
    return newDates;
  }

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(RepeatData.serializer, this);
  }

  static RepeatData fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(RepeatData.serializer, jsonData);
  }

  static Serializer<RepeatData> get serializer => _$repeatDataSerializer;
}
