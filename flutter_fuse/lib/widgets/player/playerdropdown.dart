import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import 'playername.dart';

///
/// A drop down to select a player from the season.
///
class PlayerDropDown extends StatelessWidget {
  /// The current value of the dropdown.
  final String value;

  /// What to do when the value changes.
  final ValueChanged<String> onChanged;

  /// If we shoud include the 'none' in the dropdown.
  final bool includeNone;

  /// If we should include the 'all' in the dropdown.
  final bool includeAll;

  /// IsExpanded flag to deal with dropdowns in an expanded item.
  final bool isExpanded;

  /// If we should include the decorator.
  final bool includeDecorator;

  /// The style to display the players in
  final TextStyle style;

  /// The bloc to get the derason details from.
  final SingleSeasonBloc singleSeasonBloc;

  /// If none is selected.
  static String noneValue = 'none';

  /// If all is selected.
  static String allValue = 'all';

  /// Constructor for the dropdown.
  PlayerDropDown(this.singleSeasonBloc,
      {@required this.value,
      @required this.onChanged,
      this.includeNone = false,
      this.includeDecorator = false,
      this.includeAll = false,
      this.isExpanded = false,
      this.style});

  @override
  Widget build(BuildContext context) {
    if (includeDecorator) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: Messages.of(context).playerName,
          isDense: true,
          border: InputBorder.none,
          labelStyle: TextStyle(height: 2.0),
        ),
        child: _insideStuff(context),
      );
    }
    return _insideStuff(context);
  }

  Widget _insideStuff(BuildContext context) {
    return BlocConsumer(
        bloc: singleSeasonBloc,
        listener: (BuildContext context, SingleSeasonState state) {},
        builder: (BuildContext context, SingleSeasonState state) {
          if (state is SingleSeasonUninitialized ||
              state is SingleSeasonDeleted) {
            return DropdownButton(
              value: value,
              isExpanded: isExpanded,
              items: [
                DropdownMenuItem(
                  value: value,
                  child: Text(
                    Messages.of(context).loading,
                    style: style ?? Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
              onChanged: onChanged,
            );
          }
          var items = <DropdownMenuItem<String>>[];
          if (includeNone) {
            items.add(DropdownMenuItem(
              value: noneValue,
              child: Text(
                Messages.of(context).emptyText,
                style: style ?? Theme.of(context).textTheme.headline6,
              ),
            ));
          }
          if (includeAll) {
            items.add(DropdownMenuItem(
              value: allValue,
              child: Text(
                Messages.of(context).allPlayers,
                style: style ?? Theme.of(context).textTheme.headline6,
              ),
            ));
          }
          return DropdownButton(
            value: value,
            isExpanded: isExpanded,
            items: <DropdownMenuItem<String>>[
              ...items,
              ...state.season.playersData.keys
                  .map((String uid) => DropdownMenuItem(
                        value: uid,
                        child: PlayerName(
                          playerUid: uid,
                          fallback: state.season.playersData[uid].jerseyNumber,
                        ),
                      ))
                  .toList(),
            ],
            onChanged: onChanged,
          );
        });
  }
}
