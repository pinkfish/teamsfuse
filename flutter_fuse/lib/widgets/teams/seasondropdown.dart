import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// A drop down to select a season from the team.
///
class SeasonDropDown extends StatelessWidget {
  final String teamUid;
  final String value;
  final ValueChanged<String> onChanged;
  final bool includeNone;
  final bool includeAll;
  final bool isExpanded;
  final bool includeDecorator;
  final TextStyle style;

  static String noneValue = 'none';
  static String allValue = 'all';

  SeasonDropDown(
      {@required this.teamUid,
      @required this.value,
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
          labelText: Messages.of(context).season,
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
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (context, singleTeamBloc) => BlocBuilder(
        cubit: singleTeamBloc,
        builder: (BuildContext context, SingleTeamState state) {
          if (state is SingleTeamLoaded && !state.loadedSeasons) {
            singleTeamBloc.add(SingleTeamLoadSeasons());
          }
          if (state is SingleTeamUninitialized ||
              state is SingleTeamDeleted ||
              !state.loadedSeasons) {
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
                Messages.of(context).allSeasons,
                style: style ?? Theme.of(context).textTheme.headline6,
              ),
            ));
          }
          return DropdownButton(
            value: value,
            isExpanded: isExpanded,
            items: <DropdownMenuItem<String>>[
              ...items,
              ...state.fullSeason
                  .map((Season s) => DropdownMenuItem(
                        value: s.uid,
                        child: Text(
                          s.name,
                          style: style ?? Theme.of(context).textTheme.headline6,
                        ),
                      ))
                  .toList(),
            ],
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
