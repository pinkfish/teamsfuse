import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///
/// Create a provider that will insert the single generic bloc into the tree if the
/// bloc is not current provided.
///
class SingleBlocProvider<T extends Bloc<dynamic, dynamic>>
    extends StatefulWidget {
  final T Function(BuildContext context, String uid) creator;
  final Widget Function(BuildContext context, T bloc) builder;
  final String keyUid;

  SingleBlocProvider({this.builder, this.keyUid, this.creator});

  @override
  State createState() => _SingleClubProviderState<T>();
}

class _BlocProviderState<T extends Bloc<dynamic, dynamic>> {
  final T bloc;
  int ref;

  _BlocProviderState(this.bloc) : ref = 0;
}

class _SingleClubProviderState<T extends Bloc<dynamic, dynamic>>
    extends State<SingleBlocProvider<T>> {
  T _singleBloc;
  bool _newBloc = false;
  static Map<String, _BlocProviderState<dynamic>> blocs = {};

  @override
  void initState() {
    super.initState();
    if (!blocs.containsKey(widget.keyUid)) {
      try {
        _singleBloc = BlocProvider.of<T>(context);
      } catch (_) {}

      if (_singleBloc == null) {
        _singleBloc = widget.creator(context, widget.keyUid);
        blocs[widget.keyUid] = _BlocProviderState<T>(_singleBloc);
        _newBloc = true;
      }
    }
    _singleBloc = blocs[widget.keyUid].bloc as T;
    blocs[widget.keyUid].ref++;
  }

  @override
  void dispose() {
    super.dispose();
    blocs[widget.keyUid].ref--;
    if (blocs[widget.keyUid].ref <= 0) {
      var state = blocs.remove(widget.keyUid);
      state.bloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_newBloc) {
      return BlocProvider.value(
        value: _singleBloc,
        child: widget.builder(context, _singleBloc),
      );
    }
    return widget.builder(context, _singleBloc);
  }
}
