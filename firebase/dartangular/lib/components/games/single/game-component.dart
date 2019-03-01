import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'game-display-component.dart';
import 'package:google_maps/google_maps.dart';
import 'dart:html';

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
  Game game;
  String _curGameId;
  final StreamController<Game> _controller = new StreamController<Game>();
  StreamSubscription<UpdateReason> _sub;

  SingleGameComponent();
  @override
  Future<Null> ngOnInit() async {}

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
      game = UserDatabaseData.instance.gamesCache[_curGameId];
      if (game == null) {
        UserDatabaseData.instance.updateModel
            .getGame(_curGameId)
            .then((Game g) {
          game = g;
        });
      }
    }
  }
}
