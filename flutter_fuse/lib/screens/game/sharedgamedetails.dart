import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singlesharedgameprovider.dart';
import 'package:flutter_fuse/widgets/games/gameshareddetails.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

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
  LeagueOrTournament _league;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _select(String choice) async {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {});
  }

  void _editGame() {
    Navigator.pushNamed(context, "EditSharedGame/" + widget.sharedGameUid);
  }

  @override
  Widget build(BuildContext context) {
    return SingleSharedGameProvider(
      sharedGameUid: widget.sharedGameUid,
      builder: (BuildContext context, SingleSharedGameBloc sharedGameBloc) =>
          BlocListener(
        bloc: sharedGameBloc,
        listener:
            (BuildContext context, SingleSharedGameState sharedGameState) {
          if (sharedGameState is SingleSharedGameDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          bloc: sharedGameBloc,
          builder:
              (BuildContext context, SingleSharedGameState sharedGameState) {
            List<Widget> actions = <Widget>[];
            FloatingActionButton fab;

            if (_league != null &&
                _league.isAdmin() &&
                !(sharedGameState is SingleSharedGameDeleted)) {
              fab = FloatingActionButton(
                onPressed: _editGame,
                child: new Icon(Icons.edit),
                //backgroundColor: Colors.orange,
              );
            }
            return Scaffold(
              appBar: new AppBar(
                title: Text(Messages.of(context).game),
                actions: actions,
              ),
              floatingActionButton: fab,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              body: new Scrollbar(
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  child: GameSharedDetails(sharedGameState.sharedData),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
