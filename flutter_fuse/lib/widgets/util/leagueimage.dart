import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'cachednetworkimage.dart';

///
/// Image for the league, handling the fade in/out and caching of the
/// image itself in the local cache.
///
class LeagueImage extends StatelessWidget {
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

  ImageProvider _providerFromLeague(LeagueOrTournament league) {
    String photoUrl = league.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return new CachedNetworkImageProvider(urlNow: photoUrl);
    }

    return const AssetImage("assets/images/defaultavatar.png");
  }

  @override
  Widget build(BuildContext context) {
    var blocBuilder = BlocBuilder(
        cubit: BlocProvider.of<LeagueOrTournamentBloc>(context),
        builder: (BuildContext context, LeagueOrTournamentState leagueState) {
          Widget inner;
          if (leagueState is LeagueOrTournamentLoaded) {
            if (leagueState.leagueOrTournaments
                .containsKey(leagueOrTournamentUid)) {
              // Yay!
              inner = FadeInImage(
                image: _providerFromLeague(
                    leagueState.leagueOrTournaments[leagueOrTournamentUid]),
                height: height,
                width: width,
                fit: fit,
                alignment: alignment,
                repeat: repeat,
                matchTextDirection: matchTextDirection,
                placeholder: AssetImage("assets/images/defaultavatar.png"),
              );
            } else {
              inner = FadeInImage(
                image: AssetImage("assets/images/defaultavatar.png"),
                height: height,
                width: width,
                fit: fit,
                alignment: alignment,
                repeat: repeat,
                matchTextDirection: matchTextDirection,
                placeholder: AssetImage("assets/images/defaultavatar.png"),
              );
            }
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
        });

    return SizedBox(width: width, height: height, child: blocBuilder);
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
