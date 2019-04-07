import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:async';

import 'coordinationbloc.dart';

enum LoadedState { Logout, Loading, SqlLoaded, AllLoaded }

enum LoadedEvent { Start, SQL, ALL, Logout }

///
/// Simple bloc on top fo ther loading state to track the loading state at
/// a less granular level.
///
class LoadedStateBloc extends Bloc<LoadedEvent, LoadedState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _coordSub;

  LoadedStateBloc({@required this.coordinationBloc}) {
    _coordSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(LoadedEvent.Logout);
      } else if (state is CoordinationStateStartLoadingSql) {
        dispatch(LoadedEvent.Start);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        dispatch(LoadedEvent.SQL);
      } else if (state is CoordinationStateLoaded) {
        dispatch(LoadedEvent.ALL);
      }
    });
  }

  @override
  Stream<LoadedState> mapEventToState(LoadedEvent event) async* {
    switch (event) {
      case LoadedEvent.Start:
        yield LoadedState.Loading;
        break;
      case LoadedEvent.SQL:
        yield LoadedState.SqlLoaded;
        break;
      case LoadedEvent.ALL:
        yield LoadedState.AllLoaded;
        break;
      case LoadedEvent.Logout:
        yield LoadedState.Logout;
        break;
    }
  }

  @override
  LoadedState get initialState => LoadedState.Logout;
}
