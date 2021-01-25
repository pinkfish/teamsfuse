import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'asyncstorage.dart';

/// {@template hydrated_cubit}
/// Specialized [Cubit] which handles initializing the [Cubit] state
/// based on the persisted state. This allows state to be persisted
/// across application restarts.
///
/// ```dart
/// class CounterCubit extends HydratedCubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
///   void decrement() => emit(state - 1);
///
///   @override
///   int fromJson(Map<String, dynamic> json) => json['value'] as int;
///
///   @override
///   Map<String, int> toJson(int state) => {'value': state};
/// }
/// ```
///
/// {@endtemplate}
abstract class AsyncHydratedCubit<State> extends Cubit<State>
    with HydratedMixin<State> {
  AsyncStorage storage;

  /// {@macro hydrated_cubit}
  AsyncHydratedCubit(State state, String boxName, {AsyncStorage asyncStorage})
      : super(state) {
    storage = asyncStorage ??
        AsyncHydratedStorage("${runtimeType.toString()}$boxName");
    hydrate();
  }
}

/// A mixin which enables automatic state persistence
/// for [Bloc] and [Cubit] classes.
///
/// The [hydrate] method must be invoked in the constructor body
/// when using the [HydratedMixin] directly.
///
/// If a mixin is not necessary, it is recommended to
/// extend [AsyncHydratedBloc] and [AsyncHydratedCubit] respectively.
///
/// ```dart
/// class CounterBloc extends Bloc<CounterEvent, int> with HydratedMixin {
///  CounterBloc() : super(0) {
///    hydrate();
///  }
///  ...
/// }
/// ```
///
/// See also:
///
/// * [AsyncHydratedCubit] to enable automatic state persistence/restoration with [Cubit]
/// * [AsyncHydratedBloc] to enable automatic state persistence/restoration with [Bloc]
///
mixin AsyncHydratedMixin<State> on Cubit<State> {
  /// Instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  AsyncStorage storage;
  bool _loadedData = false;
  final Completer<bool> _loadedDataCompletor = Completer();
  Future<bool> get loadedData {
    return _loadedDataCompletor.future;
  }

  Future<void> hydrate() async {
    if (storage == null) throw const StorageNotFound();
    try {
      final stateJson =
          (await storage.read(storageToken)) as Map<dynamic, dynamic>;
      if (stateJson == null) {
        return;
      }
      // Cause a state change.
      if (!_loadedData) {
        _loadedData = true;
        emit(_fromJson(stateJson));
        if (!_loadedDataCompletor.isCompleted) {
          _loadedDataCompletor.complete(true);
        }
      }
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  State _state;

  @override
  State get state {
    if (storage == null) throw const StorageNotFound();
    if (_state != null) return _state;
    return super.state;
  }

  @override
  void onChange(Change<State> change) {
    if (storage == null) throw const StorageNotFound();
    final state = change.nextState;
    try {
      // Any state change we mark ourselves as loaded.
      _loadedData = true;
      final stateJson = _toJson(state);
      if (stateJson != null) {
        storage.write(storageToken, stateJson).then((_) {}, onError: onError);
      }
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
    }
    _state = state;
    super.onChange(change);
    if (!_loadedDataCompletor.isCompleted) {
      _loadedDataCompletor.complete(true);
    }
  }

  State _fromJson(dynamic json) {
    return fromJson(_cast<Map<String, dynamic>>(_traverseRead(json)));
  }

  Map<String, dynamic> _toJson(State state) {
    return _cast<Map<String, dynamic>>(_traverseWrite(toJson(state)).value);
  }

  dynamic _traverseRead(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>((dynamic key, dynamic value) {
        return MapEntry<String, dynamic>(
          _cast<String>(key),
          _traverseRead(value),
        );
      });
    }
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        value[i] = _traverseRead(value[i]);
      }
    }
    return value;
  }

  T _cast<T>(dynamic x) => x is T ? x : null;

  _Traversed _traverseWrite(dynamic value) {
    final dynamic traversedAtomicJson = _traverseAtomicJson(value);
    if (traversedAtomicJson is! NIL) {
      return _Traversed.atomic(traversedAtomicJson);
    }
    final dynamic traversedComplexJson = _traverseComplexJson(value);
    if (traversedComplexJson is! NIL) {
      return _Traversed.complex(traversedComplexJson);
    }
    try {
      _checkCycle(value);
      final dynamic customJson = _toEncodable(value);
      final dynamic traversedCustomJson = _traverseJson(customJson);
      if (traversedCustomJson is NIL) {
        throw HydratedUnsupportedError(value);
      }
      _removeSeen(value);
      return _Traversed.complex(traversedCustomJson);
    } on HydratedCyclicError catch (e) {
      throw HydratedUnsupportedError(value, cause: e);
    } on HydratedUnsupportedError {
      rethrow; // do not stack `HydratedUnsupportedError`
    } on dynamic catch (e) {
      throw HydratedUnsupportedError(value, cause: e);
    }
  }

  dynamic _traverseAtomicJson(dynamic object) {
    if (object is num) {
      if (!object.isFinite) return const NIL();
      return object;
    } else if (identical(object, true)) {
      return true;
    } else if (identical(object, false)) {
      return false;
    } else if (object == null) {
      return null;
    } else if (object is String) {
      return object;
    }
    return const NIL();
  }

  dynamic _traverseComplexJson(dynamic object) {
    if (object is List) {
      if (object.isEmpty) return object;
      _checkCycle(object);
      List<dynamic> list;
      for (var i = 0; i < object.length; i++) {
        final traversed = _traverseWrite(object[i]);
        list ??= traversed.outcome == _Outcome.atomic
            ? object.sublist(0)
            : (<dynamic>[]..length = object.length);
        list[i] = traversed.value;
      }
      _removeSeen(object);
      return list;
    } else if (object is Map) {
      _checkCycle(object);
      final map = <String, dynamic>{};
      object.forEach((dynamic key, dynamic value) {
        map[_cast<String>(key)] = _traverseWrite(value).value;
      });
      _removeSeen(object);
      return map;
    }
    return const NIL();
  }

  dynamic _traverseJson(dynamic object) {
    final dynamic traversedAtomicJson = _traverseAtomicJson(object);
    return traversedAtomicJson is! NIL
        ? traversedAtomicJson
        : _traverseComplexJson(object);
  }

  dynamic _toEncodable(dynamic object) => object.toJson();

  final List _seen = <dynamic>[];

  void _checkCycle(dynamic object) {
    for (var i = 0; i < _seen.length; i++) {
      if (identical(object, _seen[i])) {
        throw HydratedCyclicError(object);
      }
    }
    _seen.add(object);
  }

  void _removeSeen(dynamic object) {
    assert(_seen.isNotEmpty);
    assert(identical(_seen.last, object));
    _seen.removeLast();
  }

  /// `storageToken` is used as registration token for hydrated storage.
  @nonVirtual
  String get storageToken => '${runtimeType.toString()}}';

  /// `clear` is used to wipe or invalidate the cache of a `HydratedCubit`.
  /// Calling `clear` will delete the cached state of the cubit
  /// but will not modify the current state of the cubit.
  Future<void> clear() => storage.delete(storageToken);

  /// Responsible for converting the `Map<String, dynamic>` representation
  /// of the cubit state into a concrete instance of the cubit state.
  State fromJson(Map<String, dynamic> json);

  /// Responsible for converting a concrete instance of the cubit state
  /// into the the `Map<String, dynamic>` representation.
  ///
  /// If `toJson` returns `null`, then no state changes will be persisted.
  Map<String, dynamic> toJson(State state);
}

/// {@template NIL}
/// Type which represents objects that do not support json encoding
///
/// This should never be used and is exposed only for testing purposes.
/// {@endtemplate}
@visibleForTesting
class NIL {
  /// {@macro NIL}
  const NIL();
}

enum _Outcome { atomic, complex }

class _Traversed {
  _Traversed._({@required this.outcome, @required this.value});
  _Traversed.atomic(dynamic value)
      : this._(outcome: _Outcome.atomic, value: value);
  _Traversed.complex(dynamic value)
      : this._(outcome: _Outcome.complex, value: value);
  final _Outcome outcome;
  final dynamic value;
}
