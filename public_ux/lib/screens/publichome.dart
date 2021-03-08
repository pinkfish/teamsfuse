import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/handsandtrophy.dart';
import 'package:public_ux/services/messagespublic.dart';

import '../services/algolia.dart';
import '../widgets/appleplaystore.dart';
import '../widgets/googleplaystore.dart';
import '../widgets/searchresult.dart';
import 'home/about.dart';
import 'home/league.dart';
import 'home/tournament.dart';

/// Which of the tabs in the public view are selected.
enum PublicMainTab {
  /// The team tab.
  about,

  /// The tournament tab.
  tournament,

  /// The league tab.
  league,
}

///
/// The extension for the enum to add in the name and index pieces.
///
extension PublicMainTabExtension on PublicMainTab {
  /// Turn the enum into a nice string with a name.
  String get name {
    switch (this) {
      case PublicMainTab.about:
        return 'about';
      case PublicMainTab.tournament:
        return 'tournament';
      case PublicMainTab.league:
        return 'league';
      default:
        return null;
    }
  }

  /// Get the index of this enum in the enum.
  int get sortIndex {
    switch (this) {
      case PublicMainTab.about:
        return 0;
      case PublicMainTab.tournament:
        return 1;
      case PublicMainTab.league:
        return 2;
      default:
        return null;
    }
  }

  /// Find the indexof the string.
  static PublicMainTab fromString(String str) {
    var check = str.toLowerCase();
    return PublicMainTab.values.firstWhere(
      (v) => v.name == check,
      orElse: () => PublicMainTab.about,
    );
  }

  /// Find the indexof the string.
  static PublicMainTab fromIndex(int idx) {
    return PublicMainTab.values.firstWhere(
      (v) => v.sortIndex == idx,
      orElse: () => PublicMainTab.about,
    );
  }
}

///
/// Create a nifty display with a search box.
///
class PublicHomeScreen extends StatefulWidget {
  /// Create a new public home screen.
  PublicHomeScreen(String tab)
      : mainTab = PublicMainTabExtension.fromString(tab);

  /// The main tab to display.
  final PublicMainTab mainTab;

  @override
  State<StatefulWidget> createState() {
    return _PublicHomeScreenState();
  }
}

class _PublicHomeScreenState extends State<PublicHomeScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      vsync: this,
      length: PublicMainTab.values.length,
      initialIndex: widget.mainTab.sortIndex,
    );
    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        Navigator.pushNamed(context,
            '/Home/${PublicMainTabExtension.fromIndex(_controller.index).name}');
      }
    });
  }

  void _doSearch(BuildContext context) async {
    final result = await showSearch(
      context: context,
      delegate: _SearchDelegateStuff(),
    );
    if (result != null) {
      await Navigator.pushNamed(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: PublicMainTab.values.length,
      child: Scaffold(
        appBar: AppBar(
          leading: HandsAndTrophy(),
          title: Text(Messages.of(context).title),
          bottom: TabBar(
            controller: _controller,
            tabs: [
              Tab(text: MessagesPublic.of(context).headerAbout),
              Tab(text: MessagesPublic.of(context).headerTournament),
              Tab(text: MessagesPublic.of(context).headerLeague),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.search),
              label: Text(MessagesPublic.of(context).search),
              onPressed: () => _doSearch(context),
              style: TextButton.styleFrom(
                primary: Colors.white,
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [
                  PublicAboutWidget(),
                  PublicTournamentWidget(),
                  PublicLeagueWidget(),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GooglePlayStore(),
                  SizedBox(width: 10),
                  ApplePlayStore(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchDelegateStuff extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final algolia = RepositoryProvider.of<AlgoliaSearch>(context);
    final results = algolia.search(query);
    return FutureBuilder(
      future: results,
      builder: (context, data) {
        Widget inner;
        if (data.hasData) {
          if (data.data.isEmpty) {
            inner = Text(MessagesPublic.of(context).noResults);
          } else {
            inner = ListView(
              children: data.data
                  .map<Widget>((r) => SearchResult(
                      result: r,
                      onTapped: (s) {
                        close(context, s);
                      }))
                  .toList(),
            );
          }
        } else {
          inner = Text(Messages.of(context).loading);
        }
        return AnimatedSwitcher(
          duration: Duration(
            milliseconds: 500,
          ),
          child: inner,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SizedBox(height: 0);
  }
}
