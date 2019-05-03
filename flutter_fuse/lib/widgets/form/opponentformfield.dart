import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class OpponentFormField extends FormField<String> {
  OpponentFormField({
    @required SingleTeamBloc teamBloc,
    Key key,
    String initialValue: '',
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(initialValue != null),
        assert(teamBloc != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<String> field) {
            final OpponentFormFieldState state =
                field as OpponentFormFieldState;
            state.teamBloc = teamBloc;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return BlocBuilder(
              bloc: teamBloc,
              builder: (BuildContext context,
                      SingleTeamState singleTeamState) =>
                  InputDecorator(
                    decoration: effectiveDecoration.copyWith(
                      errorText: field.errorText,
                    ),
                    child: new DropdownButton<String>(
                      hint: new Text(Messages.of(state.context).opponentselect,
                          overflow: TextOverflow.clip),
                      items: state._buildItems(context, singleTeamState),
                      value: state.value,
                      onChanged: (String val) {
                        state.updateValue(val);
                        field.didChange(val);
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted(val);
                        }
                      },
                    ),
                  ),
            );
          },
        );

  @override
  OpponentFormFieldState createState() => new OpponentFormFieldState();
}

class OpponentFormFieldState extends FormFieldState<String> {
  SingleTeamBloc teamBloc;

  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState state) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    ret.add(new DropdownMenuItem<String>(
      child: new Text(
        Messages.of(context).opponentselect,
        overflow: TextOverflow.clip,
      ),
      value: 'none',
    ));

    ret.add(
      new DropdownMenuItem<String>(
          child: new Text(Messages.of(context).addopponent,
              overflow: TextOverflow.clip),
          value: 'add'),
    );

    List<String> uids = state.team.opponents.keys.toList();
    uids.sort((String v1, String v2) =>
        state.team.opponents[v1].name.compareTo(state.team.opponents[v2].name));
    for (String opponentUid in uids) {
      Opponent opponent = state.team.opponents[opponentUid];
      if (opponent.name != null) {
        ret.add(new DropdownMenuItem<String>(
            child: new Text(opponent.name, overflow: TextOverflow.clip),
            value: opponent.uid));
      }
    }

    return ret;
  }
}
