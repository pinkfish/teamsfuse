import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:teamfuse/components/team/teamdetails.dart';

@Component(
  selector: 'team-expansionpanel',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel,
    TeamDetailsComponent,
  ],
  templateUrl: 'teamexpansionpanel.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class TeamExpansionPanelComponent implements OnDestroy, OnInit {
  @Input()
  Club club;
  @Input()
  Team team;

  @override
  void ngOnInit() {
    print('Making panel');
  }

  String get secondLine {
    Season season = team.seasons[team.currentSeason];
    return "${season.name} Win: ${season.record.win} Loss: ${season.record.loss} Tie: ${season.record.tie}";
  }

  void ngOnDestroy() {}
}
