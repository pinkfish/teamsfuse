import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/messages.dart';

///
/// Shows a dialog to change the score.
///
Future<GameResultDetailsBuilder> changeScoreDialog(
    BuildContext context, GameResultDetails details) async {
  var mess = Messages.of(context);
  var detailsState = GlobalKey<_ChangeScoreState>();

  var result = await showDialog<GameResultDetailsBuilder>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
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
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
    var ret = <Widget>[];
    for (var period in widget._details.scores.build().keys) {
      var result = widget._details.scores[period];
      ret.add(Text(
        Messages.of(context).periodname(result.period),
        style: Theme.of(context)
            .textTheme
            .subtitle1
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
              onSaved: (str) {
                var builder = result.score.toBuilder();
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
              onSaved: (str) {
                var builder = result.score.toBuilder();
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
