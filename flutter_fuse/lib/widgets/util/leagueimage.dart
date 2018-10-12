import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';
import 'dart:async';

///
/// Image for the league, handling the fade in/out and caching of the
/// image itself in the local cache.
///
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

  LeagueImage(
      {this.leagueOrTournamentUid,
      this.leagueOrTournament,
      Key key,
      this.width,
      this.height,
      this.color,
      this.colorBlendMode,
      this.fit,
      this.alignment: Alignment.center,
      this.repeat: ImageRepeat.noRepeat,
      this.matchTextDirection: false})
      : super(
          key: key,
        );

  ImageProvider _providerFromLeague(LeagueOrTournament league) {
    String photoUrl = league.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return new CachedNetworkImageProvider(urlNow: photoUrl);
    }

    return const AssetImage("assets/images/defaultavatar.png");
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
            placeholder: AssetImage("assets/images/defaultavatar.png"),
          );
        } else {
          inner = Center(child: CircularProgressIndicator());
        }
        return AnimatedContainer(
          duration: Duration(milliseconds: 500),
          color: color,
          height: height,
          width: width,
          alignment: alignment,
          child: inner,
        );
      },
    );

    return SizedBox(width: width, height: height, child: futureBuilder);
  }

  static ImageProvider getImageURL(Team team) {
    if (team == null) {
      return const AssetImage("assets/images/defaultavatar.png");
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
    return const AssetImage("assets/images/defaultavatar.png");
  }
}