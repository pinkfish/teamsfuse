import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class SeasonFormField extends FormField<String> {
  SeasonFormField({
    @required String teamUid,
    Key key,
    String initialValue: none,
    bool enabled: true,
    this.includeNone: false,
    this.includeNew: false,
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
              state._teamUid = teamUid;
              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return new InputDecorator(
                  decoration: effectiveDecoration,
                  child: new DropdownButton<String>(
                      hint: new Text(Messages.of(state.context).seasonselect),
                      value: state.value,
                      items: state._buildItems(state.context),
                      onChanged: enabled
                          ? (String val) {
                              state.updateValue(val);
                              field.didChange(val);
                              if (onFieldSubmitted != null) {
                                onFieldSubmitted(val);
                              }
                            }
                          : null));
            });

  final bool includeNone;
  final bool includeNew;

  static const String none = 'none';
  static const String createNew = 'new';

  @override
  SeasonFormFieldState createState() =>
      new SeasonFormFieldState(includeNone, includeNew);
}

class SeasonFormFieldState extends FormFieldState<String> {
  SeasonFormFieldState(this._includeNone, this._includeNew);

  String _teamUid;
  StreamSubscription<UpdateReason> _teamSubscription;
  bool _includeNone;
  bool _includeNew;

  void updateValue(String val) {
    setValue(val);
  }

  void setTeamUid(String teamUid) {
    setState(() {
      _teamUid = teamUid;
      if (_teamSubscription != null) {
        _teamSubscription.cancel();
      }
      _teamSubscription = UserDatabaseData
          .instance.teams[teamUid].thisTeamStream
          .listen((UpdateReason value) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_teamSubscription != null) {
      _teamSubscription.cancel();
      _teamSubscription = null;
    }
  }

  List<DropdownMenuItem<String>> _buildItems(BuildContext context) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    if (_teamUid != null &&
        UserDatabaseData.instance.teams.containsKey(_teamUid)) {
      if (_includeNone) {
        ret.add(new DropdownMenuItem<String>(
          child: Text(Messages.of(context).noseasons),
          value: SeasonFormField.none,
        ));
      }
      if (_includeNew) {
        ret.add(new DropdownMenuItem<String>(
          child: Text(Messages.of(context).addseason),
          value: SeasonFormField.createNew,
        ));
      }
      UserDatabaseData.instance.teams[_teamUid].seasons
          .forEach((String key, Season season) {
        ret.add(new DropdownMenuItem<String>(
            child: new Text(season.name), value: season.uid));
      });
    }

    return ret;
  }
}
