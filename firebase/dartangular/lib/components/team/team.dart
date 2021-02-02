import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';

import 'teamdetails.dart';

@Component(
  selector: 'team-display',
  directives: const [
    routerDirectives,
    NgIf,
    TeamDetailsComponent,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'team.html',
  styleUrls: const [],
)
class TeamComponent implements OnInit, OnActivate, OnDestroy, AfterChanges {
  Stream<Team> team;
  String _curTeamId;
  final StreamController<Team> _controller = new StreamController<Team>();
  StreamSubscription<Team> _sub;
  DatabaseUpdateModel _db;

  TeamComponent(this._db) {
    team = _controller.stream.asBroadcastStream();
  }

  @override
  Future<Null> ngOnInit() async {
    if (_curTeamId != null) {
      _sub = _db.getTeamDetails(teamUid: _curTeamId).listen((event) {
        _controller.add(event);
      });
    }
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    _curTeamId = current.parameters['id'];
    if (_curTeamId == null) {
      _curTeamId = current.queryParameters['id'];
    }
    if (_curTeamId != null) {
      if (_curTeamId != null) {
        _sub?.cancel();
        _sub = _db.getTeamDetails(teamUid: _curTeamId).listen((event) {
          _controller.add(event);
        });
      }
    }
  }

  @override
  void ngAfterChanges() {
    print('on team changed ');
  }
}
