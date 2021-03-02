import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/clubs/clubdetails.dart';
import 'package:flutter_fuse/widgets/clubs/clubteams.dart';
import 'package:flutter_fuse/widgets/blocs/singleclubprovider.dart';

///
/// The screen showing all the details of the club.
///
class PublicClubDetailsScreen extends StatefulWidget {
  /// Constructor.
  PublicClubDetailsScreen(this.clubUid);

  /// Club id to show the details for.
  final String clubUid;

  @override
  _PublicClubDetailsScreenState createState() {
    return _PublicClubDetailsScreenState();
  }
}

class _PublicClubDetailsScreenState extends State<PublicClubDetailsScreen> {
  bool isWideScreen = true;

  Widget _buildBody(
      Club club, SingleClubBloc singleClubBloc, BoxConstraints layout) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: Messages.of(context).about),
              Tab(icon: Icon(Icons.people), text: Messages.of(context).teams),
              Tab(icon: Icon(Icons.people), text: Messages.of(context).coaches),
            ],
          ),
          TabBarView(
            children: [
              ClubDetails(club),
              ClubTeams(club.uid,
                  onlyPublic: true,
                  onTap: (t) =>
                      Navigator.pushNamed(context, "/Public/Team/" + t.uid)),
              Text("Frogger froggerson")
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: widget.clubUid,
      builder: (context, singleClubBloc) => BlocConsumer(
        cubit: singleClubBloc,
        listener: (context, state) {
          if (state is SingleClubDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          Widget theBody;
          if (state is SingleClubDeleted) {
            theBody = Center(
              child: Text(Messages.of(context).clubDeleted,
                  style: Theme.of(context).textTheme.headline3),
            );
          } else if (state is SingleClubUninitialized) {
            theBody = Center(
              child: LoadingWidget(),
            );
          } else {
            theBody = LayoutBuilder(
              builder: (context, layout) =>
                  _buildBody(state.club, singleClubBloc, layout),
            );
          }

          return Scaffold(
            body: theBody,
          );
        },
      ),
    );
  }
}
