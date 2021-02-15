import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singlenewsprovider.dart';
import '../util/byusername.dart';
import '../util/userimage.dart';

///
/// Card with the club news stuff in it.
///
class ClubNewsCard extends StatelessWidget {
  /// The club uid to get the news for.
  final String clubUid;
  /// The news item uid to get the news for/
  final String newsItemUid;

  /// Creates a nice card to display the news item.
  ClubNewsCard({this.clubUid, this.newsItemUid})
      : assert(clubUid != null && newsItemUid != null);

  Widget build(BuildContext context) {
    return SingleNewsItemProvider(
      clubUid: clubUid,
      newsItemUid: newsItemUid,
      builder: (context, singleNewsBloc) => Card(
        child: BlocBuilder(
          cubit: singleNewsBloc,
          builder: (context, newsState) {
            if (newsState is SingleNewsItemUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (newsState is SingleNewsItemDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return Column(
              children: [
                Row(
                  children: [
                    UserImage(newsState.newsItem.postedByUid),
                    ByUserNameComponent(userId: newsState.newsItem.postedByUid),
                    SizedBox(width: 20),
                  ],
                ),
                Text(newsState.newsItem.subject,
                    style: Theme.of(context).textTheme.headline6),
                Text(newsState.newsItem.body,
                    style: Theme.of(context).textTheme.bodyText1),
              ],
            );
          },
        ),
      ),
    );
  }
}
