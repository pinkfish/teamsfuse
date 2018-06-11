import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class SeasonFormField extends FormField<String> {
  SeasonFormField({
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
              final SeasonFormFieldState state = field;
              state.teamUid = teamUid;
              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return new InputDecorator(
                  decoration: effectiveDecoration,
                  child: new DropdownButton<String>(
                      hint: new Text(Messages.of(state.context).seasonselect),
                      value: state.value,
                      items: state._buildItems(state.context),
                      onChanged: (String val) {
                        state.updateValue(val);
                        field.didChange(val);
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted(val);
                        }
                      }));
            });

  @override
  SeasonFormFieldState createState() => new SeasonFormFieldState();
}

class SeasonFormFieldState extends FormFieldState<String> {
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
    if (teamUid != null &&
        UserDatabaseData.instance.teams.containsKey(teamUid)) {
      UserDatabaseData.instance.teams[teamUid].seasons
          .forEach((String key, Season season) {
        ret.add(new DropdownMenuItem<String>(
            child: new Text(season.name), value: season.uid));
      });
    }

    return ret;
  }
}
