import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'cachednetworkimage.dart';

class TeamImage extends StatelessWidget {
  TeamImage(
      {this.team,
      this.teamImage,
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
    assert(team != null || teamUid != null || teamImage != null);
  }

  final String teamUid;
  final Team team;
  final File teamImage;
  final double width;
  final double height;
  final Color color;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final bool showIcon;

  ImageProvider _providerFromTeam(Team team) {
    if (teamImage != null) {
      return FileImage(teamImage);
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

  /*
  Future<ImageProvider> get imageUrl async {
    if (team != null) {
      return _providerFromTeam(team);
    }
    // Team uid, lookup the team first.
    Team publicTeam = await UserDatabaseData.instance.updateModel
        .getPublicTeamDetails(teamUid);
    return _providerFromTeam(publicTeam);
  }
  */

  Widget _buildImageBit(Team t) {
    return ClipOval(
      child: SizedBox(
        width: width < height ? width : height,
        height: width < height ? width : height,
        child: FittedBox(
          fit: fit,
          child: FadeInImage(
            fadeInDuration: Duration(milliseconds: 200),
            fadeOutDuration: Duration(milliseconds: 200),
            image: _providerFromTeam(t),
            alignment: alignment,
            repeat: repeat,
            matchTextDirection: matchTextDirection,
            placeholder: AssetImage("assets/images/defaultavatar2.png"),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (teamImage != null) {
      return _buildImageBit(null);
    }
    return BlocBuilder(
      bloc: BlocProvider.of<TeamBloc>(context),
      builder: (BuildContext context, TeamState teamState) {
        Widget inner;
        Team t = team;
        if (t == null) {
          t = teamState.getTeam(teamUid);
        }
        if (t != null &&
            t.photoUrl != null &&
            (t.photoUrl.isNotEmpty || width > 50.0 || !showIcon)) {
          // Yay!
          inner = _buildImageBit(t);
        } else {
          // Try and load the public team.
          if (t == null) {
            BlocProvider.of<TeamBloc>(context)
                .add(TeamLoadPublicTeam(teamUid: teamUid));
          }
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
