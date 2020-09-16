import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Shows a dialog to change the score.
///
Future<GameResultDetailsBuilder> changeScoreDialog(
    BuildContext context, GameResultDetails details) async {
  Messages mess = Messages.of(context);
  GlobalKey<_ChangeScoreState> detailsState =
      GlobalKey<_ChangeScoreState>();

  GameResultDetailsBuilder result = await showDialog<GameResultDetailsBuilder>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mess.changescore),
          content: _ChangeScore(details.toBuilder(), detailsState),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(detailsState.currentState.save());
              },
            ),
            FlatButton(
              child:
                  Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      });
  return result;
}

class _ChangeScore extends StatefulWidget {
  _ChangeScore(this._details, GlobalKey<_ChangeScoreState> key)
      : super(key: key);

  final GameResultDetailsBuilder _details;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  State createState() {
    return _ChangeScoreState();
  }
}

class _ChangeScoreState extends State<_ChangeScore> {
  GameResultDetailsBuilder save() {
    widget._formState.currentState.save();
    return widget._details;
  }

  List<Widget> _buildScores() {
    List<Widget> ret = <Widget>[];
    for (GamePeriod period in widget._details.scores.build().keys) {
      GameResultPerPeriod result = widget._details.scores[period];
      ret.add(Text(
        Messages.of(context).periodname(result.period),
        style: Theme.of(context)
            .textTheme
            .subhead
            .copyWith(fontWeight: FontWeight.bold),
      ));
      ret.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(Messages.of(context).forpts),
          SizedBox(
            width: 5.0,
          ),
          SizedBox(
            width: 40.0,
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: result.score.ptsFor.toString(),
              onSaved: (String str) {
                GameScoreBuilder builder = result.score.toBuilder();
                builder.ptsFor = int.parse(str);
                widget._details.scores[period] =
                    result.rebuild((b) => b..score = builder);
              },
            ),
          ),
          Text(Messages.of(context).againstpts),
          SizedBox(
            width: 5.0,
          ),
          SizedBox(
            width: 40.0,
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: result.score.ptsAgainst.toString(),
              onSaved: (String str) {
                GameScoreBuilder builder = result.score.toBuilder();
                builder.ptsAgainst = int.parse(str);
                widget._details.scores[period] =
                    result.rebuild((b) => b..score = builder);
              },
            ),
          ),
        ],
      ));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Form(
        key: widget._formState,
        autovalidate: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _buildScores(),
          ),
        ),
      ),
    );
  }
}
