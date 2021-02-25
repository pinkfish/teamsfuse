import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'leaguedetails.dart';

@Component(
  selector: 'league-display',
  directives: const [
    routerDirectives,
    NgIf,
    LeagueDetailsComponent,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'league.html',
  styleUrls: const [],
)
class LeagueComponent implements OnInit, OnActivate, OnDestroy, OnChanges {
  Stream<LeagueOrTournament> league;
  String _curLegueId;
  final StreamController<LeagueOrTournament> _controller =
      new StreamController<LeagueOrTournament>();
  StreamSubscription<UpdateReason> _sub;

  LeagueComponent() {
    league = _controller.stream.asBroadcastStream();
  }

  @override
  Future<Null> ngOnInit() async {
    _sub = UserDatabaseData.instance.leagueOrTournamentStream
        .listen((UpdateReason reason) {
      if (UserDatabaseData.instance.leagueOrTournments
          .containsKey(_curLegueId)) {
        _controller
            .add(UserDatabaseData.instance.leagueOrTournments[_curLegueId]);
      }
    });
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    print('on team changed $changes');
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    _curLegueId = current.parameters['id'];
    if (_curLegueId == null) {
      _curLegueId = current.queryParameters['id'];
    }
    print(
        '$_curLegueId -- ${UserDatabaseData.instance.leagueOrTournments[_curLegueId]}');
    if (_curLegueId != null) {
      _controller
          .add(UserDatabaseData.instance.leagueOrTournments[_curLegueId]);
    }
  }
}
