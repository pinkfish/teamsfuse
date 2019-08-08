import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/util/savingoverlay.dart';

class AddSeasonScreen extends StatefulWidget {
  AddSeasonScreen(this.teamUid);

  final String teamUid;

  @override
  AddSeasonScreenState createState() {
    return new AddSeasonScreenState();
  }
}

class AddSeasonScreenState extends State<AddSeasonScreen> {
  Season _seasonSelect;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _seasonName;
  bool _importPlayers;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Validations _validations = new Validations();
  AddSeasonBloc addSeasonBloc;

  @override
  void initState() {
    super.initState();
    addSeasonBloc = AddSeasonBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(value),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Make a new season.
      ListBuilder<SeasonPlayer> players = ListBuilder<SeasonPlayer>();
      if (_importPlayers) {
        players.addAll(_seasonSelect.players);
      } else {
        PlayerBloc bloc = BlocProvider.of<PlayerBloc>(context);
        var meUid = bloc.currentState.me.uid;
        players.add(SeasonPlayer((b) => b
          ..playerUid = meUid
          ..role = RoleInTeam.NonPlayer));
      }
      addSeasonBloc.dispatch(AddSeasonEventCommit(
          teamUid: widget.teamUid, name: _seasonName, players: players));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildResults(BuildContext context, SingleTeamBloc singleTeamBloc) {
    return Form(
      key: _formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new TextFormField(
            decoration: new InputDecoration(
              icon: const Icon(Icons.event_note),
              hintText: Messages.of(context).season,
              labelText: Messages.of(context).newseasonhint,
            ),
            validator: (String s) =>
                _validations.validateDisplayName(context, s),
            initialValue: '',
            keyboardType: TextInputType.text,
            obscureText: false,
            onSaved: (String value) {
              _seasonName = value;
            },
          ),
          new SizedBox(height: 40.0),
          new SwitchFormField(
            initialValue: false,
            icon: Icons.import_contacts,
            onSaved: (bool b) => _importPlayers = b,
            label: Messages.of(context).importplayers,
          ),
          new SeasonFormField(
            decoration: new InputDecoration(
              icon: const Icon(CommunityIcons.tshirtCrew),
              labelText: Messages.of(context).copyseasonfrom,
            ),
            teamBloc: singleTeamBloc,
            initialValue: singleTeamBloc.currentState.team.currentSeason,
            onSaved: (String seasonUid) {
              _seasonSelect =
                  singleTeamBloc.currentState.team.seasons[seasonUid];
            },
          ),
          new FlatButton(
            onPressed: _handleSubmit,
            child: new Text(Messages.of(context).addseason),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (BuildContext context) => addSeasonBloc,
      child: SingleTeamProvider(
        teamUid: widget.teamUid,
        builder: (BuildContext contrext, SingleTeamBloc singleTeamBloc) =>
            BlocListener(
          bloc: singleTeamBloc,
          listener: (BuildContext context, SingleTeamState state) {
            if (state is SingleTeamLoaded) {
              if (_seasonSelect == null) {
                _seasonSelect = state.team.seasons[state.team.currentSeason];
              }
            }
            if (state is SingleTeamDeleted) {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            appBar: new AppBar(
              title: new Text(Messages.of(context).addseason),
            ),
            backgroundColor: Colors.grey.shade100,
            resizeToAvoidBottomPadding: true,
            body: BlocListener(
              bloc: addSeasonBloc,
              listener: (BuildContext context, AddItemState addState) {
                if (addState is AddItemDone) {
                  Navigator.pop(context);
                }
                if (addState is AddItemSaveFailed) {
                  _showInSnackBar(Messages.of(context).formerror);
                }
              },
              child: BlocBuilder(
                bloc: addSeasonBloc,
                builder: (BuildContext context, AddItemState addState) =>
                    SavingOverlay(
                  saving: addState is AddItemSaving,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Flexible(
                        fit: FlexFit.tight,
                        flex: 0,
                        child: _buildResults(context, singleTeamBloc),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
