import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:map_view/map_view.dart';
import 'dart:async';

class TrainingEditForm extends StatefulWidget {
  final Game game;

  TrainingEditForm({this.game, GlobalKey<TrainingEditFormState> key})
      : super(key: key);

  @override
  TrainingEditFormState createState() {
    return new TrainingEditFormState();
  }
}

class TrainingEditFormState extends State<TrainingEditForm> {
  ScrollController _scrollController = new ScrollController();
  bool autoValidate = false;
  GlobalKey<FormState> _formState = new GlobalKey<FormState>();
  DateTime _atDate;

  void save() {}

  @override
  void initState() {
    super.initState();
    _atDate = new DateTime.fromMillisecondsSinceEpoch(widget.game.time);
  }

  bool validate() {
    return _formState.currentState.validate();
  }

  Future<bool> validateAndSaveToFirebase() async {
    if (_formState.currentState.validate()) {
      _formState.currentState.save();
      widget.game.time = _atDate.millisecondsSinceEpoch;
      await widget.game.updateFirestore();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);
    print("${widget.game.toJSON()}");
    return new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      child: new Form(
        key: _formState,
        autovalidate: autoValidate,
        child: new DropdownButtonHideUnderline(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new SeasonFormField(
                decoration: new InputDecoration(
                  icon: const Icon(CommunityIcons.calendarquestion),
                  labelText: messages.season,
                ),
                initialValue: widget.game.seasonUid,
                teamUid: widget.game.teamUid,
                onSaved: (String value) {
                  widget.game.seasonUid = value;
                },
              ),
              new DateTimeFormField(
                labelText: Messages.of(context).gametime,
                decoration: new InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                ),
                initialValue: _atDate,
                hideDate: false,
                onSaved: (DateTime value) {
                  _atDate = value;
                },
              ),
              new FlatButton(
                onPressed: () {
                  MapView
                      .openPlacePickerModal()
                      .then((Map<String, dynamic> val) {
                    print('places ret $val');
                  }).catchError((Object err) {
                    print('$err Error!');
                  });
                },
                child: new ListTile(
                  leading: const Icon(Icons.place),
                  title: new Text(widget.game.place.name == null
                      ? messages.unknown
                      : widget.game.place.name),
                  subtitle: new Text(widget.game.place.address == null
                      ? messages.unknown
                      : widget.game.place.address),
                ),
              ),
              new TextFormField(
                initialValue: widget.game.notes,
                decoration: new InputDecoration(
                  hintText: messages.trainingnoteshint,
                  labelText: messages.trainingnotes,
                  icon: const Icon(Icons.note),
                ),
                onSaved: (String value) {
                  widget.game.notes = value;
                },
              ),
              new TextFormField(
                initialValue: widget.game.uniform,
                decoration: new InputDecoration(
                    hintText: messages.uniformhint,
                    labelText: messages.uniform,
                    icon: const Icon(CommunityIcons.tshirtcrew)),
                onSaved: (String value) {
                  widget.game.uniform = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
