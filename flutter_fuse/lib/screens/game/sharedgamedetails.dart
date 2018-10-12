import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/games/gameshareddetails.dart';
import 'package:flutter_fuse/widgets/games/deletesharedgamedialog.dart';

class SharedGameDetailsScreen extends StatefulWidget {
  SharedGameDetailsScreen(this.sharedGameUid);

  final String sharedGameUid;

  @override
  _SharedGameDetailsScreenState createState() {
    return new _SharedGameDetailsScreenState();
  }
}

class _SharedGameDetailsScreenState extends State<SharedGameDetailsScreen> {
  ScrollController _scrollController = new ScrollController();
  SharedGameSubscription _gameSub;
  GameSharedData _game;
  LeagueOrTournament _league;

  @override
  void initState() {
    super.initState();
    _gameSub = UserDatabaseData.instance.updateModel
        .getSharedGame(widget.sharedGameUid);
  }

  @override
  void dispose() {
    super.dispose();
    _gameSub?.dispose();
  }

  void _select(String choice) async {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {});
    if (choice == 'delete') {
      // Show a dialog and then delete it!
      bool deleted = await deleteSharedGameDialog(context, _game);
      if (deleted) {
        Navigator.pop(context);
      }
    }
  }

  void _editGame() {
    Navigator.pushNamed(context, "EditSharedGame/" + widget.sharedGameUid);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    List<Widget> actions = <Widget>[];
    FloatingActionButton fab;

    body = StreamBuilder<Iterable<GameSharedData>>(
        stream: _gameSub.stream,
        builder: (BuildContext context,
            AsyncSnapshot<Iterable<GameSharedData>> snap) {
          if (snap.hasData && snap.data.length > 0) {
            _game = snap.data.first;
          }
          if (_game != null) {
            return GameSharedDetails(_game);
          }
          return Center(child: Text(Messages.of(context).loading));
        });

    if (_league != null && _league.isAdmin() && _game != null) {
      actions.add(
        new PopupMenuButton<String>(
          onSelected: (String str) => _select(str),
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                value: "delete",
                child: new Text(Messages.of(context).deletegame(_game)),
              ),
            ];
          },
        ),
      );
      fab = FloatingActionButton(
        onPressed: _editGame,
        child: new Icon(Icons.edit),
        //backgroundColor: Colors.orange,
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: Text(Messages.of(context).game),
        actions: actions,
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: new Scrollbar(
        child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: body,
        ),
      ),
    );
  }
}
