import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/clubs/clubnewscard.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Shows the news articles for the club.
///
class PublicClubNews extends StatelessWidget {
  /// The bloc to use to populate the coaches from.
  final SingleClubBloc bloc;

  /// The constructor.
  PublicClubNews(this.bloc);

  Widget _buildNewsItem(BuildContext context, NewsItem item) {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0, bottom: 20),
      child: ClubNewsCard(
        clubUid: bloc.clubUid,
        newsItemUid: item.uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        if (!state.loadedNewsItems) {
          bloc.add(SingleClubLoadNewsItems());
        }
        if (state is SingleClubUninitialized || !state.loadedNewsItems) {
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
          children: [
            SizedBox(height: 10),
            Text(
              Messages.of(context).news,
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.green),
            ),
            SizedBox(height: 10),
            state.newsItems.isEmpty
                ? Text(Messages.of(context).noNews,
                    style: Theme.of(context).textTheme.headline4)
                : SizedBox(height: 0, width: 0),
            ...state.newsItems.map<Widget>((c) => _buildNewsItem(context, c))
          ],
        );
      },
    );
  }
}
