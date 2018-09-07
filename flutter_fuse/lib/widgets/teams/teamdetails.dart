import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/games/teamresultsstreamfuture.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/util/gendericon.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

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
      teamUpdate = team.thisTeamStream.listen((UpdateReason data) {
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

  Widget _buildSeasonExpansionTitle(Season season) {
    return new ExpansionTile(
      key: new PageStorageKey<Season>(season),
      title: new Text(
        season.name +
            " W:" +
            season.record.win.toString() +
            " L:" +
            season.record.loss.toString() +
            " T:" +
            season.record.tie.toString(),
      ),
      children: <Widget>[
        new TeamResultsStreamFuture(
          teamUid: team.uid,
          seasonUid: season.uid,
        ),
      ],
      initiallyExpanded: false,
    );
  }

  Widget _buildSeasons(BuildContext context) {
    List<Widget> ret = <Widget>[];

    if (team.isAdmin()) {
      ret.add(
        new FlatButton(
          onPressed: () =>
              Navigator.pushNamed(context, "AddSeason/" + team.uid),
          child: new Text(Messages.of(context).addseason),
        ),
      );
    }
    // Show all the seasons here, not just the ones we know.
    ret.add(new FutureBuilder<Iterable<Season>>(
        future: team.getAllSeasons(),
        builder: (BuildContext context, AsyncSnapshot<Iterable<Season>> data) {
          List<Widget> happyData = <Widget>[];

          if (data.hasData) {
            for (Season season in data.data) {
              happyData.add(_buildSeasonExpansionTitle(season));
            }
          } else {
            // Show the ones we currently know about.
            for (Season season in team.seasons.values) {
              happyData.add(_buildSeasonExpansionTitle(season));
            }
            // Also mark we are still loading.
            happyData.add(new Text(Messages.of(context).loading));
          }
          return new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: happyData,
          );
        }));
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ret,
    );
  }

  void _openClub() {
    if (team.clubUid != null) {
      Navigator.pushNamed(context, "Club/" + team.clubUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (team == null) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Center(
            child: new Image(
              image: new ExactAssetImage("assets/images/abstractsport.png"),
              width: (screenSize.width < 500)
                  ? 120.0
                  : (screenSize.width / 4) + 12.0,
              height: screenSize.height / 4 + 20,
            ),
          ),
          new ListTile(title: new Text(Messages.of(context).unknown)),
          _buildSeasons(context)
        ],
      );
    }

    Widget club;
    if (team.clubUid != null) {
      club = new FutureBuilder<Club>(
        future: UserDatabaseData.instance.getClub(team.clubUid),
        builder: (BuildContext context, AsyncSnapshot<Club> club) {
          if (club.hasData) {
            if (club.data != null) {
              return new Text(club.data.name);
            }
            return new Text(Messages.of(context).noclub);
          }
          return new Text(Messages.of(context).loading);
        },
      );
    } else {
      club = new Text(Messages.of(context).noclub);
    }

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Center(
          child: new TeamImage(
            team: team,
            width: (screenSize.width < 500)
                ? 120.0
                : (screenSize.width / 4) + 12.0,
            height: screenSize.height / 4 + 20,
          ),
        ),
        new ListTile(
          leading: const Icon(Icons.people),
          title: new Text(team.name),
          subtitle: new Text(team.sport.toString() + "(" + team.league + ") "),
          trailing: new GenderIcon(team.gender),
        ),
        new ListTile(
          leading: const Icon(CommunityIcons.cardsClub),
          title: club,
          onTap: _openClub,
        ),
        new ListTile(
          leading: const Icon(Icons.timer),
          title: new Text(
            Messages.of(context).arrivebefore(
              team.arriveEarly.toInt(),
            ),
          ),
        ),
        new ListTile(
          leading: const Icon(CommunityIcons.trafficLight),
          title: new Text(
            Messages.of(context).trackattendence(
                team.trackAttendence ? Tristate.Yes : Tristate.No),
          ),
        ),
        _buildSeasons(context)
      ],
    );
  }
}
