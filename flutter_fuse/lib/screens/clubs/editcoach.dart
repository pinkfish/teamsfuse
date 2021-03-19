import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleclubcoachprovider.dart';
import '../../widgets/blocs/singleclubprovider.dart';
import '../../widgets/clubs/editcoachdetails.dart';
import '../../widgets/util/loading.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// The screen to edit the club.
///
class EditCoachScreen extends StatefulWidget {
  /// Constructor.
  EditCoachScreen(this.clubUid, this.coachUid);

  /// Club uid to edit the club for.
  final String clubUid;

  /// The coach to edit in the club.
  final String coachUid;

  @override
  _EditCoachScreenState createState() {
    return _EditCoachScreenState();
  }
}

class _EditCoachScreenState extends State<EditCoachScreen> {
  final GlobalKey<EditCoachDetailsFormState> _formKey =
      GlobalKey<EditCoachDetailsFormState>();
  bool _doingSave = false;

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(SingleClubCoachBloc singleCoachBloc) async {
    try {
      var coach = _formKey.currentState.validateAndCreate();
      var imageFile = _formKey.currentState.getImageFile();
      if (coach != null) {
        _doingSave = true;
        singleCoachBloc
            .add(SingleClubCoachUpdate(coach: coach.build(), image: imageFile));
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {}
  }

  Widget _buildBody(Club club, SingleClubCoachState state) {
    return SavingOverlay(
      saving: state is SingleClubSaving || state is SingleClubUninitialized,
      child: EditCoachDetailsForm(club, state.coach, _formKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: widget.clubUid,
      builder: (context, singleClubBloc) => SingleClubCoachProvider(
        clubUid: widget.clubUid,
        coachUid: widget.coachUid,
        builder: (context, singleCoachBloc) => Scaffold(
          appBar: AppBar(
            title: Text(Messages.of(context).title),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _savePressed(singleCoachBloc),
            child: Icon(Icons.check),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: BlocConsumer(
              bloc: singleClubBloc,
              listener: (context, clubState) {
                if (clubState is SingleClubDeleted) {
                  Navigator.pop(context);
                }
              },
              builder: (context, clubState) {
                if (clubState is SingleClubUninitialized ||
                    clubState is SingleClubDeleted) {
                  return LoadingWidget();
                }

                return BlocConsumer(
                  bloc: singleCoachBloc,
                  listener: (context, state) {
                    if (state is SingleClubCoachDeleted) {
                      Navigator.pop(context);
                    } else if (state is SingleClubCoachLoaded) {
                      // finished saving.
                      if (_doingSave) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  builder: (context, state) {
                    return _buildBody(clubState.club, state);
                  },
                );
              }),
        ),
      ),
    );
  }
}
