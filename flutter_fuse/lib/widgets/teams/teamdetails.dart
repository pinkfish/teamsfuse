import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/teamresultsstreamfuture.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/teamimage.dart';

class TeamDetails extends StatefulWidget {
  final String teamuid;

  TeamDetails(this.teamuid);

  @override
  TeamDetailsState createState() {
    return new TeamDetailsState();
  }
}

class TeamDetailsState extends State<TeamDetails> {
  Team team;

  StreamSubscription<UpdateReason> teamUpdate;

  TeamDetailsState();

  @override
  void initState() {
    super.initState();
    team = UserDatabaseData.instance.teams[widget.teamuid];
    if (team != null) {
      teamUpdate = team.thisTeamStream.listen((data) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    teamUpdate.cancel();
    teamUpdate = null;
  }

  Widget _buildSeasons(BuildContext context) {
    List<Widget> ret = new List<Widget>();

    if (team.isAdmin(UserDatabaseData.instance.players)) {
      ret.add(
        new FlatButton(
          onPressed: () =>
              Navigator.pushNamed(context, "AddSeason/" + team.uid),
          child: new Text(Messages.of(context).addseason),
        ),
      );
    }

    team.seasons.forEach((key, season) {
      ret.add(new ExpansionTile(
        key: new PageStorageKey<Season>(season),
        title: new Text(season.name +
            " W:" +
            season.record.win.toString() +
            " L:" +
            season.record.loss.toString() +
            " T:" +
            season.record.tie.toString()),
        children: <Widget>[
          new TeamResultsStreamFuture(
            future: season.getGames(),
          ),
        ],
        initiallyExpanded: false,
      ));
    });
    return new Column(
      children: ret,
    );
  }

  Widget _buildGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.Female:
        return const Icon(CommunityIcons.genderfemale);
      case Gender.Male:
        return const Icon(CommunityIcons.gendermale);
      case Gender.Coed:
        return const Icon(CommunityIcons.gendermalefemale);
      case Gender.NA:
        return const Icon(CommunityIcons.blank);
    }
    return const Icon(CommunityIcons.blank);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (team == null) {
      return new Column(
        children: <Widget>[
          new Center(
              child: new Image(
            image: new ExactAssetImage("assets/images/abstractsport.png"),
            width: (screenSize.width < 500)
                ? 120.0
                : (screenSize.width / 4) + 12.0,
            height: screenSize.height / 4 + 20,
          )),
          new ListTile(title: new Text(Messages.of(context).unknown)),
          _buildSeasons(context)
        ],
      );
    }

    return new Column(
      children: <Widget>[
        new Center(
            child: new TeamImage(
          team.uid,
          width:
              (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
          height: screenSize.height / 4 + 20,
        )),
        new ListTile(
            title: new Text(team.name),
            subtitle:
                new Text(team.sport.toString() + "(" + team.league + ") "),
            trailing: _buildGenderIcon(team.gender)),
        _buildSeasons(context)
      ],
    );
  }
}
