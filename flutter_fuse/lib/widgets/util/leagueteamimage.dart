import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleleagueortournamentteamprovider.dart';

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
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.matchTextDirection = false})
      : assert(leagueOrTeamUid != null),
        super(
          key: key,
        );

  /// The league or team to display, must not be null.
  final String leagueOrTeamUid;

  /// Width of the box
  final double width;

  /// Height of the box.
  final double height;

  /// How to fit the image in the box.
  final BoxFit fit;

  /// Background color of the box.
  final Color color;

  /// How to align the image in the box.
  final AlignmentGeometry alignment;

  /// Repeat the image in the background.
  final ImageRepeat repeat;

  /// Match the text direction.
  final bool matchTextDirection;

  /// The overlay text to say home/away.
  final HomeAwayOverlay overlay;

  Widget _getDefaultForSport(Team team) {
    switch (team.sport) {
      case Sport.Basketball:
        return Image.asset("assets/sports/Sport.Basketball.png");
      case Sport.Soccer:
        return Image.asset("assets/sports/Sport.Soccer.png");
      default:
        break;
    }
    return Image.asset("assets/images/leagueteam.png");
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

              inner = CachedNetworkImage(
                imageUrl: leagueState.publicTeam.photoUrl,
                imageBuilder: (context, imageProvider) => Image(
                  image: imageProvider,
                  height: height,
                  width: width,
                  fit: fit,
                  alignment: alignment,
                  repeat: repeat,
                  matchTextDirection: matchTextDirection,
                ),
                placeholder: (context, url) =>
                    _getDefaultForSport(leagueState.publicTeam),
                errorWidget: (context, url, error) =>
                    _getDefaultForSport(leagueState.publicTeam),
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
}
