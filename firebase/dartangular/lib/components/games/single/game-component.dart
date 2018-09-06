import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'game-display-component.dart';

@Component(
  selector: 'single-game',
  directives: const [
    routerDirectives,
    NgIf,
    GameDisplayComponent,
  ],
  pipes: const [AsyncPipe],
  templateUrl: 'game-component.html',
  styleUrls: const [],
)
class SingleGameComponent implements OnInit, OnActivate, OnDestroy {
  Stream<Game> game;
  String _curGameId;
  final StreamController<Game> _controller = new StreamController<Game>();
  StreamSubscription<UpdateReason> _sub;

  SingleGameComponent() {
    game = _controller.stream.asBroadcastStream();
  }

  Future<Null> ngOnInit() async {
    _sub = UserDatabaseData.instance.teamStream.listen((UpdateReason reason) {
      if (UserDatabaseData.instance.gamesCache.containsKey(_curGameId)) {
        _controller.add(UserDatabaseData.instance.gamesCache[_curGameId]);
      }
    });
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    _curGameId = current.parameters['id'];
    if (_curGameId == null) {
      _curGameId = current.queryParameters['id'];
    }
    if (_curGameId != null) {
      _controller.add(UserDatabaseData.instance.gamesCache[_curGameId]);
    }
  }
}
