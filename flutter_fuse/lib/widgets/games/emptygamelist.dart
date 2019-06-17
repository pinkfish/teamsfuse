import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

class EmptyGameList extends StatelessWidget {
  void _addTeam(BuildContext context) {
    Navigator.pushNamed(context, "AddTeam");
  }

  void _addGame(BuildContext context) {
    Navigator.pushNamed(context, "AddGame");
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    RaisedButton button;
    TeamBloc teams = BlocProvider.of<TeamBloc>(context);
    if (teams.currentState.allTeamUids.length == 0) {
      button = new RaisedButton(
        onPressed: () => _addTeam(context),
        child: new Text(Messages.of(context).addteam),
      );
    } else {
      button = new RaisedButton(
        onPressed: () => _addGame(context),
        child: new Text(Messages.of(context).addgame),
      );
    }

    return new Column(
      children: <Widget>[
        new Center(
            child: new Image(
          image: new ExactAssetImage("assets/images/abstractsport.png"),
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
