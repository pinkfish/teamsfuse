import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
/// Single builder for the club system and happiness.
///
typedef SingleClubCoachProviderBuilder = Widget Function(
    BuildContext context, SingleClubCoachBloc singleClubCoachBloc);

///
/// Create a provider that will insert the singe club bloc into the tree if the
/// bloc is not current provided or is different than the clubuid.
///
class SingleClubCoachProvider extends SingleBlocProvider<SingleClubCoachBloc> {
  /// Constructor.
  SingleClubCoachProvider(
      {@required String clubUid,
      @required String coachUid,
      SingleClubCoachProviderBuilder builder})
      : super(
            keyUid: "$clubUid.$coachUid",
            creator: (c, uid) => _createBloc(c, clubUid, coachUid),
            builder: builder,
            prefix: "club");

  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleClubBloc && bloc.clubUid == keyUid);
  }

  static SingleClubCoachBloc _createBloc(
      BuildContext context, String uid, String coachUid) {
    return SingleClubCoachBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      clubUid: uid,
      coachUid: coachUid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }
}
