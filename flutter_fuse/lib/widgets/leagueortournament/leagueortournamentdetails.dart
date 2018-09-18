import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'addseasondialog.dart';
import 'adddivisondialog.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';

class LeagueOrTournamentDetails extends StatefulWidget {
  final String leagueOrTournamentUid;

  LeagueOrTournamentDetails(this.leagueOrTournamentUid);

  @override
  State createState() {
    return new _LeagueOrTournamentDetailsState();
  }
}

class _LeagueOrTournamentDetailsState extends State<LeagueOrTournamentDetails> {
  String _openedPanel;

  Widget _buildSeason(LeagueOrTournamentSeason season, bool admin) {
    print('Buidling ${season.uid}');
    if (season.uid == _openedPanel) {
      // Show all the divisions and details.
      return new StreamBuilder(
        stream: season.divisonStream,
        builder: (BuildContext context,
            AsyncSnapshot<Iterable<LeagueOrTournamentDivison>> data) {
          Iterable<LeagueOrTournamentDivison> divisons = season.cacheDivisions;
          if (data.hasData) {
            divisons = data.data;
          }
          if (!data.hasData && divisons == null) {
            return Text(Messages.of(context).loading);
          }

          if (divisons.length == 0) {
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
                        onPressed: () => _addDivison(season.uid),
                        child: Text(Messages.of(context).adddivison,
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

          List<LeagueOrTournamentDivison> sortedDivisons = divisons.toList();
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
                leading: const Icon(CommunityIcons.snowflake),
                title: Text(divison.name),
              );
            },
          ).toList();

          if (admin) {
            children.add(new SizedBox(height: 10.0));
            children.add(
              FlatButton(
                onPressed: () => _addDivison(season.uid),
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

          return new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children);
        },
      );
    }
    return Text("closed");
  }

  void _addSeason() {
    AddSeasonDialog.showSeasonDialog(context, widget.leagueOrTournamentUid);
  }

  void _addDivison(String seasonUid) {
    AddDivisonDialog.showSeasonDialog(context, seasonUid);
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Show the divisons in the current season.
          new FutureBuilder(
            future: UserDatabaseData.instance
                .getLegueOrTournament(widget.leagueOrTournamentUid),
            builder:
                (BuildContext context, AsyncSnapshot<LeagueOrTournament> data) {
              if (!data.hasData) {
                return Text(Messages.of(context).loading);
              }
              // Show the seasons, making the current season open by default
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: LeagueImage(
                      leagueOrTournament: data.data,
                      width: 50.0,
                      height: 50.0,
                    ),
                    title: Text(data.data.name,
                        style: Theme.of(context).textTheme.headline),
                    subtitle: data.data.shortDescription.isEmpty
                        ? null
                        : Text(data.data.shortDescription),
                  ),
                  data.data.longDescription.isEmpty
                      ? SizedBox(height: 0.0)
                      : Container(
                          color: Colors.lightBlue.shade50,
                          child: RichText(
                              text: TextSpan(text: data.data.longDescription))),
                  StreamBuilder(
                    stream: data.data.seasonStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Iterable<LeagueOrTournamentSeason>>
                            seasons) {
                      Iterable<LeagueOrTournamentSeason> currentSeasons =
                          data.data.cacheSeasons;
                      if (seasons.hasData) {
                        currentSeasons = seasons.data;
                      }
                      if (currentSeasons == null) {
                        return Text(Messages.of(context).loading);
                      }
                      if (currentSeasons.length == 0) {
                        if (data.data.isAdmin()) {
                          return FlatButton(
                              onPressed: _addSeason,
                              child: Text(Messages.of(context).addseason,
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                          color:
                                              Theme.of(context).accentColor)));
                        } else {
                          return Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text(Messages.of(context).noseasons),
                          );
                        }
                      }
                      List<LeagueOrTournamentSeason> seasonSorted =
                          currentSeasons.toList();
                      seasonSorted.sort((LeagueOrTournamentSeason c1,
                          LeagueOrTournamentSeason c2) {
                        if (c1.uid == data.data.currentSeason) {
                          return -200000;
                        }
                        return c1.name.compareTo(c2.name);
                      });
                      return ExpansionPanelList.radio(
                        initialOpenPanelValue:
                            data.data.currentSeason ?? seasonSorted[0],
                        expansionCallback: (int pos, bool opened) {
                          print('Opening $pos $opened');
                          if (!opened) {
                            _openedPanel = seasonSorted[pos].uid;
                            setState(() {

                            });
                          }
                        },
                        children: seasonSorted.map(
                          (LeagueOrTournamentSeason season) {
                            return ExpansionPanelRadio(
                              body: _buildSeason(season, data.data.isAdmin()),
                              value: season.uid,
                              headerBuilder:
                                  (BuildContext context, bool expanded) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  margin:
                                      EdgeInsets.only(left: 10.0, right: 10.0),
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
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
