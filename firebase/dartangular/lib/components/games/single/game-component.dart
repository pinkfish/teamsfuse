import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';

import 'game-display-component.dart';

@Component(
  selector: 'game-card',
  directives: [
    DeferredContentDirective,
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
  StreamSubscription<Game> _sub;
  DatabaseUpdateModelImpl _db;

  SingleGameComponent(this._db);
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
      _sub = _db.getGame(_curGameId).listen((g) {
        game = g;
      });
    }
  }
}
