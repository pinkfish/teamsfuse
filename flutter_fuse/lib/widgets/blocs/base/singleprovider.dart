import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///
/// Create a provider that will insert the single generic bloc into the tree if the
/// bloc is not current provided.
///
abstract class SingleBlocProvider<T extends Bloc<dynamic, dynamic>>
    extends StatefulWidget {
  /// Constructor for the single bloc provider.
  SingleBlocProvider(
      {this.builder, this.keyUid, this.creator, this.prefix = ""});

  /// the function to create the provider.
  final T Function(BuildContext context, String uid) creator;

  /// The builder for the inside with the type associated with the data.
  final Widget Function(BuildContext context, T bloc) builder;

  /// The keyUid to use to find it in the tree.
  final String keyUid;

  /// Prefix to the uid so they don't get mixed up between namespaces;
  final String prefix;

  bool isBlocEqual(Bloc bloc);

  @override
  State createState() => _SingleBlocProviderState<T>();
}

class _BlocProviderState<T extends Bloc<dynamic, dynamic>> {
  _BlocProviderState(this.bloc) : ref = 0;

  final T bloc;
  int ref;
}

class _SingleBlocProviderState<T extends Bloc<dynamic, dynamic>>
    extends State<SingleBlocProvider<T>> {
  T _singleBloc;
  bool _newBloc = false;
  static Map<String, _BlocProviderState<dynamic>> blocs = {};

  @override
  void initState() {
    print("initState");
    super.initState();
    _updateSingleBloc();
  }

  void _updateSingleBloc() {
    var totalKey = (widget.prefix ?? "") + widget.keyUid;
    if (!blocs.containsKey(totalKey) || blocs[totalKey] == null) {
      try {
        _singleBloc = BlocProvider.of<T>(context);
      } catch (_) {
        _singleBloc = null;
      }

      if (_singleBloc == null || !widget.isBlocEqual(_singleBloc)) {
        _singleBloc = widget.creator(context, widget.keyUid);
        blocs[totalKey] = _BlocProviderState<T>(_singleBloc);
        _newBloc = true;
      } else {
        blocs[totalKey] = _BlocProviderState<T>(_singleBloc);
      }
    } else {
      _singleBloc = blocs[totalKey].bloc as T;
      blocs[totalKey].ref++;
    }
  }

  @override
  void dispose() {
    super.dispose();
    var totalKey = (widget.prefix ?? "") + widget.keyUid;
    if (blocs.containsKey(totalKey)) {
      blocs[totalKey].ref--;
      if (blocs[totalKey].ref <= 0) {
        var state = blocs.remove(totalKey);
        state.bloc.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    // If the teamUid has changed, flip stuff.
    if (!widget.isBlocEqual(_singleBloc)) {
      _updateSingleBloc();
    }
    if (_newBloc) {
      return BlocProvider.value(
        value: _singleBloc,
        child: widget.builder(context, _singleBloc),
      );
    }
    return widget.builder(context, _singleBloc);
  }
}
