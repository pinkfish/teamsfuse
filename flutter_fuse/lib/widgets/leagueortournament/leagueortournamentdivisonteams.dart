import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'leagueortournamentteamcard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'addteamdialog.dart';

///
/// The details section to display on a page in the app about the
/// divison of the league.
///
class LeagueOrTournamentDivisonTeamDetails extends StatefulWidget {
  final String leagueOrTournamentUid;
  final String leagueOrTournamentSeasonUid;
  final String leagueOrTournamentDivisonUid;

  LeagueOrTournamentDivisonTeamDetails(
      {@required this.leagueOrTournamentUid,
      @required this.leagueOrTournamentSeasonUid,
      @required this.leagueOrTournamentDivisonUid});

  @override
  State createState() {
    return new _LeagueOrTournamentDivisonDetailsState();
  }
}

class _LeagueOrTournamentDivisonDetailsState
    extends State<LeagueOrTournamentDivisonTeamDetails> {
  LeagueOrTournament _leagueOrTournament;
  LeagueOrTournamentSeason _leagueOrTournmentSeason;
  LeagueOrTournamentDivison _leagueOrTournmentDivison;
  List<LeagueOrTournamentTeam> _sortedTeams;
  GlobalKey<AnimatedListState> _listState = new GlobalKey<AnimatedListState>();

  void initState() {
    super.initState();
    _leagueOrTournament = UserDatabaseData
        .instance.leagueOrTournments[widget.leagueOrTournamentUid];
    _leagueOrTournmentSeason = _leagueOrTournament.cacheSeasons.firstWhere(
        (LeagueOrTournamentSeason s) =>
            s.uid == widget.leagueOrTournamentSeasonUid);
    _leagueOrTournmentDivison = _leagueOrTournmentSeason.cacheDivisions
        .firstWhere((LeagueOrTournamentDivison s) =>
            s.uid == widget.leagueOrTournamentDivisonUid);
  }

  void dispose() {
    super.dispose();
  }

  void _addTeam() {
    AddTeamDialog.showTeamDialog(context, widget.leagueOrTournamentDivisonUid);
  }

  int _sortTeams(LeagueOrTournamentTeam t1, LeagueOrTournamentTeam t2) {
    if (!t1.record.containsKey(_leagueOrTournmentDivison.uid)) {
      if (!t2.record.containsKey(_leagueOrTournmentDivison.uid)) {
        return t1.name.compareTo(t2.name);
      } else {
        return 1;
      }
    }
    if (!t2.record.containsKey(_leagueOrTournmentDivison.uid)) {
      return -1;
    }
    if (t1.record[_leagueOrTournmentDivison.uid].win ==
        t2.record[_leagueOrTournmentDivison.uid].win) {
      if (t1.record[_leagueOrTournmentDivison.uid].loss ==
          t2.record[_leagueOrTournmentDivison.uid].loss) {
        return t1.name.compareTo(t2.name);
      }
      return (t1.record[_leagueOrTournmentDivison.uid].loss -
              t2.record[_leagueOrTournmentDivison.uid].loss)
          .toInt();
    }
    return (t2.record[_leagueOrTournmentDivison.uid].win -
            t1.record[_leagueOrTournmentDivison.uid].win)
        .toInt();
  }

  Widget _buildTeamItem(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: LeagueOrTournamentTeamCard(
        _leagueOrTournament.uid,
        _sortedTeams[index],
        admin: _leagueOrTournament.isAdmin(),
        divison: _leagueOrTournmentDivison,
      ),
    );
  }

  void _updateTeams(List<LeagueOrTournamentTeam> newTeams) {
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
                _leagueOrTournament.uid,
                myTeam,
                admin: _leagueOrTournament.isAdmin(),
                divison: _leagueOrTournmentDivison,
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

  Widget build(BuildContext context) {
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.
    assert(_leagueOrTournmentSeason != null);
    assert(_leagueOrTournmentDivison != null);
    assert(_leagueOrTournament != null);

    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            leading: LeagueImage(
              leagueOrTournament: _leagueOrTournament,
              width: 50.0,
              height: 50.0,
            ),
            title: Text(
              _leagueOrTournament.name,
              style: Theme.of(context).textTheme.headline,
            ),
            subtitle: Text(
              "${_leagueOrTournmentSeason.name} ${_leagueOrTournmentDivison.name}",
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          StreamBuilder(
              stream: _leagueOrTournmentDivison.teamStream,
              builder: (BuildContext context,
                  AsyncSnapshot<Iterable<LeagueOrTournamentTeam>> snap) {
                Iterable<LeagueOrTournamentTeam> teams =
                    _leagueOrTournmentDivison.cachedTeams;
                if (snap.hasData) {
                  teams = snap.data;
                }
                if (teams == null) {
                  return Container(
                    margin: EdgeInsets.all(5.0),
                    child: Text(Messages.of(context).loading),
                  );
                }
                if (teams.length == 0) {
                  if (_leagueOrTournament.isAdmin()) {
                    return Container(
                      margin: EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(Messages.of(context).noteams),
                          FlatButton(
                            onPressed: () => _addTeam(),
                            child: Text(
                              Messages.of(context).addteam,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context).accentColor),
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
                List<LeagueOrTournamentTeam> sortedTeams = teams.toList();
                sortedTeams.sort(_sortTeams);
                _updateTeams(sortedTeams);
                _sortedTeams = sortedTeams;
                return Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: AnimatedList(
                        key: _listState,
                        shrinkWrap: true,
                        itemBuilder: _buildTeamItem,
                        initialItemCount: sortedTeams.length,
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
