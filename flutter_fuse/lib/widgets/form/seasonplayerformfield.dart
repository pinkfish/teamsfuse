import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../player/playername.dart';

///
/// Shows a form field to select the player in season for the team.
///
class SeasonPlayerFormField extends FormField<String> {
  /// Constructor.
  SeasonPlayerFormField({
    @required SingleSeasonBloc seasonBloc,
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
        assert(seasonBloc != null),
        super(
          key: key ?? Key('SEASONPLAYER'),
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (field) {
            var state = field as _SeasonPlayerFormFieldState;
            var effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            return BlocBuilder(
              bloc: seasonBloc,
              builder: (context, singleSeasonState) {
                if (singleSeasonState is SingleSeasonLoaded &&
                    !singleSeasonState.loadedGames) {
                  seasonBloc.add(SingleSeasonLoadGames());
                }
                if (singleSeasonState is SingleSeasonUninitialized ||
                    !singleSeasonState.loadedGames) {
                  return Text(Messages.of(context).loading);
                }

                return InputDecorator(
                  decoration: effectiveDecoration,
                  child: DropdownButton<String>(
                      hint: Text(Messages.of(state.context).gameSelect),
                      value: state.value,
                      items:
                          state._buildItems(state.context, singleSeasonState),
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
  _SeasonPlayerFormFieldState createState() => _SeasonPlayerFormFieldState();
}

///
/// The season form field state for the season.
///
class _SeasonPlayerFormFieldState extends FormFieldState<String> {
  SeasonPlayerFormField get _widget {
    var field = super.widget as SeasonPlayerFormField;
    return field;
  }

  /// Update the value for the season, setting the current season.
  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleSeasonState state) {
    var ret = <DropdownMenuItem<String>>[];
    if (state is SingleTeamUninitialized || !state.loadedGames) {
      ret.add(DropdownMenuItem<String>(
        value: widget.initialValue,
        child: Text(Messages.of(context).loading),
      ));
    }
    if (_widget.includeNone) {
      ret.add(DropdownMenuItem<String>(
        value: SeasonPlayerFormField.none,
        child: Text(Messages.of(context).noGames),
      ));
    }
    if (_widget.includeNew) {
      ret.add(DropdownMenuItem<String>(
        value: SeasonPlayerFormField.createNew,
        child: Text(Messages.of(context).addGame),
      ));
    }
    for (var player in state.season.players) {
      ret.add(DropdownMenuItem<String>(
        value: player.playerUid,
        child: PlayerName(playerUid: player.playerUid),
      ));
    }
    if (ret.where((element) => element.value == value).isEmpty) {
      setValue(ret[0].value);
    }

    return ret;
  }
}
