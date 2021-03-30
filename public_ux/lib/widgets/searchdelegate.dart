import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:built_collection/built_collection.dart';

import '../services/algolia.dart';
import '../services/messagespublic.dart';
import 'searchresult.dart';

///
/// The search delegate to use for showing the results of the search
/// for the teamsfuse app.
///
class TeamsFuseSearchDelegate extends SearchDelegate<String> {
  _SearchResultCubit _cubit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
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
    _cubit ??=
        _SearchResultCubit(RepositoryProvider.of<AlgoliaSearch>(context));
    _cubit.doQuery(query, doNow: true);
    print('build results');
    return BlocBuilder(
      bloc: _cubit,
      builder: (context, data) {
        return AnimatedSwitcher(
          duration: Duration(
            milliseconds: 500,
          ),
          child: _buildResults(context, data),
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, _SearchResultState data) {
    Widget extra;
    if (data.loading) {
      extra = SizedBox(
        height: 20,
        width: 20,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      extra = SizedBox(height: 0);
    }
    if (data.results.isEmpty) {
      if (data.loading) {
        return Padding(
          key: ValueKey(data),
          padding: EdgeInsets.all(10),
          child: Text(
            Messages.of(context).loading,
            style: Theme.of(context).textTheme.headline6,
          ),
        );
      } else {
        return Padding(
          key: ValueKey(data),
          padding: EdgeInsets.all(10),
          child: Text(
            MessagesPublic.of(context).noResults,
            style: Theme.of(context).textTheme.headline6,
          ),
        );
      }
    }
    return Padding(
      key: ValueKey(data),
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          ...data.results
              .map<Widget>((r) => SearchResult(
                  result: r,
                  onTapped: (s) {
                    close(context, s);
                  }))
              .toList(),
          extra,
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _cubit ??=
        _SearchResultCubit(RepositoryProvider.of<AlgoliaSearch>(context));
    _cubit.doQuery(query);
    return BlocBuilder(
        bloc: _cubit,
        builder: (context, searchResults) {
          return AnimatedSwitcher(
            duration: Duration(
              milliseconds: 500,
            ),
            child: _buildResults(context, searchResults),
          );
        });
  }
}

class _SearchResultState {
  final bool loading;
  final BuiltList<AlgoliaResult> results;

  _SearchResultState(this.loading, this.results);
}

class _SearchResultCubit extends Cubit<_SearchResultState> {
  _SearchResultCubit(this._search)
      : super(_SearchResultState(true, BuiltList.of(<AlgoliaResult>[])));

  final AlgoliaSearch _search;
  String _lastResult;

  Future<void> doQuery(String query, {bool doNow = false}) async {
    if (query.isEmpty) {
      emit(_SearchResultState(false, BuiltList.of([])));
      return;
    }
    if (query != _lastResult) {
      _lastResult = query;
      emit(_SearchResultState(true, state.results));
      // Wait for a bit.
      if (!doNow) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      // Didn't change.
      if (_lastResult == query) {
        final results = await _search.search(query);
        emit(_SearchResultState(false, results));
      }
    }
  }
}
