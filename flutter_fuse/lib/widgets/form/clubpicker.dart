import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubPicker extends StatelessWidget {
  ClubPicker({
    @required this.onChanged,
    this.clubUid,
    this.adminOnly = true,
    this.selectedTitle = false,
  });

  final ValueChanged<String> onChanged;
  final String clubUid;
  final bool adminOnly;
  final bool selectedTitle;

  static const String noClub = "noClub";

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, ClubState state) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    ret.add(
      new DropdownMenuItem<String>(
        child: new Text(Messages.of(context).noclub),
        value: noClub,
      ),
    );
    for (Club club in state.clubs.values) {
      if (adminOnly && club.isAdmin()) {
        ret.add(
          new DropdownMenuItem<String>(
            child: new Text(club.name),
            value: club.uid,
          ),
        );
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return new InputDecorator(
      decoration: new InputDecoration(
        labelText: Messages.of(context).club,
        labelStyle: selectedTitle
            ? Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(
              flex: 1,
              child: BlocBuilder(
                  bloc: BlocProvider.of<ClubBloc>(context),
                  builder: (BuildContext context, ClubState state) {
                    return DropdownButton<String>(
                      hint: new Text(Messages.of(context).selectclub),
                      items: _buildItems(context, state),
                      value: clubUid,
                      onChanged: (String val) {
                        onChanged(val);
                      },
                    );
                  })),
        ],
      ),
    );
  }
}
