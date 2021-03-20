import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add a season to the team, screen setting this up.
///
class EditSeasonScreen extends StatefulWidget {
  /// Constructor.
  EditSeasonScreen(this.seasonUid);

  /// The teamUid to add the season for.
  final String seasonUid;

  @override
  _EditSeasonScreenState createState() {
    return _EditSeasonScreenState();
  }
}

class _EditSeasonScreenState extends State<EditSeasonScreen> {
  Season _seasonSelect;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _seasonName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Validations _validations = Validations();

  @override
  void initState() {
    super.initState();
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  void _handleSubmit(SingleSeasonBloc bloc, SingleSeasonState state) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Make a season.
      var season = state.season.rebuild((b) => b..name = _seasonName);
      bloc.add(SingleSeasonUpdate(season: season));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildResults(BuildContext context, SingleSeasonBloc singleSeasonBloc,
      SingleSeasonState state) {
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
              return _validations.validateDisplayName(context, s);
            },
            initialValue: '',
            keyboardType: TextInputType.text,
            obscureText: false,
            onSaved: (value) {
              _seasonName = value;
            },
          ),
          SizedBox(height: 10.0),
          ButtonBar(
            children: [
              FlatButton(
                onPressed: () => _handleSubmit(singleSeasonBloc, state),
                //color: Theme.of(context).buttonTheme.colorScheme.primary,
                child: Text(
                  Messages.of(context).addSeason,
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
    return SingleSeasonProvider(
      seasonUid: widget.seasonUid,
      builder: (context, singleSeasonBloc) => BlocListener(
        bloc: singleSeasonBloc,
        listener: (context, state) {
          if (state is SingleSeasonDeleted) {
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
          body: BlocBuilder(
            bloc: singleSeasonBloc,
            builder: (context, seasonState) =>
                seasonState is SingleSeasonUninitialized
                    ? LoadingWidget()
                    : SavingOverlay(
                        saving: seasonState is SingleSeasonSaving,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 0,
                                child: _buildResults(
                                    context, singleSeasonBloc, seasonState),
                              )
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
