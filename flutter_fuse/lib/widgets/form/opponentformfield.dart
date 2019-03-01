import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class OpponentFormField extends FormField<String> {
  OpponentFormField({
    @required String teamUid,
    Key key,
    String initialValue: '',
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(initialValue != null),
        assert(teamUid != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<String> field) {
            final OpponentFormFieldState state =
                field as OpponentFormFieldState;
            state.teamUid = teamUid;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return new InputDecorator(
              decoration: effectiveDecoration.copyWith(
                errorText: field.errorText,
              ),
              child: new DropdownButton<String>(
                hint: new Text(Messages.of(state.context).opponentselect,
                    overflow: TextOverflow.clip),
                items: state._buildItems(state.context),
                value: state.value,
                onChanged: (String val) {
                  state.updateValue(val);
                  field.didChange(val);
                  if (onFieldSubmitted != null) {
                    onFieldSubmitted(val);
                  }
                },
              ),
            );
          },
        );

  @override
  OpponentFormFieldState createState() => new OpponentFormFieldState();
}

class OpponentFormFieldState extends FormFieldState<String> {
  String teamUid;
  StreamSubscription<UpdateReason> teamSubscription;

  void updateValue(String val) {
    setValue(val);
  }

  void setTeamUid(String teamUid) {
    setState(() {
      this.teamUid = teamUid;
      if (teamSubscription != null) {
        teamSubscription.cancel();
      }
      teamSubscription = UserDatabaseData.instance.teams[teamUid].thisTeamStream
          .listen((UpdateReason value) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (teamSubscription != null) {
      teamSubscription.cancel();
      teamSubscription = null;
    }
  }

  List<DropdownMenuItem<String>> _buildItems(BuildContext context) {
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

    if (teamUid != null &&
        UserDatabaseData.instance.teams.containsKey(teamUid)) {
      Team team = UserDatabaseData.instance.teams[teamUid];
      List<String> uids =
          UserDatabaseData.instance.teams[teamUid].opponents.keys.toList();
      uids.sort((String v1, String v2) =>
          team.opponents[v1].name.compareTo(team.opponents[v2].name));
      for (String opponentUid in uids) {
        Opponent opponent = team.opponents[opponentUid];
        if (opponent.name != null) {
          ret.add(new DropdownMenuItem<String>(
              child: new Text(opponent.name, overflow: TextOverflow.clip),
              value: opponent.uid));
        }
      }
    }

    return ret;
  }
}
