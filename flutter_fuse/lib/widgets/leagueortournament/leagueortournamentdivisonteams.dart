import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentseasonprovider.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleleagueortournamentdivisonprovider.dart';
import 'addteamdialog.dart';
import 'leagueimage.dart';
import 'leagueortournamentteamcard.dart';

///
/// The details section to display on a page in the app about the
/// divison of the league.
///
class LeagueOrTournamentDivisonTeamDetails extends StatefulWidget {
  /// Constructor.
  LeagueOrTournamentDivisonTeamDetails(
      {@required this.leagueOrTournamentDivisonUid});

  /// The division to show the details of.
  final String leagueOrTournamentDivisonUid;

  @override
  State createState() {
    return _LeagueOrTournamentDivisonDetailsState();
  }
}

class _LeagueOrTournamentDivisonDetailsState
    extends State<LeagueOrTournamentDivisonTeamDetails> {
  List<LeagueOrTournamentTeam> _sortedTeams;
  final GlobalKey<AnimatedListState> _listState =
      GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
  }

  void _addTeam(SingleLeagueOrTournamentDivisonBloc bloc) {
    AddTeamDialog.showTeamDialog(context, bloc);
  }

  int _sortTeams(LeagueOrTournamentTeam t1, LeagueOrTournamentTeam t2) {
    var divisonUid = widget.leagueOrTournamentDivisonUid;
    if (!t1.record.containsKey(divisonUid)) {
      if (!t2.record.containsKey(divisonUid)) {
        return t1.name.compareTo(t2.name);
      } else {
        return 1;
      }
    }
    if (!t2.record.containsKey(divisonUid)) {
      return -1;
    }
    if (t1.record[divisonUid].win == t2.record[divisonUid].win) {
      if (t1.record[divisonUid].loss == t2.record[divisonUid].loss) {
        return t1.name.compareTo(t2.name);
      }
      return (t1.record[divisonUid].loss - t2.record[divisonUid].loss).toInt();
    }
    return (t2.record[divisonUid].win - t1.record[divisonUid].win).toInt();
  }

  Widget _buildTeamItem(BuildContext context, int index,
      Animation<double> animation, LeagueOrTournamentDivison leagueDivison) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: LeagueOrTournamentTeamCard(
        _sortedTeams[index],
        admin: leagueDivison.isAdmin(
            RepositoryProvider.of<DatabaseUpdateModel>(context)
                .currentUser
                .uid),
      ),
    );
  }

  void _updateTeams(
      LeagueOrTournament leagueOrTournament,
      List<LeagueOrTournamentTeam> newTeams,
      LeagueOrTournamentDivison leagueOrTournamentDivison) {
    var oldList = _sortedTeams;
    _sortedTeams = newTeams;
    if (oldList == null || _listState.currentState == null) {
      //  Build the layout.
      return;
    }

    // Re-read the list and see what changed.
    var i = 0;
    var j = 0;
    while (i < _sortedTeams.length && j < oldList.length) {
      if (_sortedTeams[i].uid == oldList[j].uid) {
        i++;
        j++;
      } else {
        var diff = _sortTeams(_sortedTeams[i], oldList[j]);
        if (diff < 0) {
          i++;
          _listState.currentState.insertItem(i);
        } else {
          print("${_listState.currentState}");
          var myTeam = oldList[j];
          _listState.currentState.removeItem(j, (context, animation) {
            // Nailed it.
            return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: LeagueOrTournamentTeamCard(
                myTeam,
                admin: leagueOrTournament.isAdmin(),
              ),
            );
          });
          oldList.removeAt(j);
        }
      }
    }
    while (i < _sortedTeams.length) {
      i++;
      _listState.currentState.insertItem(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.
    assert(widget.leagueOrTournamentDivisonUid != null);
    return SingleLeagueOrTournamentDivisonProvider(
      leagueDivisonUid: widget.leagueOrTournamentDivisonUid,
      builder: (context, divisonBloc) => BlocBuilder(
          cubit: divisonBloc,
          builder:
              (context, SingleLeagueOrTournamentDivisonState divisonState) {
            if (divisonState is SingleLeagueOrTournamentDivisonDeleted) {
              return DeletedWidget();
            }
            if (divisonState is SingleLeagueOrTournamentDivisonUninitialized) {
              return LoadingWidget();
            }
            return SingleLeagueOrTournamentProvider(
              leagueUid: divisonState.divison.leagueOrTournamentUid,
              builder: (context, leagueBloc) =>
                  SingleLeagueOrTournamentSeasonProvider(
                leagueSeasonUid:
                    divisonState.divison.leagueOrTournmentSeasonUid,
                builder: (context, seasonBloc) =>
                    _buildTeams(context, leagueBloc, seasonBloc, divisonBloc),
              ),
            );
          }),
    );
  }

  Widget _buildTeams(
      BuildContext context,
      SingleLeagueOrTournamentBloc leagueBloc,
      SingleLeagueOrTournamentSeasonBloc seasonBloc,
      SingleLeagueOrTournamentDivisonBloc divisonBloc) {
    divisonBloc.add(SingleLeagueOrTournamentDivisonLoadTeams());
    return BlocBuilder(
      cubit: leagueBloc,
      builder: (congtext, state) => BlocBuilder(
        cubit: seasonBloc,
        builder: (context, seasonState) => Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.all(5.0),
          child: BlocBuilder(
            cubit: divisonBloc,
            builder: (context, divisonState) {
              Widget inner;
              if (seasonState is SingleLeagueOrTournamentSeasonUninitialized ||
                  divisonState
                      is SingleLeagueOrTournamentDivisonUninitialized) {
                inner = ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text(
                    Messages.of(context).loading,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                );
              } else {
                inner = ListTile(
                  leading: LeagueImage(
                    leagueOrTournament: state.league,
                    width: 50.0,
                    height: 50.0,
                  ),
                  title: Text(
                    state.league.name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  subtitle: Text(
                    "${seasonState.season.name} ${divisonState.divison.name}",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: inner,
                  ),
                  BlocBuilder(
                    cubit: divisonBloc,
                    builder: (context, state) {
                      if (state
                          is SingleLeagueOrTournamentDivisonUninitialized) {
                        return Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(Messages.of(context).loading),
                        );
                      } else {
                        Iterable<LeagueOrTournamentTeam> teams =
                            state.teams.values;
                        if (teams.length == 0) {
                          if (leagueBloc.state.league.isAdmin()) {
                            return Container(
                              margin: EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(Messages.of(context).noteams),
                                  FlatButton(
                                    onPressed: () => _addTeam(divisonBloc),
                                    child: Text(
                                      Messages.of(context).addteam,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .accentColor),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              margin: EdgeInsets.all(5.0),
                              child: Text(Messages.of(context).noteams),
                            );
                          }
                        }
                        var sortedTeams = teams.toList();
                        sortedTeams.sort(_sortTeams);
                        _updateTeams(leagueBloc.state.league, sortedTeams,
                            divisonState.divison);
                        _sortedTeams = sortedTeams;
                        return Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: AnimatedList(
                                key: _listState,
                                shrinkWrap: true,
                                itemBuilder: (context, item, an) =>
                                    _buildTeamItem(context, item, an,
                                        divisonState.divison),
                                initialItemCount: sortedTeams.length,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
