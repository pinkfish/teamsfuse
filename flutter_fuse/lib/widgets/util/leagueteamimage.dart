import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';
import 'dart:async';
import 'package:flutter_fuse/services/messages.dart';

/// Some overlay text onto the team to say home/away.
enum HomeAwayOverlay { Home, Away, None }

///
/// Looks up the league team from the database and then uses that to display
/// the image for team.  It has default behavior and shows a progress indicator
/// while loading.
///
class LeagueTeamImage extends StatelessWidget {
  final String leagueOrTeamUid;
  final LeagueOrTournamentTeam team;
  final double width;
  final double height;
  final BoxFit fit;
  final Color color;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final HomeAwayOverlay overlay;

  LeagueTeamImage(
      {this.team,
      this.leagueOrTeamUid,
      Key key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.overlay = HomeAwayOverlay.None,
      this.alignment: Alignment.center,
      this.repeat: ImageRepeat.noRepeat,
      this.matchTextDirection: false})
      : super(
          key: key,
        ) {}

  ImageProvider _providerFromTeam(Team team) {
    if (team == null) {
      return const AssetImage("assets/images/leagueteam.png");
    }
    String photoUrl = team.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return new CachedNetworkImageProvider(urlNow: photoUrl);
    }
    switch (team.sport) {
      case Sport.Basketball:
        return const AssetImage("assets/sports/Sport.Basketball.png");
      case Sport.Soccer:
        return const AssetImage("assets/sports/Sport.Soccer.png");
      default:
        break;
    }
    return const AssetImage("assets/images/leagueteam.png");
  }

  Future<ImageProvider> get imageUrl async {
    LeagueOrTournamentTeam lookupTeam = team;
    if (lookupTeam == null) {
      lookupTeam = await UserDatabaseData.instance.updateModel
          .getLeagueTeamData(leagueOrTeamUid);
    }
    // Team uid, lookup the team first.
    if (lookupTeam.seasonUid == null) {
      return const AssetImage("assets/images/leagueteam.png");
    }
    Season season = await UserDatabaseData.instance.updateModel
        .getSeason(lookupTeam.seasonUid);
    if (season == null) {
      return const AssetImage("assets/images/leagueteam.png");
    }
    Team publicTeam = await UserDatabaseData.instance.updateModel
        .getPublicTeamDetails(lookupTeam.teamUid);
    return _providerFromTeam(publicTeam);
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder<ImageProvider> futureBuilder = FutureBuilder<ImageProvider>(
      future: imageUrl,
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snap) {
        Widget inner;
        if (snap.hasData) {
          // Yay!
          inner = FadeInImage(
            image: snap.data,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            matchTextDirection: matchTextDirection,
            placeholder: AssetImage("assets/images/leagueteam.png"),
          );
        } else {
          inner = Center(child: CircularProgressIndicator());
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: inner,
        );
      },
    );
    if (overlay == HomeAwayOverlay.None) {
      return SizedBox(width: width, height: height, child: futureBuilder);
    }
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          futureBuilder,
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade200.withOpacity(0.7),
              ),
              width: width,
              child: Text(
                overlay == HomeAwayOverlay.Away
                    ? Messages.of(context).away
                    : Messages.of(context).home,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height / 5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static ImageProvider getImageURL(Team team) {
    if (team == null) {
      return const AssetImage("assets/images/leagueteam.png");
    }
    String photoUrl = team.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return new CachedNetworkImageProvider(urlNow: photoUrl);
    }
    switch (team.sport) {
      case Sport.Basketball:
        return const AssetImage("assets/sports/Sport.Basketball.png");
      case Sport.Soccer:
        return const AssetImage("assets/sports/Sport.Soccer.png");
      default:
        break;
    }
    return const AssetImage("assets/images/leagueteam.png");
  }
}
