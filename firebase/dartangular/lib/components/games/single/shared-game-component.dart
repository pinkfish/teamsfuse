import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
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
  SharedGameSubscription _sub;

  SingleGameComponent() {
  }

  @override
  Future<Null> ngOnInit() async {
  }

  @override
  void ngOnDestroy() {
    _sub?.dispose();
    _sub = null;
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    _curGameId = current.parameters['id'];
    if (_curGameId == null) {
      _curGameId = current.queryParameters['id'];
    }
    if (_curGameId != null) {
      _sub = UserDatabaseData.instance.updateModel.getSharedGame(_curGameId);
      _sub.stream.listen((Iterable<GameSharedData> data) {
        if (data.length > 0) {
          game = data.first;
          _controller.add(data.first);
        }
      });
      if (_sub.initialData.length > 0) {
        game = _sub.initialData.first;
        _controller.add(_sub.initialData.first);
      }
    }
  }
}
