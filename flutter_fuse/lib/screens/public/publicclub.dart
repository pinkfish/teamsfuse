import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleclubprovider.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/clubs/clubdetails.dart';
import '../../widgets/clubs/clubteams.dart';

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
    print(layout);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: ClubDetails(club),
        ),
        Expanded(
          child: ClubTeams(club.uid,
              onlyPublic: true,
              onTap: (t) =>
                  Navigator.pushNamed(context, "/Public/Team/" + t.uid)),
        ),
      ],
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
          String title;
          if (state is SingleClubDeleted || state is SingleClubUninitialized) {
            title = Messages.of(context).loading;
          } else {
            title = state.club.name;
          }
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

          // Setup the navigation items.
          var navItems = <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.gamepad),
              label: Messages.of(context).clubdetails,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: Messages.of(context).teams,
            ),
          ];

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: Icon(MdiIcons.cardsClub),
            ),
            body: theBody,
          );
        },
      ),
    );
  }
}
