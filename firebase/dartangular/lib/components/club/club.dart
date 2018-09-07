import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:teamfuse/services/asyncnotnull.dart';
import 'dart:async';
import 'clubdetails.dart';

@Component(
  selector: 'club-display',
  directives: const [
    routerDirectives,
    NgIf,
    ClubDetailsComponent,
    AsyncNotNullDirective,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'club.html',
  styleUrls: const [],
)
class ClubComponent implements OnInit, OnActivate, OnDestroy, OnChanges {
  Stream<Club> club;
  String _curClubId;
  final StreamController<Club> _controller = new StreamController<Club>();
  StreamSubscription<UpdateReason> _sub;

  ClubComponent() {
    club = _controller.stream.asBroadcastStream();
  }

  Future<Null> ngOnInit() async {
    print('club $club! $_curClubId');
    _sub = UserDatabaseData.instance.clubStream.listen((UpdateReason reason) {
      if (UserDatabaseData.instance.clubs.containsKey(_curClubId)) {
        _controller.add(UserDatabaseData.instance.clubs[_curClubId]);
      }
    });
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    print('on club changed $changes');
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    _curClubId = current.parameters['id'];
    print('activate clubs');
    if (_curClubId == null) {
      _curClubId = current.queryParameters['id'];
    }
    if (_curClubId != null) {
      print('Adding club ${UserDatabaseData.instance.clubs[_curClubId]}');
      _controller.add(UserDatabaseData.instance.clubs[_curClubId]);
    }
  }
}
