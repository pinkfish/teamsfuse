import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import 'teamplayerseason.dart';

///
/// Show the players of the team.
///
class TeamPlayers extends StatefulWidget {
  /// Constructor taking the team to find the players of
  TeamPlayers(this._teamUid);

  final String _teamUid;

  @override
  _TeamPlayersState createState() {
    return _TeamPlayersState();
  }
}

class _TeamPlayersState extends State<TeamPlayers> {
  String _seasonUid;

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState teamState) {
    var ret = <DropdownMenuItem<String>>[];
    var seasons = teamState.fullSeason.toList();
    seasons.sort((s1, s2) => s1.name.compareTo(s2.name));
    for (var s in seasons) {
      ret.add(DropdownMenuItem<String>(child: Text(s.name), value: s.uid));
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var messsages = Messages.of(context);

    return SingleTeamProvider(
      teamUid: widget._teamUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, teamState) {
          if (teamState is SingleTeamDeleted ||
              teamState is SingleTeamUninitialized) {
            return CircularProgressIndicator();
          } else {
            if (_seasonUid == null) {
              _seasonUid = teamState.team.currentSeason;
            }
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    DropdownButton<String>(
                      hint: Text(messsages.seasonselect),
                      value: _seasonUid,
                      items: _buildItems(context, teamState),
                      onChanged: (val) {
                        print('changed $val');
                        setState(() {
                          _seasonUid = val;
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: TeamPlayersSeason(widget._teamUid, _seasonUid),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
