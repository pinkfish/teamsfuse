import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// A field in a form to allow for a player to be selected.
///
class PlayerFormField extends FormField<String> {
  /// Constructor.
  PlayerFormField({
    Key key,
    String initialValue = '',
    InputDecoration decoration = const InputDecoration(),
    this.addNew = true,
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(initialValue != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (field) {
            var state = field as PlayerFormFieldState;

            var effectiveDecoration = (decoration ?? InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return InputDecorator(
                decoration: effectiveDecoration.copyWith(
                  errorText: field.errorText,
                ),
                child: BlocBuilder(
                    cubit: BlocProvider.of<PlayerBloc>(state.context),
                    builder: (context, playerState) {
                      return DropdownButton<String>(
                        hint: Text(Messages.of(state.context).playerselecthint),
                        items: state._buildItems(state.context, playerState),
                        value: state.value,
                        onChanged: (val) {
                          state.updateValue(val);
                          field.didChange(val);
                          if (onFieldSubmitted != null) {
                            onFieldSubmitted(val);
                          }
                        },
                      );
                    }));
          },
        );

  /// Constant to mark as an add case.
  static const String addPlayer = 'add';

  /// If the none of the players are selected.
  static const String nonePlayer = 'none';

  /// If wer can add a new player or not.
  final bool addNew;

  @override
  PlayerFormFieldState createState() => PlayerFormFieldState();
}

///
/// The state for the form field.
///
class PlayerFormFieldState extends FormFieldState<String> {
  PlayerFormField get _widget {
    var field = super.widget as PlayerFormField;
    return field;
  }

  ///
  /// Updates the value for this form field to select the specific player.
  ///
  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, PlayerState state) {
    var ret = <DropdownMenuItem<String>>[];
    ret.add(
      DropdownMenuItem<String>(
        child: Text(Messages.of(context).playerselect),
        value: PlayerFormField.nonePlayer,
      ),
    );

    if (_widget.addNew) {
      ret.add(DropdownMenuItem<String>(
          child: Text(Messages.of(context).addplayer),
          value: PlayerFormField.addPlayer));
    }

    for (var player in state.players.values) {
      if (player.name != null) {
        ret.add(
          DropdownMenuItem<String>(
            child: Text(player.name),
            value: player.uid,
          ),
        );
      }
    }

    return ret;
  }
}
