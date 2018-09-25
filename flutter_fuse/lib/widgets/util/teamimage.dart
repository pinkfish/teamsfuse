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

  TeamImage(
      {this.team,
      this.teamUid,
      Key key,
      this.width,
      this.height,
      this.color,
      this.fit,
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
    return new SizedBox(
      width: width,
      height: height,
      child: new FutureBuilder(
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
              placeholder: AssetImage("assets/images/defaultavatar2.png"),
            );
          } else {
            inner = Center(child: CircularProgressIndicator());
          }
          return Container(
            color: color,
            height: height,
            width: width,
            alignment: alignment,
            child: inner,
          );
        },
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
