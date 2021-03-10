import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/clubs/clubteams.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/publicteamdetails.dart';

/// Which of the tabs in the public view are selected.
enum PublicTeamTab {
  /// The team tab.
  team,

  /// Players for the team
  players,

  /// The states for the team.
  stats,
}

extension PublicTeamTabExtension on PublicTeamTab {
  /// Turn the enum into a nice string with a name.
  String get name {
    switch (this) {
      case PublicTeamTab.team:
        return 'team';
      case PublicTeamTab.players:
        return 'players';
      case PublicTeamTab.stats:
        return 'stats';
      default:
        return null;
    }
  }

  /// Get the index of this enum in the enum.
  int get sortIndex {
    switch (this) {
      case PublicTeamTab.team:
        return 0;
      case PublicTeamTab.players:
        return 1;
      case PublicTeamTab.stats:
        return 2;
      default:
        return null;
    }
  }

  /// Find the indexof the string.
  static PublicTeamTab fromString(String str) {
    var check = str.toLowerCase();
    return PublicTeamTab.values.firstWhere(
      (v) => v.name == check,
      orElse: () => PublicTeamTab.team,
    );
  }

  /// Find the indexof the string.
  static PublicTeamTab fromIndex(int idx) {
    return PublicTeamTab.values.firstWhere(
      (v) => v.sortIndex == idx,
      orElse: () => PublicTeamTab.team,
    );
  }
}

///
/// Shows the public details of the team.
///
class PublicTeamDetailsScreen extends StatelessWidget {
  /// The tab to display.
  final PublicTeamTab tabSelected;

  /// The team uid to display
  final String teamUid;

  /// Create the team details for this team.
  PublicTeamDetailsScreen(String tab, this.teamUid)
      : tabSelected = PublicTeamTab.fromString(tab);

  Widget _buildBody(BuildContext context, Team team, BoxConstraints layout) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: Column(
            children: [
              TextButton.icon(
                icon: Icon(Icons.arrow_back),
                label: Text(
                  MaterialLocalizations.of(context).backButtonTooltip,
                ),
                onPressed: () => Navigator.pushNamed(
                    context, '/Public/Club/' + team.clubUid),
              ),
              Expanded(
                child: ClubTeams(
                  team.clubUid,
                  onlyPublic: true,
                  selected: team,
                  onTap: (t) =>
                      Navigator.pushNamed(context, '/Public/Team/' + t.uid),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PublicTeamDetails(team.uid),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (context, singleTeamBloc) => BlocConsumer(
        cubit: singleTeamBloc,
        listener: (context, state) {
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          String title;
          if (state is SingleTeamDeleted || state is SingleTeamUninitialized) {
            title = Messages.of(context).loading;
          } else {
            title = state.club.name;
          }
          Widget theBody;
          if (state is SingleTeamDeleted) {
            theBody = Center(
              child: Text(Messages.of(context).clubDeleted,
                  style: Theme.of(context).textTheme.headline3),
            );
          } else if (state is SingleTeamUninitialized) {
            theBody = Center(
              child: LoadingWidget(),
            );
          } else {
            theBody = LayoutBuilder(
              builder: (context, layout) =>
                  _buildBody(context, state.team, layout),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: Icon(MdiIcons.cardsClub),
            ),
            body: theBody,
          );
        },
      ),
    );
  }
}
