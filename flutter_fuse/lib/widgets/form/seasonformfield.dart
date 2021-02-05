import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';

///
/// Shows a form field to select the season for the team.
///
class SeasonFormField extends FormField<String> {
  /// Constructor.
  SeasonFormField({
    SingleTeamBloc teamBloc,
    Team team,
    Key key,
    String initialValue = none,
    bool enabled = true,
    this.includeNone = false,
    this.includeNew = false,
    InputDecoration decoration = const InputDecoration(),
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
          builder: (field) {
            var state = field as SeasonFormFieldState;
            var effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            if (teamBloc != null) {
              return BlocBuilder(
                cubit: teamBloc,
                builder: (context, singleTeamState) {
                  if (singleTeamState is SingleTeamLoaded &&
                      !singleTeamState.loadedSeasons) {
                    teamBloc.add(SingleTeamLoadSeasons());
                  }
                  if (singleTeamState is SingleTeamUninitialized ||
                      !singleTeamState.loadedSeasons) {
                    return Text(Messages.of(context).loading);
                  }

                  return InputDecorator(
                    decoration: effectiveDecoration,
                    child: DropdownButton<String>(
                        hint: Text(Messages.of(state.context).seasonselect),
                        value: state.value,
                        items:
                            state._buildItems(state.context, singleTeamState),
                        onChanged: enabled
                            ? (val) {
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
                builder: (context, singleTeamBloc) => BlocBuilder(
                    cubit: singleTeamBloc,
                    builder: (context, singleTeamState) {
                      if (singleTeamState is SingleTeamLoaded &&
                          !singleTeamState.loadedSeasons) {
                        teamBloc.add(SingleTeamLoadSeasons());
                      }

                      if (singleTeamState is SingleTeamUninitialized ||
                          !singleTeamState.loadedSeasons) {
                        return Text(Messages.of(context).loading);
                      }

                      return InputDecorator(
                        decoration: effectiveDecoration,
                        child: DropdownButton<String>(
                            hint: Text(Messages.of(state.context).seasonselect),
                            value: state.value,
                            items: state._buildItems(
                                state.context, singleTeamState),
                            onChanged: enabled
                                ? (val) {
                                    state.updateValue(val);
                                    field.didChange(val);
                                    if (onFieldSubmitted != null) {
                                      onFieldSubmitted(val);
                                    }
                                  }
                                : null),
                      );
                    }),
              );
            }
          },
        );

  /// If we should include the none item.
  final bool includeNone;

  /// If we should include the new item.
  final bool includeNew;

  /// None constant if none of the seasons are selected.
  static const String none = 'none';

  /// None constant if a new season is asked to be created.
  static const String createNew = 'new';

  @override
  SeasonFormFieldState createState() => SeasonFormFieldState();
}

///
/// The season form field state for the season.
///
class SeasonFormFieldState extends FormFieldState<String> {
  SeasonFormField get _widget {
    var field = super.widget as SeasonFormField;
    return field;
  }

  /// Update the value for the season, setting the current season.
  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState state) {
    var ret = <DropdownMenuItem<String>>[];
    if (_widget.includeNone) {
      ret.add(DropdownMenuItem<String>(
        child: Text(Messages.of(context).noseasons),
        value: SeasonFormField.none,
      ));
    }
    if (_widget.includeNew) {
      ret.add(DropdownMenuItem<String>(
        child: Text(Messages.of(context).addseason),
        value: SeasonFormField.createNew,
      ));
    }
    for (var season in state.fullSeason) {
      ret.add(DropdownMenuItem<String>(
          child: Text(season.name), value: season.uid));
    }

    return ret;
  }
}
