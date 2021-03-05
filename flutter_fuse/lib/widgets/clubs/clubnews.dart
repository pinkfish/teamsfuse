import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleclubprovider.dart';
import 'clubnewscard.dart';

///
/// Shows the news items for the club.
///
class ClubNewsItems extends StatelessWidget {
  /// Constructor.
  ClubNewsItems(this.clubUid);

  /// The club to show the details for.
  final String clubUid;

  void _onPressed(SingleClubBloc bloc, SingleClubState state) {
    if (state is SingleClubLoaded && state.loadedNewsItems) {
      if (state.extraNewsItems.isEmpty) {
        bloc.add(SingleClubLoadNewsItems(
          startAt:
              state.newsItems.last.timeCreated.add(Duration(milliseconds: 1)),
        ));
      } else {
        // Find the highest one and go from that.
        var maxValue = state.extraNewsItems.keys.reduce(max);
        bloc.add(SingleClubLoadNewsItems(
          startAt: DateTime.fromMillisecondsSinceEpoch(maxValue + 1),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleClubProvider(
        clubUid: clubUid,
        builder: (context, singleClubBloc) => SingleChildScrollView(
          child: BlocBuilder(
            cubit: singleClubBloc,
            builder: (context, clubState) {
              BuiltList<NewsItem> newsItems;
              if (clubState is SingleClubUninitialized) {
                newsItems = null;
              } else {
                if (!clubState.loadedNewsItems) {
                  singleClubBloc.add(SingleClubLoadNewsItems());
                }
                newsItems = clubState.newsItems;
              }

              var clubAdmin = clubState.club.isAdmin();
              var buttons = <Widget>[];
              if (clubAdmin) {
                buttons.add(TextButton(
                  child: Text(
                    Messages.of(context).addNews,
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/Club/News/Add/$clubUid'),
                ));
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (newsItems == null ||
                        newsItems.isEmpty && !clubState.loadedCoaches
                    ? [
                        Text(Messages.of(context).loading,
                            style: Theme.of(context).textTheme.headline4)
                      ]
                    : newsItems.isEmpty
                        ? [
                            Text(Messages.of(context).noNews,
                                style: Theme.of(context).textTheme.headline4),
                            ButtonBar(children: buttons),
                          ]
                        : [
                            ...newsItems.map<Widget>((c) => ExpansionTile(
                                  title: Text(c.subject,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4),
                                  children: [
                                    ClubNewsCard(
                                      clubUid: c.clubUid,
                                      newsItemUid: c.uid,
                                      isAdmin: clubAdmin,
                                    ),
                                  ],
                                )),
                            ButtonBar(
                              children: [
                                ...buttons,
                                TextButton(
                                  child: Text(
                                    Messages.of(context).loadMore,
                                  ),
                                  onPressed: () =>
                                      _onPressed(singleClubBloc, clubState),
                                ),
                              ],
                            ),
                          ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
