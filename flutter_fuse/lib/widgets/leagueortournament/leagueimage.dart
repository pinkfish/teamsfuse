import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentprovider.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Image for the league, handling the fade in/out and caching of the
/// image itself in the local cache.
///
class LeagueImage extends StatelessWidget {
  /// Constructor.
  LeagueImage(
      {String leagueOrTournamentUid,
      this.leagueOrTournament,
      Key key,
      this.width,
      this.height,
      this.color,
      this.colorBlendMode,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.matchTextDirection = false})
      : assert(leagueOrTournament != null || leagueOrTournamentUid != null),
        this._leagueOrTournamentUid =
            leagueOrTournamentUid ?? leagueOrTournament.uid,
        super(
          key: key,
        );

  /// The league or tournament to display.
  final String _leagueOrTournamentUid;

  /// The league or tournament to display.
  final LeagueOrTournament leagueOrTournament;

  /// How wide the image is,
  final double width;

  /// Height of the image,
  final double height;

  /// Color of the background.
  final Color color;

  /// How to fit the image in the box.
  final BoxFit fit;

  /// Alignment to use for the image.
  final AlignmentGeometry alignment;

  /// Background repating for the image.
  final ImageRepeat repeat;

  /// matching the text direction.
  final bool matchTextDirection;

  /// The blend mode to use for the color.
  final BlendMode colorBlendMode;

  Widget _buildInner(LeagueOrTournament league) {
    return CachedNetworkImage(
      imageUrl: league.photoUrl ?? "",
      imageBuilder: (context, imageProvider) => FadeInImage(
        image: imageProvider,
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        placeholder: AssetImage('assets/images/defaultavatar.png'),
      ),
      placeholder: (context, url) =>
          Image.asset('assets/images/defaultavatar.png'),
      errorWidget: (context, url, error) =>
          Image.asset('assets/images/defaultavatar.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (leagueOrTournament != null) {
      return SizedBox(
        width: width,
        height: height,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          color: color,
          height: height,
          width: width,
          alignment: alignment,
          child: _buildInner(leagueOrTournament),
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: SingleLeagueOrTournamentProvider(
        leagueUid: _leagueOrTournamentUid,
        builder: (context, singleLeagueOrTournamentBloc) => BlocBuilder(
          cubit: singleLeagueOrTournamentBloc,
          builder: (context, SingleLeagueOrTournamentState leagueState) {
            Widget inner;
            if (leagueState is SingleLeagueOrTournamentUninitialized) {
              inner = Center(child: CircularProgressIndicator());
            } else {
              // Yay!
              inner = _buildInner(leagueState.league);
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
        ),
      ),
    );
  }
}
