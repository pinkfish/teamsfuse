import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///
/// Create a provider that will insert the single generic bloc into the tree if the
/// bloc is not current provided.
///
class SingleBlocProvider<T extends Bloc<dynamic, dynamic>>
    extends StatefulWidget {
  /// Constructor for the single bloc provider.
  SingleBlocProvider({this.builder, this.keyUid, this.creator});

  /// the function to create the provider.
  final T Function(BuildContext context, String uid) creator;

  /// The builder for the inside with the type associated with the data.
  final Widget Function(BuildContext context, T bloc) builder;

  /// The keyUid to use to find it in the tree.
  final String keyUid;

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
    super.initState();
    if (!blocs.containsKey(widget.keyUid)) {
      try {
        _singleBloc = BlocProvider.of<T>(context);
      } catch (_) {
        _singleBloc = null;
      }

      if (_singleBloc == null) {
        _singleBloc = widget.creator(context, widget.keyUid);
        blocs[widget.keyUid] = _BlocProviderState<T>(_singleBloc);
        _newBloc = true;
      }
    }
    _singleBloc = blocs[widget.keyUid].bloc as T;
    blocs[widget.keyUid].ref++;
    print("Got singleBloc $_singleBloc");
  }

  @override
  void dispose() {
    super.dispose();
    blocs[widget.keyUid].ref--;
    if (blocs[widget.keyUid].ref <= 0) {
      print("Closing ${widget.keyUid}");
      var state = blocs.remove(widget.keyUid);
      state.bloc.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Making bloc $_newBloc $_singleBloc");
    if (_newBloc) {
      return BlocProvider.value(
        value: _singleBloc,
        child: widget.builder(context, _singleBloc),
      );
    }
    return widget.builder(context, _singleBloc);
  }
}
