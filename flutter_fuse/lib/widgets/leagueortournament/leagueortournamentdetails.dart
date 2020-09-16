import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/gendericon.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleleagueortournamentprovider.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';
import 'adddivisondialog.dart';
import 'addseasondialog.dart';

class LeagueOrTournamentDetails extends StatefulWidget {
  LeagueOrTournamentDetails(this.leagueOrTournamentUid);

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
    if (season.uid == _openedPanel || season.uid == leagueBloc.state.league) {
      // Show all the divisions and details.
      return SingleLeagueOrTournamentSeasonProvider(
        leagueSeasonUid: season.uid,
        builder: (BuildContext context,
                SingleLeagueOrTournamentSeasonBloc seasonBloc) =>
            BlocBuilder(
          cubit: seasonBloc,
          builder: (BuildContext context,
              SingleLeagueOrTournamentSeasonState seasonState) {
            if (!seasonState.loadedDivisons) {
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
                          child: Text(Messages.of(context).adddivison,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
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

            List<LeagueOrTournamentDivison> sortedDivisons =
                seasonState.divisons.values.toList();
            sortedDivisons.sort(
                (LeagueOrTournamentDivison d1, LeagueOrTournamentDivison d2) =>
                    d1.name.compareTo(d2.name));
            List<Widget> children = sortedDivisons.map<Widget>(
              (LeagueOrTournamentDivison divison) {
                return ListTile(
                  onTap: () => Navigator.pushNamed(
                      context,
                      "/League/Divison/" +
                          widget.leagueOrTournamentUid +
                          "/" +
                          season.uid +
                          "/" +
                          divison.uid),
                  leading: const Icon(CommunityIcons.accountGroup),
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
                    Messages.of(context).adddivison,
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
    return Text("closed");
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
        return FlatButton(
            onPressed: () => _addSeason(leagueOrTournamentBloc),
            child: Text(Messages.of(context).addseason,
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
    List<LeagueOrTournamentSeason> seasonSorted = state.seasons.values.toList();
    seasonSorted
        .sort((LeagueOrTournamentSeason c1, LeagueOrTournamentSeason c2) {
      if (c1.uid == state.league.currentSeason) {
        return -200000;
      }
      return c1.name.compareTo(c2.name);
    });
    Widget expansionList = ExpansionPanelList.radio(
      initialOpenPanelValue: state.league.currentSeason ?? seasonSorted[0],
      expansionCallback: (int pos, bool opened) {
        print('Opening $pos $opened');
        if (!opened) {
          _openedPanel = seasonSorted[pos].uid;
          setState(() {});
        }
      },
      children: seasonSorted.map(
        (LeagueOrTournamentSeason season) {
          return ExpansionPanelRadio(
            body: _buildSeason(
                season, state.league.isAdmin(), leagueOrTournamentBloc),
            value: season.uid,
            headerBuilder: (BuildContext context, bool expanded) {
              return Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  season.name,
                  style: Theme.of(context).textTheme.subhead,
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
              FlatButton(
                onPressed: () => _addSeason(leagueOrTournamentBloc),
                child: Text(
                  Messages.of(context).addseason,
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
            builder: (BuildContext context,
                    SingleLeagueOrTournamentBloc leagueBloc) =>
                BlocListener(
              cubit: leagueBloc,
              listener:
                  (BuildContext context, SingleLeagueOrTournamentState state) {
                if (state is SingleLeagueOrTournamentDeleted) {
                  Navigator.pop(context);
                  return;
                }
              },
              child: BlocBuilder(
                cubit: leagueBloc,
                builder: (BuildContext context,
                    SingleLeagueOrTournamentState state) {
                  if (state is SingleLeagueOrTournamentLoaded) {
                    // Tell it to load the seasons.
                    leagueBloc.add(SingleLeagueOrTournamentLoadSeasons());
                  }
                  if (state is SingleLeagueOrTournamentDeleted) {
                    return Text(Messages.of(context).loading);
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
                                            .headline
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
                                                  .subhead
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500)),
                                        ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          Messages.of(context)
                                              .sportname(state.league.sport),
                                          style: Theme.of(context)
                                              .textTheme
                                              .body1
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
                                          .subhead))),
                      _buildSeasonData(leagueBloc, state)
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
