import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../clubs/clubimage.dart';
import '../clubs/coachimage.dart';

///
/// Shows the details about the coaches in a specific club.
///
class PublicCoachDetails extends StatelessWidget {
  /// The bloc to use to populate the coaches from.
  final SingleClubBloc bloc;

  /// The constructor.
  PublicCoachDetails(this.bloc);

  Widget _buildCoach(BuildContext context, Coach coach) {
    return Card(
      margin: EdgeInsets.all(5.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            CoachImage(
                coachUid: coach.uid,
                clubUid: coach.clubUid,
                height: 100,
                width: 100),
            Expanded(
              child: Column(
                children: [
                  Text(coach.name,
                      style: Theme.of(context).textTheme.headline5),
                  Text(coach.about,
                      style: Theme.of(context).textTheme.bodyText1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          if (!state.loadedCoaches) {
            bloc.add(SingleClubLoadCoaches());
          }
          if (state is SingleClubUninitialized || !state.loadedCoaches) {
            return Text(Messages.of(context).loading,
              style: Theme.of(context).textTheme.headline4,);
          }
          if (state is SingleClubDeleted) {
            return Text(Messages.of(context).clubDeleted,
              style: Theme.of(context).textTheme.headline4,);
          }
          return Column(
            children: [
              SizedBox(height: 10),
              Row(children: [
                ClubImage(
                  clubUid: state.club.uid,
                  width: 100,
                  height: 100,
                ),
                Text(
                state.club.name,
                style: Theme.of(context).textTheme.headline4,
              ),
              ],),
              SizedBox(height: 10),
              Text(
                Messages.of(context).coaches,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.green),
              ),
              state.coaches.isEmpty
                  ? Text(Messages.of(context).noCoaches,
                      style: Theme.of(context).textTheme.headline4)
                  : SizedBox(height: 0, width: 0),
              ...state.coaches.map<Widget>((c) => _buildCoach(context, c))
            ],
          );
        });
  }
}
