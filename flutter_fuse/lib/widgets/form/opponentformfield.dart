import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// The opponent form field to display the opponent and setup for
/// selection.
///
class OpponentFormField extends FormField<String> {
  /// Constructor.
  OpponentFormField({
    @required SingleTeamBloc teamBloc,
    Key key,
    String initialValue = '',
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(initialValue != null),
        assert(teamBloc != null),
        super(
          key: key ?? Key("OPPONENT"),
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (field) {
            var state = field as OpponentFormFieldState;

            var effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return BlocBuilder(
                cubit: teamBloc,
                builder: (context, singleTeamState) {
                  if (singleTeamState is SingleTeamLoaded &&
                      !singleTeamState.loadedOpponents) {
                    teamBloc.add(SingleTeamLoadOpponents());
                  }
                  return InputDecorator(
                    decoration: effectiveDecoration.copyWith(
                      errorText: field.errorText,
                    ),
                    child: DropdownButton<String>(
                      hint: Text(Messages.of(state.context).opponentselect,
                          overflow: TextOverflow.clip),
                      items: state._buildItems(context, singleTeamState),
                      value: state.value.isEmpty
                          ? OpponentFormField.none
                          : state.value,
                      onChanged: (val) {
                        state.updateValue(val);
                        field.didChange(val);
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted(val);
                        }
                      },
                    ),
                  );
                });
          },
        );

  /// None of the opponents are selected.
  static const String none = 'none';

  /// Add a new opponent is selected.
  static const String add = 'add';

  @override
  OpponentFormFieldState createState() => OpponentFormFieldState();
}

///
/// The state for the opponents form field.
///
class OpponentFormFieldState extends FormFieldState<String> {
  /// Update the current value of the selected opponent.
  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState state) {
    var ret = <DropdownMenuItem<String>>[];
    ret.add(DropdownMenuItem<String>(
      child: Text(
        Messages.of(context).opponentselect,
        overflow: TextOverflow.clip,
      ),
      value: OpponentFormField.none,
    ));

    ret.add(
      DropdownMenuItem<String>(
          child: Text(Messages.of(context).addOpponent,
              overflow: TextOverflow.clip),
          value: OpponentFormField.add),
    );

    var uids = state.opponents.keys.toSet().toList();
    uids.sort((v1, v2) =>
        state.opponents[v1].name.compareTo(state.opponents[v2].name));
    for (var opponentUid in uids) {
      var opponent = state.opponents[opponentUid];
      if (opponent.name != null) {
        ret.add(DropdownMenuItem<String>(
            child: Text(opponent.name, overflow: TextOverflow.clip),
            value: opponent.uid));
      }
    }

    return ret;
  }
}
