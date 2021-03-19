import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singlenewsprovider.dart';

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
  ClubNewsCard(
      {@required this.clubUid,
      @required this.newsItemUid,
      this.isAdmin = false})
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
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headline5.copyWith(color: Colors.white);

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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child:

                            // In order to have the ink splash appear above the image, you
                            // must use Ink.image. This allows the image to be painted as
                            // part of the Material and display ink effects above it. Using
                            // a standard Image will obscure the ink splash.
                            Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/news-banner.png',
                              ),
                              fit: BoxFit.fitHeight,
                              alignment: Alignment.topLeft,
                            ),
                            color: Colors.black,
                          ),
                          height: 100,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 16,
                        right: 16,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            newsState.newsItem.subject,
                            style: titleStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 10,
                    bottom: 10,
                    top: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(newsState.newsItem.body,
                          style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(newsState.newsItem.postedByName,
                            style: Theme.of(context).textTheme.caption),
                      ),
                      isAdmin
                          ? ButtonBar(children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => Navigator.pushNamed(context,
                                    '/Club/News/Edit/$clubUid/$newsItemUid'),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    _deleteItem(context, singleNewsBloc),
                              ),
                            ])
                          : SizedBox(height: 0),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
