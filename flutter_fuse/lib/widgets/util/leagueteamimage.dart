import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleleagueortournamentteamprovider.dart';
import 'cachednetworkimage.dart';

/// Some overlay text onto the team to say home/away.
enum HomeAwayOverlay { home, away, none }

///
/// Looks up the league team from the database and then uses that to display
/// the image for team.  It has default behavior and shows a progress indicator
/// while loading.
///
class LeagueTeamImage extends StatelessWidget {
  LeagueTeamImage(
      {this.leagueOrTeamUid,
      Key key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.overlay = HomeAwayOverlay.none,
      this.alignment: Alignment.center,
      this.repeat: ImageRepeat.noRepeat,
      this.matchTextDirection: false})
      : super(
          key: key,
        );

  final String leagueOrTeamUid;
  final double width;
  final double height;
  final BoxFit fit;
  final Color color;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final HomeAwayOverlay overlay;

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

  @override
  Widget build(BuildContext context) {
    Widget blocBuilder = SingleLeagueOrTournamentTeamProvider(
      leagueTeamUid: leagueOrTeamUid,
      builder: (BuildContext context, SingleLeagueOrTournamentTeamBloc bloc) =>
          BlocListener(
        cubit: bloc,
        listener:
            (BuildContext context, SingleLeagueOrTournamentTeamState state) {
          if (state is SingleLeagueOrTournamentTeamLoaded) {
            bloc.add(SingleLeagueOrTournamentTeamLoadPublicTeam());
          }
        },
        child: BlocBuilder(
          cubit: bloc,
          builder: (BuildContext context,
              SingleLeagueOrTournamentTeamState leagueState) {
            Widget inner;
            if (leagueState is SingleLeagueOrTournamentTeamDeleted ||
                leagueState.publicTeam == null) {
              inner = Center(child: CircularProgressIndicator());
            } else {
              // Yay!

              inner = FadeInImage(
                image: _providerFromTeam(leagueState.publicTeam),
                height: height,
                width: width,
                fit: fit,
                alignment: alignment,
                repeat: repeat,
                matchTextDirection: matchTextDirection,
                placeholder: AssetImage("assets/images/leagueteam.png"),
              );
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: inner,
            );
          },
        ),
      ),
    );
    if (overlay == HomeAwayOverlay.none) {
      return SizedBox(
        width: width,
        height: height,
        child: blocBuilder,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          blocBuilder,
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade200.withOpacity(0.7),
              ),
              width: width,
              child: Text(
                overlay == HomeAwayOverlay.away
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
