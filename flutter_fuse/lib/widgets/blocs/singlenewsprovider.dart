import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/analytics.dart';
import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
/// Single builder for the club system and happiness.
///
typedef SingleClubNewsProviderBuilder = Widget Function(
    BuildContext context, SingleNewsItemBloc singleClubNewsBloc);

///
/// Create a provider that will insert the singe club bloc into the tree if the
/// bloc is not current provided or is different than the clubuid.
///
class SingleNewsItemProvider extends SingleBlocProvider<SingleNewsItemBloc> {
  /// Constructor.
  SingleNewsItemProvider(
      {@required String clubUid,
      @required String newsItemUid,
      SingleClubNewsProviderBuilder builder})
      : super(
            keyUid: '$clubUid.$newsItemUid',
            creator: (c, uid) => _createBloc(c, clubUid, newsItemUid),
            builder: builder,
            prefix: 'club');

  @override
  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleClubBloc && bloc.clubUid == keyUid);
  }

  static SingleNewsItemBloc _createBloc(
      BuildContext context, String uid, String newsUid) {
    return SingleNewsItemBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      clubUid: uid,
      newsItemUid: newsUid,
      crashes: RepositoryProvider.of<AnalyticsSubsystemImpl>(context),
    );
  }
}
