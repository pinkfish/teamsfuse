import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleleagueortournamentdivisonprovider.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';
import 'addteamdialog.dart';
import 'leagueortournamentteamcard.dart';

///
/// The details section to display on a page in the app about the
/// divison of the league.
///
class LeagueOrTournamentDivisonTeamDetails extends StatefulWidget {
  LeagueOrTournamentDivisonTeamDetails(
      {@required this.leagueOrTournamentUid,
      @required this.leagueOrTournamentSeasonUid,
      @required this.leagueOrTournamentDivisonUid});

  final String leagueOrTournamentUid;
  final String leagueOrTournamentSeasonUid;
  final String leagueOrTournamentDivisonUid;

  @override
  State createState() {
    return new _LeagueOrTournamentDivisonDetailsState();
  }
}

class _LeagueOrTournamentDivisonDetailsState
    extends State<LeagueOrTournamentDivisonTeamDetails> {
  List<LeagueOrTournamentTeam> _sortedTeams;
  GlobalKey<AnimatedListState> _listState = new GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
  }

  void _addTeam(SingleLeagueOrTournamentDivisonBloc bloc) {
    AddTeamDialog.showTeamDialog(context, bloc);
  }

  int _sortTeams(LeagueOrTournamentTeam t1, LeagueOrTournamentTeam t2) {
    String divisonUid = widget.leagueOrTournamentDivisonUid;
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
    List<LeagueOrTournamentTeam> oldList = _sortedTeams;
    _sortedTeams = newTeams;
    if (oldList == null || _listState.currentState == null) {
      //  Build the new layout.
      return;
    }

    // Re-read the list and see what changed.
    int i = 0;
    int j = 0;
    while (i < _sortedTeams.length && j < oldList.length) {
      if (_sortedTeams[i].uid == oldList[j].uid) {
        i++;
        j++;
      } else {
        int diff = _sortTeams(_sortedTeams[i], oldList[j]);
        if (diff < 0) {
          i++;
          _listState.currentState.insertItem(i);
        } else {
          print("${_listState.currentState}");
          LeagueOrTournamentTeam myTeam = oldList[j];
          _listState.currentState.removeItem(j,
              (BuildContext context, Animation<double> animation) {
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
      builder:
          (BuildContext context, SingleLeagueOrTournamentBloc leagueBloc) =>
              SingleLeagueOrTournamentSeasonProvider(
        leagueSeasonUid: widget.leagueOrTournamentSeasonUid,
        tournmentBloc: leagueBloc,
        builder: (BuildContext context,
                SingleLeagueOrTournamentSeasonBloc seasonBloc) =>
            SingleLeagueOrTournamentDivisonProvider(
          leagueDivisonUid: widget.leagueOrTournamentDivisonUid,
          singleLeagueOrTournamentSeasonBloc: seasonBloc,
          builder: (BuildContext context,
                  SingleLeagueOrTournamentDivisonBloc divisonBloc) =>
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
      builder: (BuildContext congtext, SingleLeagueOrTournamentState state) =>
          BlocBuilder(
        cubit: seasonBloc,
        builder: (BuildContext context,
                SingleLeagueOrTournamentSeasonState seasonState) =>
            BlocBuilder(
          cubit: divisonBloc,
          builder: (BuildContext context,
              SingleLeagueOrTournamentDivisonState divisonState) {
            return Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new ListTile(
                    leading: LeagueImage(
                      leagueOrTournament: state.leagueOrTournament,
                      width: 50.0,
                      height: 50.0,
                    ),
                    title: Text(
                      state.leagueOrTournament.name,
                      style: Theme.of(context).textTheme.headline,
                    ),
                    subtitle: Text(
                      "${seasonState.leagueOrTournamentSeason.name} ${divisonState.divison.name}",
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  BlocBuilder(
                    cubit: divisonBloc,
                    builder: (BuildContext context,
                        SingleLeagueOrTournamentDivisonState state) {
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
                          if (leagueBloc.state.leagueOrTournament.isAdmin()) {
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
                        List<LeagueOrTournamentTeam> sortedTeams =
                            teams.toList();
                        sortedTeams.sort(_sortTeams);
                        _updateTeams(leagueBloc.state.leagueOrTournament,
                            sortedTeams, divisonState.divison);
                        _sortedTeams = sortedTeams;
                        return Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: AnimatedList(
                                key: _listState,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int item,
                                        Animation<double> an) =>
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
