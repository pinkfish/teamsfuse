import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/messages.dart';
import '../../form/switchformfield.dart';

///
/// Setup the time, using an exciting dialog.
///
Future<GamePeriodTime> timerSetupDialog(
    BuildContext context, GameResultDetails details) async {
  var mess = Messages.of(context);
  var detailsState = GlobalKey<_TimerDetailsState>();

  var result = await showDialog<GamePeriodTime>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(mess.deleteInvite),
          content: _TimerDetails(details.time, detailsState),
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
        autovalidateMode: AutovalidateMode.disabled,
        key: widget._formState,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SwitchFormField(
                label: Messages.of(context).timerCountUp,
                initialValue: widget._periodTime.timeCountUp,
                onSaved: (value) => widget._periodTime.timeCountUp = value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
