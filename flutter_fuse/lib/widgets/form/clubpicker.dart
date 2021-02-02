import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// Shows a picker to select a club.
///
class ClubPicker extends StatelessWidget {
  /// Constructor.
  ClubPicker({
    @required this.onChanged,
    this.clubUid,
    this.adminOnly = true,
    this.selectedTitle = false,
  });

  /// Called when the value changes.
  final ValueChanged<String> onChanged;

  /// The current clubUid selected.
  final String clubUid;

  /// Only shows clubs they are an admin of.
  final bool adminOnly;

  /// If the title is selected.
  final bool selectedTitle;

  /// The variable to use if nothing is selected.
  static const String noClub = "noClub";

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, ClubState state) {
    var ret = <DropdownMenuItem<String>>[];
    ret.add(
      DropdownMenuItem<String>(
        child: Text(Messages.of(context).noclub),
        value: noClub,
      ),
    );
    for (var club in state.clubs.values) {
      if (adminOnly && club.isAdmin()) {
        ret.add(
          DropdownMenuItem<String>(
            child: Text(club.name),
            value: club.uid,
          ),
        );
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: Messages.of(context).club,
        labelStyle: selectedTitle
            ? Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: BlocBuilder(
                  cubit: BlocProvider.of<ClubBloc>(context),
                  builder: (context, state) {
                    return DropdownButton<String>(
                      hint: Text(Messages.of(context).selectclub),
                      items: _buildItems(context, state),
                      value: clubUid,
                      onChanged: onChanged,
                    );
                  })),
        ],
      ),
    );
  }
}
