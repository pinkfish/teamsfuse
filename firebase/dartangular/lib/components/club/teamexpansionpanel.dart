import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:fusemodel/fusemodel.dart';
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

  Stream<String> secondLine;

  StreamController<String> _controllers = StreamController<String>();

  DatabaseUpdateModel _db;

  TeamExpansionPanelComponent(this._db) {
    secondLine = _controllers.stream;
  }

  @override
  void ngOnInit() {
    print('Making panel');
_db.getSingleSeason(team.currentSeason).listen((s) {
  _controllers.add(
   "${s.name} Win: ${s.record.win} Loss: ${s.record.loss} Tie: ${s.record.tie}");
});
  }


  @override
  void ngOnDestroy() {}
}
