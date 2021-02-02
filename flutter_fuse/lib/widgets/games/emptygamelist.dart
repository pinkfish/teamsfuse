import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import '../../services/blocs.dart';

import '../../services/messages.dart';

///
/// What to show when there are no games.  Empty!
///
class EmptyGameList extends StatelessWidget {
  void _addTeam(BuildContext context) {
    Navigator.pushNamed(context, "AddTeam");
  }

  void _addGame(BuildContext context) {
    Navigator.pushNamed(context, "AddGame");
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    RaisedButton button;
    var teams = BlocProvider.of<TeamBloc>(context);
    if (teams.state.allTeamUids.length == 0) {
      button = RaisedButton(
        onPressed: () => _addTeam(context),
        child: Text(Messages.of(context).addteam),
      );
    } else {
      button = RaisedButton(
        onPressed: () => _addGame(context),
        child: Text(Messages.of(context).addgamebutton),
      );
    }

    return Column(
      children: <Widget>[
        Center(
            child: Image(
          image: ExactAssetImage("assets/images/abstractsport.png"),
          width: screenSize.width < screenSize.height
              ? screenSize.width - 30.0
              : screenSize.height - 30.0,
          height: screenSize.width < screenSize.height
              ? screenSize.width - 30.0
              : screenSize.height - 30.0,
        )),
        button,
      ],
    );
  }
}
