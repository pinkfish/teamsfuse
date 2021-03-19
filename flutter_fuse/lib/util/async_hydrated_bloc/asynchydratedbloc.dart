import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asynchydratedmixin.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'asyncstorage.dart';

/// {@template hydrated_bloc}
/// Specialized [Bloc] which handles initializing the [Bloc] state
/// based on the persisted state. This allows state to be persisted
/// across hot restarts as well as complete app restarts.
/// {@endtemplate}
abstract class AsyncHydratedBloc<Event, State> extends Bloc<Event, State>
    with AsyncHydratedMixin<State> {
  /// Instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  @override
  AsyncStorage storage;

  /// {@macro hydrated_bloc}
  AsyncHydratedBloc(State state, String boxName, {AsyncStorage asyncStorage})
      : super(state) {
    storage = asyncStorage ??
        AsyncHydratedStorage('${runtimeType.toString()}.$boxName');
    hydrate();
  }
}
