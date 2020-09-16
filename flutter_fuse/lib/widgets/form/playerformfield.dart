import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class PlayerFormField extends FormField<String> {
  PlayerFormField({
    Key key,
    String initialValue: '',
    InputDecoration decoration: const InputDecoration(),
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
          builder: (FormFieldState<String> field) {
            final PlayerFormFieldState state = field as PlayerFormFieldState;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return InputDecorator(
                decoration: effectiveDecoration.copyWith(
                  errorText: field.errorText,
                ),
                child: BlocBuilder(
                    cubit: BlocProvider.of<PlayerBloc>(state.context),
                    builder: (BuildContext context, PlayerState playerState) {
                      return DropdownButton<String>(
                        hint: Text(Messages.of(state.context).playerselecthint),
                        items: state._buildItems(state.context, playerState),
                        value: state.value,
                        onChanged: (String val) {
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

  static const String addPlayer = 'add';
  static const String nonePlayer = 'none';

  final bool addNew;

  @override
  PlayerFormFieldState createState() => PlayerFormFieldState();
}

class PlayerFormFieldState extends FormFieldState<String> {
  @override
  PlayerFormField get widget {
    PlayerFormField field = super.widget as PlayerFormField;
    return field;
  }

  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, PlayerState state) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    ret.add(
      DropdownMenuItem<String>(
        child: Text(Messages.of(context).playerselect),
        value: PlayerFormField.nonePlayer,
      ),
    );

    if (widget.addNew) {
      ret.add(DropdownMenuItem<String>(
          child: Text(Messages.of(context).addplayer),
          value: PlayerFormField.addPlayer));
    }

    for (Player player in state.players.values) {
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
