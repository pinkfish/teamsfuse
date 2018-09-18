import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';
import 'dart:async';
import 'package:flutter_fuse/services/messages.dart';

enum HomeAwayOverlay { Home, Away, None }

class LeagueImage extends StatelessWidget {
  final String leagueOrTournamentUid;
  final LeagueOrTournament leagueOrTournament;
  final double width;
  final double height;
  final Color color;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final BlendMode colorBlendMode;
  final HomeAwayOverlay overlay;

  LeagueImage(
      {this.leagueOrTournamentUid,
      this.leagueOrTournament,
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

  ImageProvider _providerFromLeague(LeagueOrTournament league) {
    String photoUrl = league.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return new CachedNetworkImageProvider(urlNow: photoUrl);
    }

    return const AssetImage("assets/images/defaultavatar2.png");
  }

  Future<ImageProvider> get imageUrl async {
    LeagueOrTournament lookupLeague = leagueOrTournament;
    if (lookupLeague == null) {
      lookupLeague = await UserDatabaseData.instance.updateModel
          .getLeagueData(leagueOrTournamentUid);
    }
    // Team uid, lookup the team first.

    return _providerFromLeague(lookupLeague);
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
              ),
              child: Text(
                overlay == HomeAwayOverlay.Away
                    ? Messages.of(context).away
                    : Messages.of(context).home,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          futureBuilder
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
