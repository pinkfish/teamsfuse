import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';

enum LoadedState { Logout, Loading, AllLoaded }

enum LoadedEvent { Start, ALL, Logout }

///
/// Simple bloc on top fo ther loading state to track the loading state at
/// a less granular level.
///
class LoadedStateBloc extends Bloc<LoadedEvent, LoadedState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _coordSub;

  LoadedStateBloc({@required this.coordinationBloc})
      : super(LoadedState.Logout) {
    _coordSub = coordinationBloc.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        add(LoadedEvent.Logout);
      } else if (state is CoordinationStateLoadingFirestore) {
        add(LoadedEvent.Start);
      } else if (state is CoordinationStateLoaded) {
        add(LoadedEvent.ALL);
      }
    });
  }

  @override
  Future<void> close() {
    _coordSub.cancel();
    return super.close();
  }

  @override
  Stream<LoadedState> mapEventToState(LoadedEvent event) async* {
    switch (event) {
      case LoadedEvent.Start:
        yield LoadedState.Loading;
        break;
      case LoadedEvent.ALL:
        yield LoadedState.AllLoaded;
        break;
      case LoadedEvent.Logout:
        yield LoadedState.Logout;
        break;
    }
  }
}
