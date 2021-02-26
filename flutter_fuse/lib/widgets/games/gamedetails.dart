import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../games/attendancedialog.dart';
import '../games/editresultdialog.dart';
import '../games/multipleattendencedialog.dart';
import '../util/savingoverlay.dart';
import 'gamedetailsbase.dart';
import 'officalresultdialog.dart';

///
/// Show the details of the game in the main screen page.
/// Lots of details.
///
class GameDetails extends StatefulWidget {
  /// Constrcutor.
  GameDetails(this.gameBloc, {this.adding = false});

  /// The game bloc to show the details for.
  final SingleGameBloc gameBloc;

  /// If we are adding this game or not.
  final bool adding;

  @override
  _GameDetailsState createState() {
    return _GameDetailsState();
  }
}

class _GameDetailsState extends State<GameDetails> {
  void openNavigation(Game game) {
    var url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=${Uri.encodeComponent(game.sharedData.place.address)}";
    if (game.sharedData.place.placeId != null) {
      url +=
          "&destination_place_id=${Uri.encodeComponent(game.sharedData.place.placeId)}";
    }
    launch(url);
  }

  void _editResult(Game game) async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditResultDialog(widget.gameBloc);
      },
    );
  }

  void _openAttendance(Game game, Map<Player, Attendance> attendence) async {
    if (attendence.length == 1) {
      // Do a simple picker popup.
      var player = attendence.keys.first;
      var current = attendence[player];

      var attend = await showDialog<Attendance>(
          context: context,
          builder: (context) {
            return AttendanceDialog(current: current);
          });
      if (attend != null) {
        widget.gameBloc.add(SingleGameUpdateAttendance(
            playerUid: player.uid, attendance: attend));
      }
    } else {
      var attend = await showDialog(
        context: context,
        builder: (context) {
          return MultipleAttendanceDialog(attendence);
        },
      );
      if (attend != null) {
        attend.forEach((player, attend) {
          widget.gameBloc.add(SingleGameUpdateAttendance(
              playerUid: player.uid, attendance: attend));
        });
      }
    }
  }

  ///
  /// Try and edit the offical results, this is only possible if the
  /// user is an admin for the league itself.  Otherwise we can
  /// ask if they want to copy the results.
  ///
  void _editOfficialResult(
      GameSharedData sharedData, GameResultSharedDetails offical) {
    var leagueOrTournamentBloc =
        BlocProvider.of<LeagueOrTournamentBloc>(context);

    if (leagueOrTournamentBloc.state.leagueOrTournaments
        .containsKey(sharedData.leagueUid)) {
      if (leagueOrTournamentBloc.state.leagueOrTournaments[sharedData.leagueUid]
          .isAdmin()) {
        // Show it and forget it.
        showDialog<bool>(
            context: context,
            builder: (context) => OfficialResultDialog(sharedData));
        return;
      }
    }
    _copyOfficialResult(sharedData, offical);
  }

  ///
  /// Copy the current score/stuff from the official results.
  ///
  void _copyOfficialResult(
      GameSharedData sharedData, GameResultSharedDetails details) async {
    var ret = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Messages.of(context).useofficialresultbutton),
            content: RichText(
                text: TextSpan(
                    text: Messages.of(context).useofficialresultdialog,
                    children: <TextSpan>[
                  TextSpan(text: Messages.of(context).resultInProgress(details))
                ])),
            actions: <Widget>[
              TextButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          );
        });
    if (ret != null && ret) {
      // Copy the result over and save.
      var newResult = GameResultDetailsBuilder();
      newResult.scoresInternal[GamePeriod.regulation1] =
          details.regulationResult;
      if (details.overtimeResult != null) {
        newResult.scoresInternal[GamePeriod.overtime1] = details.overtimeResult;
      }
      if (details.penaltyResult != null) {
        newResult.scoresInternal[GamePeriod.penalty] = details.penaltyResult;
      }
      newResult.result = details.result;
      widget.gameBloc.add(SingleGameUpdateResult(result: newResult.build()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: widget.gameBloc,
      listener: (context, state) {
        if (state is SingleGameDeleted) {
          Navigator.pop(context);
        }

        if (state is SingleGameSaveFailed) {}
      },
      child: BlocBuilder(
        cubit: widget.gameBloc,
        builder: (context, state) {
          if (state is SingleGameDeleted) {
            return CircularProgressIndicator();
          }
          return SavingOverlay(
            saving: state is SingleGameSaving,
            child: GameDetailsBase(
              gameState: state,
              adding: widget.adding,
              editResult: _editResult,
              editOfficialResult: _editOfficialResult,
              openNavigation: openNavigation,
              openAttendence: _openAttendance,
              copyOfficalResult: _copyOfficialResult,
            ),
          );
        },
      ),
    );
  }
}
