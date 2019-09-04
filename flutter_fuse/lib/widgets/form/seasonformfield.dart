import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../widgets/blocs/singleteamprovider.dart';

class SeasonFormField extends FormField<String> {
  SeasonFormField({
    SingleTeamBloc teamBloc,
    Team team,
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
        assert(teamBloc != null || team != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<String> field) {
            final SeasonFormFieldState state = field as SeasonFormFieldState;
            state._teamUid = teamBloc;
            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            if (teamBloc != null) {
              return BlocBuilder(
                bloc: teamBloc,
                builder:
                    (BuildContext context, SingleTeamState singleTeamState) {
                  return InputDecorator(
                    decoration: effectiveDecoration,
                    child: DropdownButton<String>(
                        hint: new Text(Messages.of(state.context).seasonselect),
                        value: state.value,
                        items:
                            state._buildItems(state.context, singleTeamState),
                        onChanged: enabled
                            ? (String val) {
                                state.updateValue(val);
                                field.didChange(val);
                                if (onFieldSubmitted != null) {
                                  onFieldSubmitted(val);
                                }
                              }
                            : null),
                  );
                },
              );
            } else {
              return SingleTeamProvider(
                teamUid: team.uid,
                builder:
                    (BuildContext context, SingleTeamBloc singleTeamBloc) =>
                        BlocBuilder(
                  bloc: singleTeamBloc,
                  builder:
                      (BuildContext context, SingleTeamState singleTeamState) =>
                          InputDecorator(
                    decoration: effectiveDecoration,
                    child: DropdownButton<String>(
                        hint: new Text(Messages.of(state.context).seasonselect),
                        value: state.value,
                        items:
                            state._buildItems(state.context, singleTeamState),
                        onChanged: enabled
                            ? (String val) {
                                state.updateValue(val);
                                field.didChange(val);
                                if (onFieldSubmitted != null) {
                                  onFieldSubmitted(val);
                                }
                              }
                            : null),
                  ),
                ),
              );
            }
          },
        );

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

  SingleTeamBloc _teamUid;
  bool _includeNone;
  bool _includeNew;

  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState state) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    if (_teamUid != null) {
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
      state.fullSeason.forEach((Season season) {
        ret.add(new DropdownMenuItem<String>(
            child: new Text(season.name), value: season.uid));
      });
    }

    return ret;
  }
}
