import 'package:bloc/bloc.dart';

import 'asyncstorage.dart';
import 'hydratedcubit.dart';

/// {@template hydrated_bloc}
/// Specialized [Bloc] which handles initializing the [Bloc] state
/// based on the persisted state. This allows state to be persisted
/// across hot restarts as well as complete app restarts.
/// {@endtemplate}
abstract class AsyncHydratedBloc<Event, State> extends Bloc<Event, State>
    with AsyncHydratedMixin {
  AsyncStorage storage;

  /// {@macro hydrated_bloc}
  AsyncHydratedBloc(State state, String boxName, {AsyncStorage asyncStorage})
      : super(state) {
    print("async $boxName");
    storage = asyncStorage ??
        AsyncHydratedStorage("${runtimeType.toString()}.$boxName");
    hydrate();
  }
}
