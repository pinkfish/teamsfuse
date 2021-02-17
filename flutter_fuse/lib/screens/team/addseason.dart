import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/form/seasonformfield.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add a season to the team, screen setting this up.
///
class AddSeasonScreen extends StatefulWidget {
  /// Constructor.
  AddSeasonScreen(this.teamUid);

  /// The teamUid to add the season for.
  final String teamUid;

  @override
  _AddSeasonScreenState createState() {
    return _AddSeasonScreenState();
  }
}

class _AddSeasonScreenState extends State<AddSeasonScreen> {
  Season _seasonSelect;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _seasonName;
  bool _importPlayers = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Validations _validations = Validations();
  AddSeasonBloc addSeasonBloc;

  @override
  void initState() {
    super.initState();
    addSeasonBloc = AddSeasonBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
        playersBloc: BlocProvider.of<PlayerBloc>(context));
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
      var players = ListBuilder<SeasonPlayer>();
      if (_importPlayers) {
        players.addAll(_seasonSelect.players);
      } else {
        var bloc = BlocProvider.of<PlayerBloc>(context);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: const Icon(Icons.event_note),
              hintText: Messages.of(context).season,
              labelText: Messages.of(context).newseasonhint,
            ),
            validator: (s) {
              String ret = _validations.validateDisplayName(context, s);
            },
            initialValue: '',
            keyboardType: TextInputType.text,
            obscureText: false,
            onSaved: (value) {
              _seasonName = value;
            },
          ),
          SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Switch.adaptive(
                value: _importPlayers ?? false,
                onChanged: (v) => setState(() => _importPlayers = v),
              ),
              InkWell(
                onTap: () => setState(() => _importPlayers = !_importPlayers),
                child: Text(
                  Messages.of(context).importplayers,
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: SeasonFormField(
                    teamBloc: singleTeamBloc,
                    initialValue: singleTeamBloc.state.team.currentSeason,
                    onSaved: (seasonUid) {
                      _seasonSelect = singleTeamBloc.state.getSeason(seasonUid);
                    },
                    validator: (s) {
                      String ret = _importPlayers && s == SeasonFormField.none
                          ? Messages.of(context).seasonrequired
                          : null;
                    },
                  ),
                ),
              ),
            ],
          ),
          ButtonBar(
            children: [
              FlatButton(
                onPressed: _handleSubmit,
                //color: Theme.of(context).buttonTheme.colorScheme.primary,
                child: Text(
                  Messages.of(context).addSeasonButton,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => addSeasonBloc,
      child: SingleTeamProvider(
        teamUid: widget.teamUid,
        builder: (contrext, singleTeamBloc) => BlocListener(
          cubit: singleTeamBloc,
          listener: (context, state) {
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
              title: Text(Messages.of(context).addSeason),
            ),
            backgroundColor: Colors.grey.shade100,
            resizeToAvoidBottomInset: true,
            body: BlocListener(
              cubit: addSeasonBloc,
              listener: (context, addState) {
                if (addState is AddItemDone) {
                  Navigator.pop(context);
                }
                if (addState is AddItemSaveFailed) {
                  _showInSnackBar(Messages.of(context).savefailed);
                }
              },
              child: BlocBuilder(
                cubit: addSeasonBloc,
                builder: (context, addState) => SavingOverlay(
                  saving: addState is AddItemSaving,
                  child: SingleChildScrollView(
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
      ),
    );
  }
}
