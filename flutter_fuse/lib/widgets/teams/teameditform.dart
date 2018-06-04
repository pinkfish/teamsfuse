import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/genderformfield.dart';
import 'package:flutter_fuse/widgets/form/sportformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/playerformfield.dart';
import 'package:flutter_fuse/widgets/form/relationshipformfield.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class TeamEditForm extends StatefulWidget {
  final Team team;

  TeamEditForm(this.team, GlobalKey<TeamEditFormState> key) : super(key: key);

  @override
  TeamEditFormState createState() {
    return new TeamEditFormState(this.team);
  }
}

class TeamEditFormState extends State<TeamEditForm> {
  Team team;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNodeName = new FocusNode();
  FocusNode _focusNodeNotes = new FocusNode();
  FocusNode _focusNodeSeason = new FocusNode();
  FocusNode _focusNodeNewPlayer = new FocusNode();
  File _imageFile;
  bool _changedImage = false;
  String _seasonName = "";
  String _startAdmin = "";
  String _newPlayerName = "";
  Relationship _newPlayerRelationship = Relationship.Friend;

  TeamEditFormState(this.team);

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  Future<bool> validateAndSaveToFirebase() async {
    if (!_formKey.currentState.validate()) {
      return false;
    } else {
      _formKey.currentState.save();

      if (team.uid == null) {
        // If it says to add a new player, then do that.
        Player player;
        if (_startAdmin == 'add') {
          player = new Player();
          player.name = _newPlayerName;
          PlayerUser playerUser = new PlayerUser();
          playerUser.userUid = UserDatabaseData.instance.userUid;
          playerUser.relationship = _newPlayerRelationship;
          player.users[UserDatabaseData.instance.userUid] = playerUser;
          await player.updateFirestore();
          _startAdmin = player.uid;
        } else {
          player = UserDatabaseData.instance.players[_startAdmin];
        }
        team.admins.add(_startAdmin);
        Season season = new Season();
        season.name = _seasonName;
        season.record = new WinRecord();
        season.teamUid = team.precreateUid();
        SeasonPlayer seasonPlayer = new SeasonPlayer();
        seasonPlayer.playerUid = _startAdmin;
        seasonPlayer.role = RoleInTeam.Player;
        seasonPlayer.displayName = player.name;
        seasonPlayer.photoUrl = player.photoUrl;
        season.players.add(seasonPlayer);
        await season.updateFirestore(includePlayers: true);
        team.currentSeason = season.uid;
      }
      await team.updateFirestore();
      if (_changedImage) {
        await team.updateImage(_imageFile);
      }
    }
    return true;
  }

