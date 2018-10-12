import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';
import 'dart:async';

class TeamImage extends StatelessWidget {
  final String teamUid;
  final Team team;
  final double width;
  final double height;
  final Color color;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final bool showIcon;

  TeamImage(
      {this.team,
      this.teamUid,
      Key key,
      this.width = 200.0,
      this.height = 200.0,
      this.color,
      this.showIcon = false,
      this.fit = BoxFit.cover,
      this.alignment: Alignment.center,
      this.repeat: ImageRepeat.noRepeat,
      this.matchTextDirection: false})
      : super(
          key: key,
        ) {
    assert(team != null || teamUid != null);
  }

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
    if (team != null) {
      return _providerFromTeam(team);
    }
    // Team uid, lookup the team first.
    Team oublicTeam = await UserDatabaseData.instance.updateModel
        .getPublicTeamDetails(teamUid);
    return _providerFromTeam(oublicTeam);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<Team>(
      future: team != null
          ? Future.value<Team>(team)
          : UserDatabaseData.instance.updateModel.getPublicTeamDetails(teamUid),
      builder: (BuildContext context, AsyncSnapshot<Team> snap) {
        Widget inner;
        if (snap.hasData &&
            (snap.data.photoUrl != null && snap.data.photoUrl.isNotEmpty ||
                width > 50.0 ||
                !showIcon)) {
          // Yay!
          inner = ClipOval(
            child: SizedBox(
              width: width < height ? width : height,
              height: width < height ? width : height,
              child: FittedBox(
                fit: fit,
                child: FadeInImage(
                  fadeInDuration: Duration(milliseconds: 200),
                  fadeOutDuration: Duration(milliseconds: 200),
                  image: _providerFromTeam(snap.data),
                  alignment: alignment,
                  repeat: repeat,
                  matchTextDirection: matchTextDirection,
                  placeholder: AssetImage("assets/images/defaultavatar2.png"),
                ),
              ),
            ),
          );
        } else {
          inner = const Icon(Icons.group);
        }
        return Container(
          color: color,
          height: height,
          width: width,
          alignment: alignment,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: inner,
          ),
        );
      },
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
