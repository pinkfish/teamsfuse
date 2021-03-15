import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singlenewsprovider.dart';
import '../util/userimage.dart';

///
/// Card with the club news stuff in it.
///
class ClubNewsCard extends StatelessWidget {
  /// The club uid to get the news for.
  final String clubUid;

  /// The news item uid to get the news for/
  final String newsItemUid;

  /// If the person is a admin for the club.
  final bool isAdmin;

  /// Creates a nice card to display the news item.
  ClubNewsCard({@required this.clubUid, this.newsItemUid, this.isAdmin = false})
      : assert(clubUid != null && newsItemUid != null);

  void _deleteItem(BuildContext context, SingleNewsItemBloc newsItem) async {
    var ret = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Messages.of(context).deleteNewsItem),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Messages.of(context).newsItemToDelete),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Do the delete and then pop
                Navigator.pop(context, true);
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
    if (ret == true) {
      newsItem.add(SingleNewsItemDelete());
    }
  }

  @override
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
                    Text(
                      Messages.of(context)
                          .invitedBy(newsState.newsItem.postedByName),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
                Text(newsState.newsItem.subject,
                    style: Theme.of(context).textTheme.headline6),
                Text(newsState.newsItem.body,
                    style: Theme.of(context).textTheme.bodyText1),
                isAdmin
                    ? ButtonBar(children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => Navigator.pushNamed(
                              context, '/Club/News/Edit/$clubUid/$newsItemUid'),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteItem(context, singleNewsBloc),
                        ),
                      ])
                    : SizedBox(height: 0),
              ],
            );
          },
        ),
      ),
    );
  }
}
