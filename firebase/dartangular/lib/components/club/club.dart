import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:teamfuse/services/asyncnotnull.dart';

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
class ClubComponent implements OnInit, OnActivate, OnDestroy, AfterChanges {
  Stream<Club> club;
  String _curClubId;
  final StreamController<Club> _controller = new StreamController<Club>();
  StreamSubscription<Club> _sub;
  DatabaseUpdateModel _db;

  ClubComponent(this._db) {
    club = _controller.stream.asBroadcastStream();
  }

  @override
  Future<Null> ngOnInit() async {
    print('club $club! $_curClubId');
    if (_curClubId != null && _sub == null) {
      _sub = _db.getClubData(clubUid: _curClubId).listen((Club data) {
        _controller.add(data);
      });
    }
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    _curClubId = current.parameters['id'];
    print('activate clubs');
    if (_curClubId == null) {
      _curClubId = current.queryParameters['id'];
    }
    if (_curClubId != null) {
      if (_curClubId != null && _sub == null) {
        _sub = _db.getClubData(clubUid: _curClubId).listen((Club data) {
          _controller.add(data);
        });
      }
    }
  }

  @override
  void ngAfterChanges() {
    print('on club changed ');
  }
}
