import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/media/mediacard.dart';
import 'package:flutter_fuse/widgets/teams/seasondropdown.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Show the media associated with the team.
///
class TeamMediaScreen extends StatefulWidget {
  /// The teamUid for the media.
  final String teamUid;

  /// Creates the team media screen.
  TeamMediaScreen(this.teamUid);

  @override
  State<StatefulWidget> createState() {
    return _TeamMediaScreenState();
  }
}

class _TeamMediaScreenState extends State<TeamMediaScreen> {
  String _seasonUid;

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (context, singleTeamBloc) => BlocBuilder(
          bloc: singleTeamBloc,
          builder: (context, teamState) {
            if (teamState is SingleTeamDeleted) {
              Navigator.pop(context);
              return Text(Messages.of(context).teamDeleted);
            }
            if (teamState is SingleTeamUninitialized) {
              return LoadingWidget();
            }
            _seasonUid ??= teamState.team.currentSeason;

            var actions = <Widget>[
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/Team/Media/${widget.teamUid}',
                ),
              ),
            ];

            if (!teamState.loadedSeasons) {
              singleTeamBloc.add(SingleTeamLoadSeasons());
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  Messages.of(context)
                      .titleWith(singleTeamBloc.state.team.name),
                ),
                actions: actions,
              ),
              body: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeasonDropDown(
                      teamUid: widget.teamUid,
                      value: _seasonUid,
                      onChanged: (s) => setState(() => _seasonUid = s),
                    ),
                    Expanded(
                        child: SingleSeasonProvider(
                      seasonUid: _seasonUid,
                      builder: (context, singleSeasonBloc) => BlocBuilder(
                        bloc: singleSeasonBloc,
                        builder: (context, seasonState) {
                          if (seasonState is SingleSeasonUninitialized) {
                            return LoadingWidget();
                          }

                          if (seasonState is SingleSeasonDeleted) {
                            return DeletedWidget();
                          }
                          if (!seasonState.loadedMedia) {
                            singleSeasonBloc.add(SingleSeasonLoadMedia());
                            return LoadingWidget();
                          }
                          if (seasonState.media.isEmpty) {
                            return Text(Messages.of(context).noMedia);
                          }
                          return ListView(
                            children: seasonState.media
                                .map<Widget>((m) => MediaCard(
                                      media: m,
                                      allMedia: seasonState.media,
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    )),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
