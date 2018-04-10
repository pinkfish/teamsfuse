import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';

class SeasonFormField extends FormField<String> {
  SeasonFormField({
    Key key,
    String teamUid,
    String initialValue: '',
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })
      : assert(initialValue != null),
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
                  child: new DropdownButton(
                      hint: new Text(Messages.of(state.context).seasonselect),
                      value: state.value,
                      items: state._buildItems(state.context),
                      onChanged: (dynamic val) {
                        state.setValue(val);
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
  @override
  SeasonFormField get widget => super.widget;

  String teamUid;
  StreamSubscription<UpdateReason> teamSubscription;

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

  List<DropdownMenuItem> _buildItems(BuildContext context) {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    if (teamUid != null &&
        UserDatabaseData.instance.teams.containsKey(teamUid)) {
      UserDatabaseData.instance.teams[teamUid].seasons.forEach((key, season) {
        ret.add(new DropdownMenuItem(
            child: new Text(season.name), value: season.uid));
      });
    }

    return ret;
  }
}
