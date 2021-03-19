import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleclubprovider.dart';
import '../../widgets/blocs/singlenewsprovider.dart';
import '../../widgets/clubs/editnewsitemdetails.dart';
import '../../widgets/util/loading.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// The screen to edit the club.
///
class EditNewsItemScreen extends StatefulWidget {
  /// Constructor.
  EditNewsItemScreen(this.clubUid, this.newsItemUid);

  /// Club uid to edit the club for.
  final String clubUid;

  /// The newsItem to edit in the club.
  final String newsItemUid;

  @override
  _EditNewsItemScreenState createState() {
    return _EditNewsItemScreenState();
  }
}

class _EditNewsItemScreenState extends State<EditNewsItemScreen> {
  final GlobalKey<EditNewsItemDetailsFormState> _formKey =
      GlobalKey<EditNewsItemDetailsFormState>();
  bool _doingSave = false;

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(SingleNewsItemBloc singleNewsItemBloc) async {
    try {
      var newsItem = _formKey.currentState.validateAndCreate();
      if (newsItem != null) {
        _doingSave = true;
        singleNewsItemBloc
            .add(SingleNewsItemUpdate(newsItem: newsItem.build()));
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {}
  }

  Widget _buildBody(Club club, SingleNewsItemState state) {
    return SavingOverlay(
      saving: state is SingleClubSaving || state is SingleClubUninitialized,
      child: EditNewsItemDetailsForm(club, state.newsItem, _formKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: widget.clubUid,
      builder: (context, singleClubBloc) => SingleNewsItemProvider(
        clubUid: widget.clubUid,
        newsItemUid: widget.newsItemUid,
        builder: (context, singleNewsItemBloc) => Scaffold(
          appBar: AppBar(
            title: Text(Messages.of(context).title),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _savePressed(singleNewsItemBloc),
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
                  bloc: singleNewsItemBloc,
                  listener: (context, state) {
                    if (state is SingleNewsItemDeleted) {
                      Navigator.pop(context);
                    } else if (state is SingleNewsItemLoaded) {
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
