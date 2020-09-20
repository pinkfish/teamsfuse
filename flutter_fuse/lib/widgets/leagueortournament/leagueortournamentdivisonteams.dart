import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleleagueortournamentdivisonprovider.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';
import '../util/leagueimage.dart';
import 'addteamdialog.dart';
import 'leagueortournamentteamcard.dart';

///
/// The details section to display on a page in the app about the
/// divison of the league.
///
class LeagueOrTournamentDivisonTeamDetails extends StatefulWidget {
  /// Constructor.
  LeagueOrTournamentDivisonTeamDetails(
      {@required this.leagueOrTournamentUid,
      @required this.leagueOrTournamentSeasonUid,
      @required this.leagueOrTournamentDivisonUid});

  /// The league or tournament to show the details of.
  final String leagueOrTournamentUid;

  /// The season to show the details of.
  final String leagueOrTournamentSeasonUid;

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
        widget.leagueOrTournamentUid,
        _sortedTeams[index],
        admin: leagueDivison.isAdmin(),
        divison: leagueDivison,
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
                widget.leagueOrTournamentUid,
                myTeam,
                admin: leagueOrTournament.isAdmin(),
                divison: leagueOrTournamentDivison,
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
    assert(widget.leagueOrTournamentSeasonUid != null);
    assert(widget.leagueOrTournamentDivisonUid != null);
    assert(widget.leagueOrTournamentUid != null);
    return SingleLeagueOrTournamentProvider(
      leagueUid: widget.leagueOrTournamentUid,
      builder: (context, leagueBloc) => SingleLeagueOrTournamentSeasonProvider(
        leagueSeasonUid: widget.leagueOrTournamentSeasonUid,
        builder: (context, seasonBloc) =>
            SingleLeagueOrTournamentDivisonProvider(
          leagueDivisonUid: widget.leagueOrTournamentDivisonUid,
          singleLeagueOrTournamentSeasonBloc: seasonBloc,
          builder: (context, divisonBloc) =>
              _buildTeams(context, leagueBloc, seasonBloc, divisonBloc),
        ),
      ),
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
        builder: (context, seasonState) => BlocBuilder(
          cubit: divisonBloc,
          builder: (context, divisonState) {
            return Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ListTile(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
