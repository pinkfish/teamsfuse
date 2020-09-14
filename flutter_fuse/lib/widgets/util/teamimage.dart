import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

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

  Widget getSportWidget(Team team) {
    switch (team.sport) {
      case Sport.Basketball:
        return Image.asset("assets/sports/Sport.Basketball.png");
      case Sport.Soccer:
        return Image.asset("assets/sports/Sport.Soccer.png");
      default:
        break;
    }
    return Image.asset("assets/images/defaultavatar2.png");
  }

  Widget _buildImageBit(Team t) {
    return ClipOval(
      child: SizedBox(
        width: width < height ? width : height,
        height: width < height ? width : height,
        child: FittedBox(
          fit: fit,
          child: CachedNetworkImage(
            imageUrl: t.photoUrl,
            fadeInDuration: Duration(milliseconds: 200),
            fadeOutDuration: Duration(milliseconds: 200),
            alignment: alignment,
            repeat: repeat,
            matchTextDirection: matchTextDirection,
            placeholder: (context, url) => getSportWidget(t),
            errorWidget: (context, url, e) => getSportWidget(t),
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
      cubit: BlocProvider.of<TeamBloc>(context),
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
}
