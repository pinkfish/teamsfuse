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
      new GlobalKey<_ChangeScoreState>();

  GameResultDetailsBuilder result = await showDialog<GameResultDetailsBuilder>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.changescore),
          content: new _ChangeScore(details.toBuilder(), detailsState),
          actions: <Widget>[
            new FlatButton(
              child: new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(detailsState.currentState.save());
              },
            ),
            new FlatButton(
              child:
                  new Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
  final GlobalKey<FormState> _formState = new GlobalKey<FormState>();

  @override
  State createState() {
    return new _ChangeScoreState();
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
      ret.add(new Text(
        Messages.of(context).periodname(result.period),
        style: Theme.of(context)
            .textTheme
            .subhead
            .copyWith(fontWeight: FontWeight.bold),
      ));
      ret.add(new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text(Messages.of(context).forpts),
          new SizedBox(
            width: 5.0,
          ),
          new SizedBox(
            width: 40.0,
            child: new TextFormField(
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
          new Text(Messages.of(context).againstpts),
          new SizedBox(
            width: 5.0,
          ),
          new SizedBox(
            width: 40.0,
            child: new TextFormField(
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
    return new Scrollbar(
      child: new Form(
        key: widget._formState,
        autovalidate: false,
        child: new SingleChildScrollView(
          child: new Column(
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
