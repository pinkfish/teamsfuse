import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

///
/// Displays an image for the team.
///
class TeamImage extends StatelessWidget {
  /// Constructor the team image display.  Must specify a team or teamUid or
  /// teamImage
  TeamImage(
      {this.team,
      this.teamImage,
      String teamUid,
      Key key,
      this.width = 200.0,
      this.height = 200.0,
      this.color,
      this.showIcon = false,
      this.fit = BoxFit.cover,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.matchTextDirection = false})
      : this.teamUid = teamUid ?? team.uid,
        super(
          key: key,
        ) {
    assert(team != null || teamUid != null || teamImage != null);
  }

  /// Uid of the team to display.
  final String teamUid;

  /// The team to display.
  final Team team;

  /// The image itself to use
  final File teamImage;

  /// Width of the image
  final double width;

  /// Height of the image.
  final double height;

  /// Background color.
  final Color color;

  /// How to fit the image in the space
  final BoxFit fit;

  /// How to align the image in the box.
  final AlignmentGeometry alignment;

  /// Should we repeatg in the background.
  final ImageRepeat repeat;

  /// The text direction.
  final bool matchTextDirection;

  /// If we should display an icon or not.
  final bool showIcon;

  Widget _getSportWidget(Team team) {
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
          child: t.photoUrl != null && t.photoUrl.isNotEmpty ?
          CachedNetworkImage(
            imageUrl: t.photoUrl ?? "",
            fadeInDuration: Duration(milliseconds: 200),
            fadeOutDuration: Duration(milliseconds: 200),
            alignment: alignment,
            repeat: repeat,
            matchTextDirection: matchTextDirection,
            placeholder: (context, url) => _getSportWidget(t),
            errorWidget: (context, url, e) => _getSportWidget(t),
          ) : _getSportWidget(t),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (teamImage != null) {
      return _buildImageBit(team);
    }
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (context, singleTeamBloc) => BlocBuilder(
        cubit: singleTeamBloc,
        builder: (context, teamState) {
          Widget inner;
          if (teamState is SingleTeamUninitialized) {
            inner = Icon(MdiIcons.loading);
          } else if (teamState is SingleTeamDeleted) {
            inner = Icon(MdiIcons.skullCrossbones);
          } else {
            var t = teamState.team;
            if (t.photoUrl != null &&
                (t.photoUrl.isNotEmpty || width > 50.0 || !showIcon)) {
              // Yay!
              inner = _buildImageBit(t);
            } else {
              if (showIcon) {
                inner = const Icon(Icons.group);
              } else {
                inner = _buildImageBit(t);
              }
            }
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
      ),
    );
  }
}
