import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:fusemodel/fusemodel.dart';

@Component(
  selector: 'player-attendence',
  directives: const [
    MaterialButtonComponent,
    MaterialIconComponent,
    NgIf,
  ],
  templateUrl: 'attendence.html',
  styleUrls: const [
    'game-display-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class AttendenceComponent {
  @Input()
  SeasonPlayer player;
  @Input()
  Game game;

  AttendenceComponent();

  String playerName() {
    return UserDatabaseData.instance.players[player.playerUid].name;
  }

  String iconFromAttendance() {
    Attendance attendance = Attendance.Maybe;
    if (game.attendance.containsKey(player.playerUid)) {
      attendance = game.attendance[player.playerUid];
    }
    switch (attendance) {
      case Attendance.Maybe:
        return "help_outline";
      case Attendance.No:
        return "close";
      case Attendance.Yes:
        return "check";
    }
    return "help_outline";
  }

  String iconFromAttendanceColor() {
    Attendance attendance = Attendance.Maybe;
    if (game.attendance.containsKey(player.playerUid)) {
      attendance = game.attendance[player.playerUid];
    }
    switch (attendance) {
      case Attendance.Maybe:
        return "";
      case Attendance.No:
        return "red";
      case Attendance.Yes:
        return "green";
    }
    return "";
  }

  String get attendclass {
    Attendance attendance = Attendance.Maybe;
    if (game.attendance.containsKey(player.playerUid)) {
      attendance = game.attendance[player.playerUid];
    }
    switch (attendance) {
      case Attendance.Maybe:
        return "attendmaybe";
      case Attendance.No:
        return "attendno";
      case Attendance.Yes:
        return "attendyes";
    }
    return "attendmaybe";
  }

  void openAttendence() {}
}
