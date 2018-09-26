import 'package:angular/angular.dart';
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:teamfuse/components/drawer/clubdraweritem.dart';
import 'package:teamfuse/components/drawer/teamdraweritem.dart';
import 'package:teamfuse/services/isfirebaseauth.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'teamfuse-drawer',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialPersistentDrawerDirective,
    MaterialListComponent,
    MaterialListItemComponent,
    ClubDrawerItem,
    TeamDrawerItem,
    NgFor,
    IfFirebaseAuthDirective,
  ],
  templateUrl: 'drawer.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'drawer.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class Drawer implements OnInit, OnDestroy {
  bool customWidth = false;
  bool end = false;
  Player player = UserDatabaseData.instance.mePlayer;
  Stream<Iterable<Team>> teams;
  Stream<Iterable<Club>> clubs;
  StreamController<Iterable<Team>> _teamController = new StreamController();
  StreamSubscription<UpdateReason> _sub;
  StreamController<Iterable<Club>> _clubController = new StreamController();
  StreamSubscription<UpdateReason> _clubSub;
  final Router _router;

  Drawer(this._router);

  Object trackByTeams(int index, dynamic team) => team is Team ? team.uid : "";
  Object trackByClubs(int index, dynamic club) => club is Club ? club.uid : "";

  @override
  void ngOnInit() {
    teams = _teamController.stream.asBroadcastStream();
    _teamController.add(UserDatabaseData.instance.teams.values);
    _sub = UserDatabaseData.instance.teamStream.listen((UpdateReason reason) {
      _teamController.add(UserDatabaseData.instance.teams.values);
    });

    clubs = _clubController.stream.asBroadcastStream();
    _clubController.add(UserDatabaseData.instance.clubs.values);
    _clubSub =
        UserDatabaseData.instance.clubStream.listen((UpdateReason reason) {
      print('Update clubs ${UserDatabaseData.instance.clubs.length}');
      _clubController.add(UserDatabaseData.instance.clubs.values);
    });
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
    _clubSub?.cancel();
    _sub = null;
    _clubSub = null;
  }

  String get profileUrl {
    return "assets/defaultavatar2.png";
  }

  void openToday() {
    _router.navigate("a/games");
  }

  void openLeague() {
    //_router.navigate("a/league/home");
  }

  void signOut() async {
    print('Starting signout');
    await UserDatabaseData.instance.userAuth.signOut();
    _router.navigate("/g/home");
    print('Ended signout');
  }
}
