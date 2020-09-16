import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:fusemodel/fusemodel.dart';

Future<GamePeriodTime> timerSetupDialog(
    BuildContext context, GameResultDetails details) async {
  Messages mess = Messages.of(context);
  GlobalKey<_TimerDetailsState> detailsState = GlobalKey<_TimerDetailsState>();

  GamePeriodTime result = await showDialog<GamePeriodTime>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mess.deleteinvite),
          content: _TimerDetails(details.time, detailsState),
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

class _TimerDetails extends StatefulWidget {
  _TimerDetails(GamePeriodTime periodTime, GlobalKey<_TimerDetailsState> key)
      : _periodTime = periodTime.toBuilder(),
        super(key: key);

  final GamePeriodTimeBuilder _periodTime;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  State createState() {
    return _TimerDetailsState();
  }
}

class _TimerDetailsState extends State<_TimerDetails> {
  GamePeriodTime save() {
    widget._formState.currentState.save();
    return widget._periodTime.build();
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
            children: <Widget>[
              SwitchFormField(
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
