import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';
import 'league/leaguenameandresult.dart';
import 'package:google_maps/google_maps.dart';

@Component(
  selector: 'game-shared-card',
  directives: const [
    DeferredContentDirective,
    MaterialIconComponent,
    NgIf,
    NgSwitch,
    NgSwitchDefault,
    NgSwitchWhen,
    formDirectives,
    RouterLink,
    LeagueNameAndResult,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'gamesharedcard-component.html',
  styleUrls: const [
    'games-component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class GameSharedCardComponent {
  @Input()
  GameSharedData game;
  static DateFormat dateFormat = DateFormat.MEd();
  static DateFormat dateWithTimeFormat = new DateFormat(
      DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY);
      static DateFormat timeFormat = DateFormat.jm();
  static const String API_KEY = "AIzaSyCP22ZMhWoQuzH9qIEnxYL7C_XfjWjo6tI";
  static Uri GOOGLE_PLACE_SEARCH =
      Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json");
  final Router _router;

  GameSharedCardComponent(this._router);

  void openDetails() {
    _router.navigate("/a/gameshared/" + game.uid);
   }
}
