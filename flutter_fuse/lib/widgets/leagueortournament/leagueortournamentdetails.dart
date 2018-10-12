import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'addseasondialog.dart';
import 'adddivisondialog.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:flutter_fuse/widgets/util/gendericon.dart';

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

  Widget _buildSeason(
      LeagueOrTournamentSeason season, bool admin, LeagueOrTournament league) {
    if (season.uid == _openedPanel || season.uid == league.currentSeason) {
      // Show all the divisions and details.
      return new StreamBuilder<Iterable<LeagueOrTournamentDivison>>(
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
                leading: const Icon(CommunityIcons.accountGroup),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Show the divisons in the current season.
          new FutureBuilder<LeagueOrTournament>(
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
                            leagueOrTournament: data.data,
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
                                child: Text(data.data.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark)),
                              ),
                              data.data.shortDescription.isEmpty
                                  ? SizedBox(
                                      height: 0.0,
                                    )
                                  : Flexible(
                                      child: Text(data.data.shortDescription,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(
                                                  fontWeight: FontWeight.w500)),
                                    ),
                              SizedBox(height: 5.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      Messages.of(context)
                                          .sportname(data.data.sport),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                              color: Colors.black54,
                                              fontStyle: FontStyle.italic)),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: GenderIcon(data.data.gender,
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
                  data.data.longDescription.isEmpty
                      ? SizedBox(height: 0.0)
                      : Container(
                          padding: EdgeInsets.only(
                              left: 15.0, bottom: 5.0, right: 5.0),
                          child: RichText(
                              text: TextSpan(
                                  text: data.data.longDescription,
                                  style: Theme.of(context).textTheme.subhead))),
                  StreamBuilder<Iterable<LeagueOrTournamentSeason>>(
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
                      Widget expansionList = ExpansionPanelList.radio(
                        initialOpenPanelValue:
                            data.data.currentSeason ?? seasonSorted[0],
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
                                  season, data.data.isAdmin(), data.data),
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
                      if (data.data.isAdmin()) {
                        return Column(
                          children: <Widget>[
                            ButtonBar(
                              children: <Widget>[
                                FlatButton(
                                  onPressed: _addSeason,
                                  child: Text(
                                    Messages.of(context).addseason,
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(
                                            color:
                                                Theme.of(context).accentColor),
                                  ),
                                ),
                              ],
                            ),
                            expansionList,
                          ],
                        );
                      }
                      return expansionList;
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
