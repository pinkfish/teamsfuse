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
  final String value;
  final ValueChanged<String> onChanged;
  final bool includeNone;
  final bool includeAll;
  final bool isExpanded;
  final bool includeDecorator;
  final TextStyle style;

  static String noneValue = 'none';
  static String allValue = 'all';

  PlayerDropDown(
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
        cubit: BlocProvider.of<SingleSeasonBloc>(context),
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
                        ),
                      ))
                  .toList(),
            ],
            onChanged: onChanged,
          );
        });
  }
}
