import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:fusemodel/fusemodel.dart';

Future<GamePeriodTime> timerSetupDialog(
    BuildContext context, GameResultDetails details) async {
  Messages mess = Messages.of(context);
  GlobalKey<_TimerDetailsState> detailsState =
      new GlobalKey<_TimerDetailsState>();

  GamePeriodTime result = await showDialog<GamePeriodTime>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteinvite),
          content: new _TimerDetails(details.time, detailsState),
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

class _TimerDetails extends StatefulWidget {
  _TimerDetails(GamePeriodTime periodTime, GlobalKey<_TimerDetailsState> key)
      : _periodTime = new GamePeriodTime.copy(periodTime),
        super(key: key);

  final GamePeriodTime _periodTime;
  final GlobalKey<FormState> _formState = new GlobalKey<FormState>();

  @override
  State createState() {
    return new _TimerDetailsState();
  }
}

class _TimerDetailsState extends State<_TimerDetails> {
  GamePeriodTime save() {
    widget._formState.currentState.save();
    return widget._periodTime;
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
            children: <Widget>[
              new SwitchFormField(
                label: Messages.of(context).timercountup,
                initialValue: widget._periodTime.timeCountUp,
                onSaved: (bool value) => widget._periodTime.timeCountUp = value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
