import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/clubs/coachimage.dart';

import '../screens/publicclubhome.dart';
import '../services/messagespublic.dart';

///
/// Shows the details about the coaches in a specific club.
///
class PublicCoachDetails extends StatelessWidget {
  /// The bloc to use to populate the coaches from.
  final SingleClubBloc bloc;

  /// If we should display this as if it is small.
  final bool smallDisplay;

  /// The constructor.
  PublicCoachDetails(this.bloc, {this.smallDisplay = false});

  Widget _buildCoach(BuildContext context, Coach coach) {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0, bottom: 20),
      child: Card(
        margin: EdgeInsets.all(5.0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              CoachImage(
                  coachUid: coach.uid,
                  clubUid: coach.clubUid,
                  height: 200,
                  width: 200),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coach.name,
                        style: Theme.of(context).textTheme.headline5),
                    SizedBox(height: 15),
                    Text(coach.about,
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          if (!state.loadedCoaches) {
            bloc.add(SingleClubLoadCoaches());
          }
          if (state is SingleClubUninitialized || !state.loadedCoaches) {
            return Text(
              Messages.of(context).loading,
              style: Theme.of(context).textTheme.headline4,
            );
          }
          if (state is SingleClubDeleted) {
            return Text(
              Messages.of(context).clubDeleted,
              style: Theme.of(context).textTheme.headline4,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                Messages.of(context).coaches,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.green),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      state.coaches.isEmpty
                          ? Text(Messages.of(context).noCoaches,
                              style: Theme.of(context).textTheme.headline4)
                          : SizedBox(height: 0, width: 0),
                      ...state.coaches
                          .map<Widget>((c) => _buildCoach(context, c)),
                    ],
                  ),
                ),
              ),
              smallDisplay
                  ? ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context,
                              '/Club/'
                              '${PublicClubTab.club.name}'
                              '/${state.club.uid}'),
                          child: Text(
                            MessagesPublic.of(context).aboutButton,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context,
                              '/Club/'
                              '${PublicClubTab.team.name}'
                              '/${state.club.uid}'),
                          child: Text(
                            MessagesPublic.of(context).teamsButton,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context,
                              '/Club/'
                              '${PublicClubTab.news.name}'
                              '/${state.club.uid}'),
                          child: Text(
                            MessagesPublic.of(context).newsButton,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(height: 0),
            ],
          );
        });
  }
}
