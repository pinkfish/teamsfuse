import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singlesharedgameprovider.dart';
import '../../widgets/games/gameshareddetails.dart';

///
/// The details of the shared game.  Displays the teams involved and the scores.
///
class SharedGameDetailsScreen extends StatefulWidget {
  /// constructor.
  SharedGameDetailsScreen(this.sharedGameUid);

  /// The shared game uid to display.
  final String sharedGameUid;

  @override
  _SharedGameDetailsScreenState createState() {
    return _SharedGameDetailsScreenState();
  }
}

class _SharedGameDetailsScreenState extends State<SharedGameDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  LeagueOrTournament _league;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editGame() {
    Navigator.pushNamed(context, "EditSharedGame/${widget.sharedGameUid}");
  }

  @override
  Widget build(BuildContext context) {
    return SingleSharedGameProvider(
      sharedGameUid: widget.sharedGameUid,
      builder: (context, sharedGameBloc) => BlocListener(
        cubit: sharedGameBloc,
        listener: (context, sharedGameState) {
          if (sharedGameState is SingleSharedGameDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          cubit: sharedGameBloc,
          builder: (context, sharedGameState) {
            var actions = <Widget>[];
            FloatingActionButton fab;

            if (_league != null &&
                _league.isAdmin() &&
                !(sharedGameState is SingleSharedGameDeleted)) {
              fab = FloatingActionButton(
                onPressed: _editGame,
                child: Icon(Icons.edit),
                //backgroundColor: Colors.orange,
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(Messages.of(context).game),
                actions: actions,
              ),
              floatingActionButton: fab,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              body: Scrollbar(
                child: SingleChildScrollView(
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
