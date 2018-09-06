import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'clubdetails.dart';

@Component(
  selector: 'club-display',
  directives: const [
    routerDirectives,
    NgIf,
    ClubDetailsComponent,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'club.html',
  styleUrls: const [],
)
class ClubComponent implements OnInit, OnActivate, OnDestroy {
  Stream<Club> club;
  String _curClubId;
  final StreamController<Club> _controller = new StreamController<Club>();
  StreamSubscription<UpdateReason> _sub;

  TeamComponent() {
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
  void onActivate(RouterState previous, RouterState current) {
    _curClubId = current.parameters['id'];
    print('activate! ${current.parameters} ${current.queryParameters} $_curClubId');
    if (_curClubId == null) {
      _curClubId = current.queryParameters['id'];
    }
    print('$_curClubId -- ${UserDatabaseData.instance.clubs[_curClubId]}');
    if (_curClubId != null) {
      print('Adding club');
      _controller.add(UserDatabaseData.instance.clubs[_curClubId]);
    }
  }
}
