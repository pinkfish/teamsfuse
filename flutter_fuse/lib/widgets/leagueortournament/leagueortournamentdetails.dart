import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';
import '../player/gendericon.dart';
import 'adddivisondialog.dart';
import 'addseasondialog.dart';
import 'leagueimage.dart';

///
/// Show the details for the league or tournament.
///
class LeagueOrTournamentDetails extends StatefulWidget {
  /// Constructor.
  LeagueOrTournamentDetails(this.leagueOrTournamentUid);

  /// League or tournament to show the details of.
  final String leagueOrTournamentUid;

  @override
  State createState() {
    return _LeagueOrTournamentDetailsState();
  }
}

class _LeagueOrTournamentDetailsState extends State<LeagueOrTournamentDetails> {
  String _openedPanel;

  Widget _buildSeason(LeagueOrTournamentSeason season, bool admin,
      SingleLeagueOrTournamentBloc leagueBloc) {
    // Show all the divisions and details.
    return SingleLeagueOrTournamentSeasonProvider(
      leagueSeasonUid: season.uid,
      builder: (context, seasonBloc) => BlocBuilder(
        cubit: seasonBloc,
        builder: (context, seasonState) {
          if (!seasonState.loadedDivisons) {
            seasonBloc.add(SingleLeagueOrTournamentSeasonLoadDivisions());
            return Text(Messages.of(context).loading);
          }

          if (seasonState.divisons.length == 0) {
            if (admin) {
              return Container(
                margin: EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(Messages.of(context).nodivisons),
                    Align(
                      alignment: Alignment.topLeft,
                      child: FlatButton(
                        onPressed: () => _addDivison(seasonBloc),
                        child: Text(Messages.of(context).addDivison,
                            style: Theme.of(context).textTheme.button.copyWith(
                                color: Theme.of(context).accentColor)),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                margin: EdgeInsets.all(5.0),
                child: Text(Messages.of(context).nodivisons),
              );
            }
          }

          var sortedDivisons = seasonState.divisons.values.toList();
          sortedDivisons.sort(
              (LeagueOrTournamentDivison d1, LeagueOrTournamentDivison d2) =>
                  d1.name.compareTo(d2.name));
          var children = sortedDivisons.map<Widget>(
            (divison) {
              return ListTile(
                onTap: () => Navigator.pushNamed(context,
                    '/League/Divison/${widget.leagueOrTournamentUid}/${season.uid}/${divison.uid}'),
                leading: Icon(MdiIcons.accountGroup),
                title: Text(divison.name),
              );
            },
          ).toList();

          if (admin) {
            children.add(SizedBox(height: 10.0));
            children.add(
              FlatButton(
                onPressed: () => _addDivison(seasonBloc),
                child: Text(
                  Messages.of(context).addDivison,
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Theme.of(context).accentColor),
                ),
              ),
            );
          }

          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children);
        },
      ),
    );
  }

  void _addSeason(SingleLeagueOrTournamentBloc tournmentBloc) {
    AddSeasonDialog.showSeasonDialog(context, tournmentBloc);
  }

  void _addDivison(SingleLeagueOrTournamentSeasonBloc seasonBloc) {
    AddDivisonDialog.showSeasonDialog(context, seasonBloc);
  }

  Widget _buildSeasonData(SingleLeagueOrTournamentBloc leagueOrTournamentBloc,
      SingleLeagueOrTournamentState state) {
    if (!state.loadedSeasons) {
      return Text(Messages.of(context).loading);
    }

    if (state.seasons == 0) {
      if (state.league.isAdmin()) {
        return TextButton(
            onPressed: () => _addSeason(leagueOrTournamentBloc),
            child: Text(Messages.of(context).addSeasonButton,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Theme.of(context).accentColor)));
      } else {
        return Container(
          margin: EdgeInsets.all(5.0),
          child: Text(Messages.of(context).noseasons),
        );
      }
    }
    var seasonSorted = state.seasons.values.toList();
    seasonSorted.sort((c1, c2) {
      if (c1.uid == state.league.currentSeason) {
        return -200000;
      }
      return c1.name.compareTo(c2.name);
    });
    var expansionList = ExpansionPanelList.radio(
      initialOpenPanelValue: state.league.currentSeason ?? seasonSorted[0],
      expansionCallback: (pos, opened) {
        if (!opened) {
          _openedPanel = seasonSorted[pos].uid;
          setState(() {});
        }
      },
      children: seasonSorted.map(
        (season) {
          return ExpansionPanelRadio(
            body: _buildSeason(
                season, state.league.isAdmin(), leagueOrTournamentBloc),
            value: season.uid,
            headerBuilder: (context, expanded) {
              return Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  season.name,
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ).toList(),
    );
    if (state.league.isAdmin()) {
      return Column(
        children: <Widget>[
          ButtonBar(
            children: <Widget>[
              TextButton(
                onPressed: () => _addSeason(leagueOrTournamentBloc),
                child: Text(
                  Messages.of(context).addSeason,
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Theme.of(context).accentColor),
                ),
              ),
            ],
          ),
          expansionList,
        ],
      );
    }
    return expansionList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Show the divisons in the current season.
          SingleLeagueOrTournamentProvider(
            leagueUid: widget.leagueOrTournamentUid,
            builder: (context, leagueBloc) => BlocConsumer(
              cubit: leagueBloc,
              listener: (context, state) {
                if (state is SingleLeagueOrTournamentDeleted) {
                  Navigator.pop(context);
                  return;
                }
              },
              builder: (context, state) {
                if (state is SingleLeagueOrTournamentLoaded &&
                    !state.loadedSeasons) {
                  // Tell it to load the seasons.
                  leagueBloc.add(SingleLeagueOrTournamentLoadSeasons());
                }
                if (state is SingleLeagueOrTournamentDeleted) {
                  return DeletedWidget();
                }
                if (state is SingleLeagueOrTournamentUninitialized) {
                  return LoadingWidget();
                }
                // Show the seasons, making the current season open by default
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 5.0, bottom: 10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10.0),
                            child: LeagueImage(
                              leagueOrTournament: state.league,
                              width: 100.0,
                              height: 100.0,
                            ),
                          ),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Text(state.league.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark)),
                                ),
                                state.league.shortDescription.isEmpty
                                    ? SizedBox(
                                        height: 0.0,
                                      )
                                    : Flexible(
                                        child: Text(
                                            state.league.shortDescription,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                      ),
                                SizedBox(height: 5.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        Messages.of(context)
                                            .sportName(state.league.sport),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                                color: Colors.black54,
                                                fontStyle: FontStyle.italic)),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GenderIcon(state.league.gender,
                                            size: 20.0),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    state.league.longDescription.isEmpty
                        ? SizedBox(height: 0.0)
                        : Container(
                            padding: EdgeInsets.only(
                                left: 15.0, bottom: 5.0, right: 5.0),
                            child: RichText(
                                text: TextSpan(
                                    text: state.league.longDescription,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1))),
                    _buildSeasonData(leagueBloc, state)
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
