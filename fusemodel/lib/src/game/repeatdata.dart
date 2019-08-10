import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:timezone/timezone.dart';

part 'repeatdata.g.dart';

enum RepeatPeriod {
  // ignore: camel_case_types, constant_identifier_names
  None,
  // ignore: camel_case_types, constant_identifier_names
  Weekly,
  // ignore: camel_case_types, constant_identifier_names
  Monthly,
}

abstract class RepeatData implements Built<RepeatData, RepeatDataBuilder> {
  RepeatData._();

  factory RepeatData([updates(RepeatDataBuilder b)]) => _$RepeatData((b) => b
    ..period = RepeatPeriod.None
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
    List<TZDateTime> newDates = <TZDateTime>[];
    // Normalize to 0.
    TZDateTime startOfWeek = start.subtract(new Duration(days: start.weekday));
    if (period != RepeatPeriod.None) {
      if (repeatUntil || period == RepeatPeriod.Monthly) {
        print("Interval ${repeatInterval}");
        for (int i = 0; i < repeatInterval; i++) {
          if (period == RepeatPeriod.Monthly) {
            newDates.add(new TZDateTime(start.location, start.year,
                start.month + i, start.day, start.hour, start.minute));
          } else {
            TZDateTime newWeek = startOfWeek.add(new Duration(days: i * 7));
            for (int dayNum = 0; dayNum < dayRepeats.length; dayNum++) {
              if (dayRepeats[dayNum]) {
                newDates.add(newWeek.add(new Duration(days: dayNum)));
              }
            }
          }
        }
      } else {
        int i = 0;
        int curSpins = 0;
        TZDateTime end = new TZDateTime(
                start.location, endRepeat.year, endRepeat.month, endRepeat.day)
            .add(new Duration(days: 1));
        while (
            startOfWeek.millisecondsSinceEpoch < end.millisecondsSinceEpoch &&
                curSpins < 100) {
          TZDateTime newWeek = startOfWeek.add(new Duration(days: i * 7));
          for (int dayNum = 0; dayNum < dayRepeats.length; dayNum++) {
            if (dayRepeats[dayNum]) {
              TZDateTime newTime = newWeek.add(new Duration(days: dayNum));
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
}
