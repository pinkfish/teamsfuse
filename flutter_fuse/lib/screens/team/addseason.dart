import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/form/seasonformfield.dart';
import '../../widgets/form/switchformfield.dart';
import '../../widgets/util/communityicons.dart';
import '../../widgets/util/savingoverlay.dart';

class AddSeasonScreen extends StatefulWidget {
  AddSeasonScreen(this.teamUid);

  final String teamUid;

  @override
  AddSeasonScreenState createState() {
    return AddSeasonScreenState();
  }
}

class AddSeasonScreenState extends State<AddSeasonScreen> {
  Season _seasonSelect;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _seasonName;
  bool _importPlayers;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Validations _validations = Validations();
  AddSeasonBloc addSeasonBloc;

  @override
  void initState() {
    super.initState();
    addSeasonBloc = AddSeasonBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Make a season.
      ListBuilder<SeasonPlayer> players = ListBuilder<SeasonPlayer>();
      if (_importPlayers) {
        players.addAll(_seasonSelect.players);
      } else {
        PlayerBloc bloc = BlocProvider.of<PlayerBloc>(context);
        var meUid = bloc.state.me.uid;
        players.add(SeasonPlayer((b) => b
          ..playerUid = meUid
          ..role = RoleInTeam.NonPlayer));
      }
      addSeasonBloc.add(AddSeasonEventCommit(
          teamUid: widget.teamUid,
          name: _seasonName,
          players: players.build()));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildResults(BuildContext context, SingleTeamBloc singleTeamBloc) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
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
          SizedBox(height: 40.0),
          SwitchFormField(
            initialValue: false,
            icon: Icons.import_contacts,
            onSaved: (bool b) => _importPlayers = b,
            label: Messages.of(context).importplayers,
          ),
          SeasonFormField(
            decoration: InputDecoration(
              icon: const Icon(CommunityIcons.tshirtCrew),
              labelText: Messages.of(context).copyseasonfrom,
            ),
            teamBloc: singleTeamBloc,
            initialValue: singleTeamBloc.state.team.currentSeason,
            onSaved: (String seasonUid) {
              _seasonSelect = singleTeamBloc.state.getSeason(seasonUid);
            },
          ),
          FlatButton(
            onPressed: _handleSubmit,
            child: Text(Messages.of(context).addseason),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => addSeasonBloc,
      child: SingleTeamProvider(
        teamUid: widget.teamUid,
        builder: (BuildContext contrext, SingleTeamBloc singleTeamBloc) =>
            BlocListener(
          cubit: singleTeamBloc,
          listener: (BuildContext context, SingleTeamState state) {
            if (state is SingleTeamLoaded) {
              if (_seasonSelect == null) {
                _seasonSelect = state.getSeason(state.team.currentSeason);
              }
            }
            if (state is SingleTeamDeleted) {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(Messages.of(context).addseason),
            ),
            backgroundColor: Colors.grey.shade100,
            resizeToAvoidBottomPadding: true,
            body: BlocListener(
              cubit: addSeasonBloc,
              listener: (BuildContext context, AddItemState addState) {
                if (addState is AddItemDone) {
                  Navigator.pop(context);
                }
                if (addState is AddItemSaveFailed) {
                  _showInSnackBar(Messages.of(context).formerror);
                }
              },
              child: BlocBuilder(
                cubit: addSeasonBloc,
                builder: (BuildContext context, AddItemState addState) =>
                    SavingOverlay(
                  saving: addState is AddItemSaving,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Flexible(
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
