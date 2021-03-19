import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleplayerprovider.dart';
import 'package:flutter_fuse/widgets/player/playerimage.dart';
import 'package:flutter_fuse/widgets/util/coloredtabbar.dart';
import 'package:flutter_fuse/widgets/util/responsivewidget.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../services/messagespublic.dart';
import '../widgets/publicplayerdetails.dart';

/// Which of the tabs in the public view are selected.
enum PublicPlayerTab {
  /// The details tab.
  details,

  /// The media tab.
  media,

  /// The stats tab.
  stats,
}

extension PublicPlayerTabExtension on PublicPlayerTab {
  /// Turn the enum into a nice string with a name.
  String get name {
    switch (this) {
      case PublicPlayerTab.details:
        return 'details';
      case PublicPlayerTab.media:
        return 'media';
      case PublicPlayerTab.stats:
        return 'stats';
      default:
        return null;
    }
  }

  /// Get the index of this enum in the enum.
  int get sortIndex {
    switch (this) {
      case PublicPlayerTab.details:
        return 0;
      case PublicPlayerTab.media:
        return 1;
      case PublicPlayerTab.stats:
        return 2;
      default:
        return null;
    }
  }

  /// Find the indexof the string.
  static PublicPlayerTab fromString(String str) {
    var check = str.toLowerCase();
    return PublicPlayerTab.values.firstWhere(
      (v) => v.name == check,
      orElse: () => PublicPlayerTab.details,
    );
  }

  /// Find the indexof the string.
  static PublicPlayerTab fromIndex(int idx) {
    return PublicPlayerTab.values.firstWhere(
      (v) => v.sortIndex == idx,
      orElse: () => PublicPlayerTab.details,
    );
  }
}

///
/// Show all the nice information about the player in a details screen.
///
class PublicPlayerDetailsScreen extends StatelessWidget {
  /// The player uid to get the details for.
  final String playerUid;

  /// The tab to display.
  final PublicPlayerTab tabSelected;

  /// Create the details screen.
  PublicPlayerDetailsScreen(String tab, this.playerUid)
      : tabSelected = PublicPlayerTabExtension.fromString(tab);

  Widget _buildMediumBody(
      BuildContext context, SinglePlayerBloc bloc, PublicPlayerSize size) {
    return DefaultTabController(
      length: 3,
      initialIndex: tabSelected.sortIndex,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: BlocBuilder(
          bloc: bloc,
          builder: (context, singlePlayerState) {
            if (singlePlayerState is SinglePlayerUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (singlePlayerState is SinglePlayerDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _buildStuff(context, bloc, size),
            );
          },
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String newRoute) {
    RepositoryProvider.of<fluro.FluroRouter>(context)
        .navigateTo(context, newRoute, transition: fluro.TransitionType.fadeIn);
  }

  Widget _buildStuff(BuildContext context, SinglePlayerBloc singlePlayerBloc,
      PublicPlayerSize size) {
    switch (tabSelected) {
      case PublicPlayerTab.details:
        return PublicPlayerDetails(singlePlayerBloc, size);
      case PublicPlayerTab.media:
        return SizedBox(height: 0);
      case PublicPlayerTab.stats:
        return SizedBox(height: 0);
    }
    return SizedBox(height: 0);
  }

  AppBar _buildAppBar(BuildContext context, SinglePlayerBloc singlePlayerBloc) {
    return AppBar(
      leading: PlayerImage(playerUid: playerUid),
      title: BlocBuilder(
        bloc: singlePlayerBloc,
        builder: (context, state) {
          if (state is SinglePlayerUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (state is SinglePlayerDeleted) {
            return Text(Messages.of(context).clubDeleted);
          }
          return Text(state.player.name);
        },
      ),
      bottom: ColoredTabBar(
        color: Colors.white,
        tabBar: TabBar(
          labelColor: Colors.black,
          indicatorColor: Colors.green,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.green),
          ),
          tabs: [
            Tab(
                icon: Icon(MdiIcons.basketball),
                text: Messages.of(context).about),
            Tab(
                icon: Icon(Icons.image),
                text: MessagesPublic.of(context).media),
            Tab(icon: Icon(MdiIcons.graph), text: Messages.of(context).stats),
          ],
          onTap: (idx) => _navigateTo(
              context,
              '/Player/'
              '${PublicPlayerTab.values[idx].name}'
              '/$playerUid'),
        ),
      ),
    );
  }

  Widget _buildSmallBody(
      BuildContext context, SinglePlayerBloc singlePlayerBloc) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder(
          bloc: singlePlayerBloc,
          builder: (context, state) {
            if (state is SinglePlayerUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (state is SinglePlayerDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return Text(state.player.name,
                style: Theme.of(context).textTheme.headline4);
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: BlocBuilder(
                  bloc: singlePlayerBloc,
                  builder: (context, state) {
                    if (state is SinglePlayerUninitialized) {
                      return Text(Messages.of(context).loading);
                    }
                    return Column(
                      children: [
                        PlayerImage(playerUid: playerUid, radius: 100),
                        Text(
                          state.player.name,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    );
                  }),
            ),
            ListTile(
              leading: Icon(MdiIcons.basketball),
              title: Text(Messages.of(context).about),
              onTap: () => _navigateTo(
                  context,
                  '/Player/'
                  '${PublicPlayerTab.details.name}'
                  '/$playerUid'),
            ),
            ListTile(
              leading: Icon(MdiIcons.image),
              title: Text(MessagesPublic.of(context).media),
              onTap: () => _navigateTo(
                  context,
                  '/Player/${PublicPlayerTab.media.name}'
                  '/$playerUid'),
            ),
            ListTile(
              leading: Icon(MdiIcons.graph),
              title: Text(Messages.of(context).stats),
              onTap: () => Navigator.popAndPushNamed(
                  context,
                  '/Player/'
                  '${PublicPlayerTab.stats.name}'
                  '/$playerUid'),
            ),
          ],
        ),
      ),
      body: BlocBuilder(
        bloc: singlePlayerBloc,
        builder: (context, singlePlayerState) {
          if (singlePlayerState is SinglePlayerUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (singlePlayerState is SinglePlayerDeleted) {
            return Text(Messages.of(context).clubDeleted);
          }
          return _buildStuff(context, singlePlayerBloc, PublicPlayerSize.small);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SinglePlayerProvider(
      playerUid: playerUid,
      builder: (context, singlePlayerBloc) => Scaffold(
        body: ResponsiveWidget(
          largeScreen: (context) => _buildMediumBody(
              context, singlePlayerBloc, PublicPlayerSize.large),
          mediumScreen: (context) => _buildMediumBody(
              context, singlePlayerBloc, PublicPlayerSize.large),
          smallScreen: (context) => _buildSmallBody(context, singlePlayerBloc),
        ),
      ),
    );
  }
}
