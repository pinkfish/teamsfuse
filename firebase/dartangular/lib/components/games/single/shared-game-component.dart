import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';

import 'shared-game-display.dart';

@Component(
  selector: 'shared-single-game',
  directives: const [
    routerDirectives,
    NgIf,
    SharedGameDisplayComponent,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'shared-game-component.html',
  styleUrls: const [],
)
class SharedSingleGameComponent implements OnInit, OnActivate, OnDestroy {
  GameSharedData game;
  String _curGameId;
  final StreamController<GameSharedData> _controller =
      new StreamController<GameSharedData>();
  DatabaseUpdateModel _db;

  SharedSingleGameComponent(this._db);

  StreamSubscription<GameSharedData> _sub;

  @override
  Future<Null> ngOnInit() async {}

  @override
  void ngOnDestroy() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    _curGameId = current.parameters['id'];
    if (_curGameId == null) {
      _curGameId = current.queryParameters['id'];
    }
    if (_curGameId != null) {
      _sub = _db.getSharedGame(_curGameId).listen((event) {
        game = event;
        _controller.add(event);
      });
    }
  }
}
