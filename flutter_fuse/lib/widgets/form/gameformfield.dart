import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../games/gametitle.dart';

///
/// Shows a form field to select the season for the team.
///
class GameFormField extends FormField<String> {
  /// Constructor.
  GameFormField({
    SingleSeasonBloc seasonBloc,
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
          key: key ?? Key('GAME'),
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (field) {
            var state = field as GameFormFieldState;
            var effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            return BlocBuilder(
              cubit: seasonBloc,
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
  GameFormFieldState createState() => GameFormFieldState();
}

///
/// The season form field state for the season.
///
class GameFormFieldState extends FormFieldState<String> {
  GameFormField get _widget {
    var field = super.widget as GameFormField;
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
        value: GameFormField.none,
        child: Text(Messages.of(context).noGames),
      ));
    }
    if (_widget.includeNew) {
      ret.add(DropdownMenuItem<String>(
        value: GameFormField.createNew,
        child: Text(Messages.of(context).addGame),
      ));
    }
    for (var game in state.games) {
      ret.add(
        DropdownMenuItem<String>(
          value: game.uid,
          child: Row(
            children: [
              Text(DateFormat.yMMMd().format(game.sharedData.tzTime)),
              SizedBox(width: 5),
              GameTitle(
                game,
                null,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
      );
    }
    if (ret.where((element) => element.value == value).isEmpty) {
      setValue(ret[0].value);
    }

    return ret;
  }
}
