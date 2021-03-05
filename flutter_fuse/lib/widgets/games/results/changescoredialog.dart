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
          content: _ChangeScore(details, detailsState),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(detailsState.currentState.save());
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        );
      });
  return result;
}

class _ChangeScore extends StatefulWidget {
  _ChangeScore(this._details, GlobalKey<_ChangeScoreState> key)
      : super(key: key);

  final GameResultDetails _details;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  State createState() {
    return _ChangeScoreState();
  }
}

class _ChangeScoreState extends State<_ChangeScore> {
  GameResultDetailsBuilder _builder;

  GameResultDetailsBuilder save() {
    widget._formState.currentState.save();
    return _builder;
  }

  List<Widget> _buildScores() {
    var ret = <Widget>[];
    for (var period in _builder.scoresInternal.build().keys) {
      var result = widget._details.scoresInternal[period];
      ret.add(Text(
        Messages.of(context).periodName(result.period),
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
                _builder.scoresInternal[period] =
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
                _builder.scoresInternal[period] =
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
        autovalidateMode: AutovalidateMode.disabled,
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