  void _selectImage() async {
    File imgFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      setState(() {
        _imageFile = imgFile;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage() {
    if (!_changedImage) {
      return new TeamImage(team.uid);
    }
    return new Image.file(_imageFile);
  }

  Widget build(BuildContext context) {
    if (team == null) {
      return new Text('Invalid state');
    }

    final Size screenSize = MediaQuery.of(context).size;
    Widget seasonWidget;
    Widget adminWidget;
    Widget adminRelationshipWidget;
    Widget adminNameWidget;
    if (team.uid == null) {
      // Adding a team
      seasonWidget = new EnsureVisibleWhenFocused(
        focusNode: _focusNodeSeason,
        child: new TextFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.event_note),
            hintText: Messages.of(context).season,
            labelText: Messages.of(context).seasonhint,
          ),
          focusNode: _focusNodeSeason,
          initialValue: _seasonName,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (String value) {
            return _validations.validateSeason(context, value);
          },
          onSaved: (String value) {
            _seasonName = value;
          },
        ),
      );
      Map<String, Player> players = UserDatabaseData.instance.players;
      adminWidget = new PlayerFormField(
        decoration: new InputDecoration(
          icon: const Icon(Icons.person),
          hintText: Messages.of(context).playerselecthint,
          labelText: Messages.of(context).playerselect,
        ),
        initialValue: players[players.keys.first].uid,
        validator: (String str) => null,
        onSaved: (String value) {
          _startAdmin = value;
        },
      );
      if (_startAdmin == 'add') {
        adminNameWidget = new EnsureVisibleWhenFocused(
          focusNode: _focusNodeNewPlayer,
          child: new TextFormField(
            decoration: new InputDecoration(
              icon: const Icon(Icons.event_note),
              hintText: Messages.of(context).newplayername,
              labelText: Messages.of(context).newplayernamehint,
            ),
            focusNode: _focusNodeNewPlayer,
            initialValue: _newPlayerName,
            keyboardType: TextInputType.text,
            obscureText: false,
            validator: (String value) {
              return _validations.validateName(context, value);
            },
            onSaved: (String value) {
              team.name = value;
            },
          ),
        );
        adminRelationshipWidget = new RelationshipFormField(
          initialValue: Relationship.Friend,
          onSaved: (Relationship rel) {
            _newPlayerRelationship = rel;
          },
        );
      }
    } else {
      seasonWidget = new SeasonFormField(
        decoration: new InputDecoration(
          icon: const Icon(Icons.calendar_today),
          hintText: Messages.of(context).seasonselect,
          labelText: Messages.of(context).seasonselect,
        ),
        teamUid: team.uid,
        initialValue: team.currentSeason,
        onSaved: (String value) {
          team.currentSeason = value;
        },
      );
    }

    List<Widget> fields = <Widget>[
      new IconButton(
        onPressed: this._selectImage,
        iconSize:
            (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
        icon: this._buildImage(),
      ),
      new EnsureVisibleWhenFocused(
        focusNode: _focusNodeName,
        child: new TextFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.event_note),
            hintText: Messages.of(context).team,
            labelText: Messages.of(context).teamnamehint,
          ),
          focusNode: _focusNodeName,
          initialValue: team.name,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (String value) {
            return _validations.validateDisplayName(context, value);
          },
          onSaved: (String value) {
            team.name = value;
          },
        ),
      ),
      new SportFormField(
        decoration: new InputDecoration(
          icon: const Icon(Icons.people),
          hintText: Messages.of(context).sportselect,
          labelText: Messages.of(context).sportselect,
        ),
        initialValue: team.sport.toString(),
        validator: (String value) {
          return _validations.validateSport(context, value);
        },
        onSaved: (String value) {
          team.sport = Sport.values.firstWhere((e) => e.toString() == value);
        },
      ),
      new GenderFormField(
        decoration: new InputDecoration(
          icon: const Icon(CommunityIcons.gendermalefemale),
          hintText: Messages.of(context).genderselect,
          labelText: Messages.of(context).genderselect,
        ),
        initialValue: team.gender.toString(),
        validator: (String value) {
          return _validations.validateGender(context, value);
        },
        onSaved: (String value) {
          team.gender = Gender.values.firstWhere((e) => e.toString() == value);
        },
      ),
      seasonWidget,
      new EnsureVisibleWhenFocused(
        focusNode: _focusNodeNotes,
        child: new TextFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.event_note),
            hintText: Messages.of(context).league,
            labelText: Messages.of(context).leaguehint,
          ),
          focusNode: _focusNodeNotes,
          initialValue: team.league == null ? '' : team.league,
          keyboardType: TextInputType.text,
          obscureText: false,
          onSaved: (String value) {
            team.league = value;
          },
        ),
      ),
    ];
    if (adminWidget != null) {
      fields.add(adminWidget);
    }
    if (adminNameWidget != null) {
      fields.add(adminNameWidget);
      fields.add(adminRelationshipWidget);
    }

    print('uid ${team.toJSON()}');
    return new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: new DropdownButtonHideUnderline(
              child: new Column(children: fields),
            ),
          ),
        ],
      ),
    );
  }
}
