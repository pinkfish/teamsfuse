import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';
import 'dart:async';
import 'package:flutter_fuse/services/messages.dart';

enum HomeAwayOverlay { Home, Away, None }

class LeagueTeamImage extends StatelessWidget {
  final String leagueOrTeamUid;
  final LeagueOrTournamentTeam team;
  final double width;
  final double height;
  final Color color;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final BlendMode colorBlendMode;
  final HomeAwayOverlay overlay;

  LeagueTeamImage(
      {this.team,
      this.leagueOrTeamUid,
      Key key,
      this.width,
      this.height,
      this.color,
      this.colorBlendMode,
      this.fit,
      this.overlay = HomeAwayOverlay.None,
      this.alignment: Alignment.center,
      this.repeat: ImageRepeat.noRepeat,
      this.matchTextDirection: false})
      : super(
          key: key,
        ) {}

  ImageProvider _providerFromTeam(Team team) {
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
    return const AssetImage("assets/images/defaultavatar2.png");
  }

  Future<ImageProvider> get imageUrl async {
    LeagueOrTournamentTeam lookupTeam = team;
    if (lookupTeam == null) {
      lookupTeam = await UserDatabaseData.instance.updateModel
          .getLeagueTeamData(leagueOrTeamUid);
    }
    // Team uid, lookup the team first.
    if (lookupTeam.seasonUid == null) {
      return const AssetImage("assets/images/defaultavatar2.png");
    }
    Season season = await UserDatabaseData.instance.updateModel
        .getSeason(lookupTeam.seasonUid);
    if (season == null) {
      return const AssetImage("assets/images/defaultavatar2.png");
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
        if (snap.hasData) {
          // Yay!
          return Image(
            image: snap.data,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            matchTextDirection: matchTextDirection,
            color: color,
            colorBlendMode: colorBlendMode,
          );
        }
        return Container(
          color: color,
          height: height,
          width: width,
          alignment: alignment,
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
      return const AssetImage("assets/images/defaultavatar2.png");
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
    return const AssetImage("assets/images/defaultavatar2.png");
  }
}
