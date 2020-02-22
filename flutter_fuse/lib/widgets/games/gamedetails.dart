import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/attendancedialog.dart';
import 'package:flutter_fuse/widgets/games/editresultdialog.dart';
import 'package:flutter_fuse/widgets/games/multipleattendencedialog.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/savingoverlay.dart';
import 'gamedetailsbase.dart';
import 'officalresultdialog.dart';

class GameDetails extends StatefulWidget {
  GameDetails(this.gameBloc, {this.adding = false});

  final SingleGameBloc gameBloc;
  final bool adding;

  @override
  GameDetailsState createState() {
    return new GameDetailsState();
  }
}

class GameDetailsState extends State<GameDetails> {
  void openNavigation(Game game) {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" + Uri.encodeComponent(game.sharedData.place.address);
    if (game.sharedData.place.placeId != null) {
      url += "&destination_place_id=" +
          Uri.encodeComponent(game.sharedData.place.placeId);
    }
    launch(url);
  }

  void _editResult(Game game) async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        print("$widget");
        return new EditResultDialog(widget.gameBloc);
      },
    );
  }

  void _openAttendance(Game game, Map<Player, Attendance> attendence) async {
    if (attendence.length == 1) {
      // Do a simple picker popup.
      Player player = attendence.keys.first;
      Attendance current = attendence[player];

      Attendance attend = await showDialog<Attendance>(
          context: context,
          builder: (BuildContext context) {
            return new AttendanceDialog(current: current);
          });
      if (attend != null) {
        widget.gameBloc.add(SingleGameUpdateAttendance(
            playerUid: player.uid, attendance: attend));
      }
    } else {
      Map<Player, Attendance> attend = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new MultipleAttendanceDialog(attendence);
        },
      );
      if (attend != null) {
        attend.forEach((Player player, Attendance attend) {
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
    LeagueOrTournamentBloc leagueOrTournamentBloc =
        BlocProvider.of<LeagueOrTournamentBloc>(context);

    if (leagueOrTournamentBloc.state.leagueOrTournaments
        .containsKey(sharedData.leagueUid)) {
      if (leagueOrTournamentBloc.state.leagueOrTournaments[sharedData.leagueUid]
          .isAdmin()) {
        // Show it and forget it.
        showDialog<bool>(
            context: context,
            builder: (BuildContext context) =>
                OfficialResultDialog(sharedData));
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
    bool ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Messages.of(context).useofficialresultbutton),
            content: RichText(
                text: TextSpan(
                    text: Messages.of(context).useofficialresultdialog,
                    children: <TextSpan>[
                  TextSpan(text: Messages.of(context).resultinprogress(details))
                ])),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () => Navigator.pop(context, true),
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          );
        });
    if (ret != null && ret) {
      // Copy the result over and save.
      GameResultDetailsBuilder newResult = GameResultDetailsBuilder();
      newResult.scores[GamePeriod.regulation] = details.regulationResult;
      if (details.overtimeResult != null) {
        newResult.scores[GamePeriod.overtime] = details.overtimeResult;
      }
      if (details.penaltyResult != null) {
        newResult.scores[GamePeriod.penalty] = details.penaltyResult;
      }
      newResult.result = details.result;
      widget.gameBloc.add(SingleGameUpdateResult(result: newResult.build()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: widget.gameBloc,
      listener: (BuildContext context, SingleGameState state) {
        if (state is SingleGameDeleted) {
          Navigator.pop(context);
        }

        if (state is SingleGameSaveFailed) {}
      },
      child: BlocBuilder(
        bloc: widget.gameBloc,
        builder: (BuildContext context, SingleGameState state) {
          if (state is SingleGameDeleted) {
            return CircularProgressIndicator();
          }
          return SavingOverlay(
            saving: state is SingleGameSaving,
            child: GameDetailsBase(
              game: state.game,
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
