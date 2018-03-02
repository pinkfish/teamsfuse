// GENERATED CODE - DO NOT MODIFY BY HAND

part of services.databasedetails;

// **************************************************************************
// Generator: DsonGenerator
// **************************************************************************

abstract class _$RoleInTeamSerializable extends SerializableMap {
  int get index;

  String toString();

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'toString':
        return toString;
    }
    throwFieldNotFoundException(__key, 'RoleInTeam');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'RoleInTeam');
  }

  Iterable<String> get keys => RoleInTeamClassMirror.fields.keys;
}

abstract class _$SportSerializable extends SerializableMap {
  int get index;

  String toString();

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'toString':
        return toString;
    }
    throwFieldNotFoundException(__key, 'Sport');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'Sport');
  }

  Iterable<String> get keys => SportClassMirror.fields.keys;
}

abstract class _$GenderSerializable extends SerializableMap {
  int get index;

  String toString();

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'toString':
        return toString;
    }
    throwFieldNotFoundException(__key, 'Gender');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'Gender');
  }

  Iterable<String> get keys => GenderClassMirror.fields.keys;
}

abstract class _$EventTypeSerializable extends SerializableMap {
  int get index;

  String toString();

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'toString':
        return toString;
    }
    throwFieldNotFoundException(__key, 'EventType');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'EventType');
  }

  Iterable<String> get keys => EventTypeClassMirror.fields.keys;
}

abstract class _$GameResultSerializable extends SerializableMap {
  int get index;

  String toString();

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'toString':
        return toString;
    }
    throwFieldNotFoundException(__key, 'GameResult');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'GameResult');
  }

  Iterable<String> get keys => GameResultClassMirror.fields.keys;
}

abstract class _$UpdateReasonSerializable extends SerializableMap {
  int get index;

  String toString();

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'toString':
        return toString;
    }
    throwFieldNotFoundException(__key, 'UpdateReason');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'UpdateReason');
  }

  Iterable<String> get keys => UpdateReasonClassMirror.fields.keys;
}

abstract class _$PlayerSerializable extends SerializableMap {
  String get name;
  String get uid;
  Stream<QuerySnapshot> get _snapshot;
  void set name(String v);
  void set uid(String v);
  void set _snapshot(Stream<QuerySnapshot> v);
  void updateFrom(Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'name':
        return name;
      case 'uid':
        return uid;
      case '_snapshot':
        return _snapshot;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'Player');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'name':
        name = __value;
        return;
      case 'uid':
        uid = __value;
        return;
      case '_snapshot':
        _snapshot = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Player');
  }

  Iterable<String> get keys => PlayerClassMirror.fields.keys;
}

abstract class _$GameResultDetailsSerializable extends SerializableMap {
  int get ptsFor;
  int get ptsAgainst;
  GameResult get result;
  void set ptsFor(int v);
  void set ptsAgainst(int v);
  void set result(GameResult v);
  void updateFrom(Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'ptsFor':
        return ptsFor;
      case 'ptsAgainst':
        return ptsAgainst;
      case 'result':
        return result;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'GameResultDetails');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'ptsFor':
        ptsFor = __value;
        return;
      case 'ptsAgainst':
        ptsAgainst = __value;
        return;
      case 'result':
        result = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'GameResultDetails');
  }

  Iterable<String> get keys => GameResultDetailsClassMirror.fields.keys;
}

abstract class _$GamePlaceSerializable extends SerializableMap {
  String get name;
  String get placeId;
  String get address;
  String get notes;
  void set name(String v);
  void set placeId(String v);
  void set address(String v);
  void set notes(String v);
  void updateFrom(Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'name':
        return name;
      case 'placeId':
        return placeId;
      case 'address':
        return address;
      case 'notes':
        return notes;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'GamePlace');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'name':
        name = __value;
        return;
      case 'placeId':
        placeId = __value;
        return;
      case 'address':
        address = __value;
        return;
      case 'notes':
        notes = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'GamePlace');
  }

  Iterable<String> get keys => GamePlaceClassMirror.fields.keys;
}

abstract class _$GameSerializable extends SerializableMap {
  String get uid;
  String get name;
  TZDateTime get time;
  Location get timezone;
  int get arriveEarly;
  int get gameLength;
  String get notes;
  String get opponentUid;
  String get teamUid;
  String get uniform;
  EventType get type;
  GameResultDetails get result;
  GamePlace get place;
  void set uid(String v);
  void set name(String v);
  void set time(TZDateTime v);
  void set timezone(Location v);
  void set arriveEarly(int v);
  void set gameLength(int v);
  void set notes(String v);
  void set opponentUid(String v);
  void set teamUid(String v);
  void set uniform(String v);
  void set type(EventType v);
  void set result(GameResultDetails v);
  void set place(GamePlace v);
  void updateFrom(String teamuid, Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'uid':
        return uid;
      case 'name':
        return name;
      case 'time':
        return time;
      case 'timezone':
        return timezone;
      case 'arriveEarly':
        return arriveEarly;
      case 'gameLength':
        return gameLength;
      case 'notes':
        return notes;
      case 'opponentUid':
        return opponentUid;
      case 'teamUid':
        return teamUid;
      case 'uniform':
        return uniform;
      case 'type':
        return type;
      case 'result':
        return result;
      case 'place':
        return place;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'Game');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'uid':
        uid = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'time':
        time = __value;
        return;
      case 'timezone':
        timezone = __value;
        return;
      case 'arriveEarly':
        arriveEarly = __value;
        return;
      case 'gameLength':
        gameLength = __value;
        return;
      case 'notes':
        notes = __value;
        return;
      case 'opponentUid':
        opponentUid = __value;
        return;
      case 'teamUid':
        teamUid = __value;
        return;
      case 'uniform':
        uniform = __value;
        return;
      case 'type':
        type = __value;
        return;
      case 'result':
        result = __value;
        return;
      case 'place':
        place = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Game');
  }

  Iterable<String> get keys => GameClassMirror.fields.keys;
}

abstract class _$WinRecordSerializable extends SerializableMap {
  int get win;
  int get loss;
  int get tie;
  void set win(int v);
  void set loss(int v);
  void set tie(int v);
  void updateFrom(Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'win':
        return win;
      case 'loss':
        return loss;
      case 'tie':
        return tie;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'WinRecord');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'win':
        win = __value;
        return;
      case 'loss':
        loss = __value;
        return;
      case 'tie':
        tie = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'WinRecord');
  }

  Iterable<String> get keys => WinRecordClassMirror.fields.keys;
}

abstract class _$OpponentSerializable extends SerializableMap {
  String get name;
  String get contact;
  String get uid;
  WinRecord get record;
  void set name(String v);
  void set contact(String v);
  void set uid(String v);
  void set record(WinRecord v);
  void updateFrom(Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'name':
        return name;
      case 'contact':
        return contact;
      case 'uid':
        return uid;
      case 'record':
        return record;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'Opponent');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'name':
        name = __value;
        return;
      case 'contact':
        contact = __value;
        return;
      case 'uid':
        uid = __value;
        return;
      case 'record':
        record = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Opponent');
  }

  Iterable<String> get keys => OpponentClassMirror.fields.keys;
}

abstract class _$SeasonPlayerSerializable extends SerializableMap {
  String get playerUid;
  RoleInTeam get role;
  void set playerUid(String v);
  void set role(RoleInTeam v);
  void updateFrom(Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'playerUid':
        return playerUid;
      case 'role':
        return role;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'SeasonPlayer');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'playerUid':
        playerUid = __value;
        return;
      case 'role':
        role = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'SeasonPlayer');
  }

  Iterable<String> get keys => SeasonPlayerClassMirror.fields.keys;
}

abstract class _$SeasonSerializable extends SerializableMap {
  String get name;
  String get uid;
  WinRecord get record;
  List<SeasonPlayer> get players;
  void set name(String v);
  void set uid(String v);
  void set record(WinRecord v);
  void set players(List<SeasonPlayer> v);
  void updateFrom(Map<String, dynamic> data);

  operator [](Object __key) {
    switch (__key) {
      case 'name':
        return name;
      case 'uid':
        return uid;
      case 'record':
        return record;
      case 'players':
        return players;
      case 'updateFrom':
        return updateFrom;
    }
    throwFieldNotFoundException(__key, 'Season');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'name':
        name = __value;
        return;
      case 'uid':
        uid = __value;
        return;
      case 'record':
        record = __value;
        return;
      case 'players':
        players = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Season');
  }

  Iterable<String> get keys => SeasonClassMirror.fields.keys;
}

abstract class _$TeamSerializable extends SerializableMap {
  String get name;
  int get earlyArrival;
  String get currentSeason;
  Gender get gender;
  String get league;
  Sport get sport;
  String get uid;
  WinRecord get record;
  List<String> get admins;
  Map<String, Opponent> get opponents;
  Map<String, Season> get seasons;
  Stream<UpdateReason> get opponentStream;
  Stream<UpdateReason> get thisTeamStream;
  StreamController<UpdateReason> get _opponentController;
  StreamController<UpdateReason> get _updateThisTeam;
  StreamSubscription<DocumentSnapshot> get _teamSnapshot;
  StreamSubscription<QuerySnapshot> get _gameSnapshot;
  StreamSubscription<QuerySnapshot> get _opponentSnapshot;
  void set name(String v);
  void set earlyArrival(int v);
  void set currentSeason(String v);
  void set gender(Gender v);
  void set league(String v);
  void set sport(Sport v);
  void set uid(String v);
  void set record(WinRecord v);
  void set admins(List<String> v);
  void set opponents(Map<String, Opponent> v);
  void set seasons(Map<String, Season> v);
  void set opponentStream(Stream<UpdateReason> v);
  void set thisTeamStream(Stream<UpdateReason> v);
  void set _opponentController(StreamController<UpdateReason> v);
  void set _updateThisTeam(StreamController<UpdateReason> v);
  void set _teamSnapshot(StreamSubscription<DocumentSnapshot> v);
  void set _gameSnapshot(StreamSubscription<QuerySnapshot> v);
  void set _opponentSnapshot(StreamSubscription<QuerySnapshot> v);
  void _onOpponentUpdated(QuerySnapshot query);
  void _onTeamUpdated(DocumentSnapshot snap);
  void updateSeason(DocumentSnapshot doc);
  void setupSnap();

  operator [](Object __key) {
    switch (__key) {
      case 'name':
        return name;
      case 'earlyArrival':
        return earlyArrival;
      case 'currentSeason':
        return currentSeason;
      case 'gender':
        return gender;
      case 'league':
        return league;
      case 'sport':
        return sport;
      case 'uid':
        return uid;
      case 'record':
        return record;
      case 'admins':
        return admins;
      case 'opponents':
        return opponents;
      case 'seasons':
        return seasons;
      case 'opponentStream':
        return opponentStream;
      case 'thisTeamStream':
        return thisTeamStream;
      case '_opponentController':
        return _opponentController;
      case '_updateThisTeam':
        return _updateThisTeam;
      case '_teamSnapshot':
        return _teamSnapshot;
      case '_gameSnapshot':
        return _gameSnapshot;
      case '_opponentSnapshot':
        return _opponentSnapshot;
      case '_onOpponentUpdated':
        return _onOpponentUpdated;
      case '_onTeamUpdated':
        return _onTeamUpdated;
      case 'updateSeason':
        return updateSeason;
      case 'setupSnap':
        return setupSnap;
    }
    throwFieldNotFoundException(__key, 'Team');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'name':
        name = __value;
        return;
      case 'earlyArrival':
        earlyArrival = __value;
        return;
      case 'currentSeason':
        currentSeason = __value;
        return;
      case 'gender':
        gender = __value;
        return;
      case 'league':
        league = __value;
        return;
      case 'sport':
        sport = __value;
        return;
      case 'uid':
        uid = __value;
        return;
      case 'record':
        record = __value;
        return;
      case 'admins':
        admins = __value;
        return;
      case 'opponents':
        opponents = __value;
        return;
      case 'seasons':
        seasons = __value;
        return;
      case 'opponentStream':
        opponentStream = __value;
        return;
      case 'thisTeamStream':
        thisTeamStream = __value;
        return;
      case '_opponentController':
        _opponentController = __value;
        return;
      case '_updateThisTeam':
        _updateThisTeam = __value;
        return;
      case '_teamSnapshot':
        _teamSnapshot = __value;
        return;
      case '_gameSnapshot':
        _gameSnapshot = __value;
        return;
      case '_opponentSnapshot':
        _opponentSnapshot = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Team');
  }

  Iterable<String> get keys => TeamClassMirror.fields.keys;
}

// **************************************************************************
// Generator: MirrorsGenerator
// **************************************************************************

const RoleInTeamClassMirror = const ClassMirror(
    name: 'RoleInTeam', isEnum: true, values: RoleInTeam.values);
const SportClassMirror =
    const ClassMirror(name: 'Sport', isEnum: true, values: Sport.values);
const GenderClassMirror =
    const ClassMirror(name: 'Gender', isEnum: true, values: Gender.values);
const EventTypeClassMirror = const ClassMirror(
    name: 'EventType', isEnum: true, values: EventType.values);
const GameResultClassMirror = const ClassMirror(
    name: 'GameResult', isEnum: true, values: GameResult.values);
const UpdateReasonClassMirror = const ClassMirror(
    name: 'UpdateReason', isEnum: true, values: UpdateReason.values);
_Player__Constructor([positionalParams, namedParams]) => new Player();

const $$Player_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$Player_fields_uid = const DeclarationMirror(name: 'uid', type: String);
const $$Player_fields__snapshot = const DeclarationMirror(
    name: '_snapshot',
    type: const [Stream, QuerySnapshot],
    annotations: const [ignore]);

const PlayerClassMirror =
    const ClassMirror(name: 'Player', constructors: const {
  '': const FunctionMirror(name: '', $call: _Player__Constructor)
}, fields: const {
  'name': $$Player_fields_name,
  'uid': $$Player_fields_uid,
  '_snapshot': $$Player_fields__snapshot
}, getters: const [
  'name',
  'uid',
  '_snapshot'
], setters: const [
  'name',
  'uid',
  '_snapshot'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_GameResultDetails__Constructor([positionalParams, namedParams]) =>
    new GameResultDetails();

const $$GameResultDetails_fields_ptsFor =
    const DeclarationMirror(name: 'ptsFor', type: int);
const $$GameResultDetails_fields_ptsAgainst =
    const DeclarationMirror(name: 'ptsAgainst', type: int);
const $$GameResultDetails_fields_result =
    const DeclarationMirror(name: 'result', type: GameResult);

const GameResultDetailsClassMirror =
    const ClassMirror(name: 'GameResultDetails', constructors: const {
  '': const FunctionMirror(name: '', $call: _GameResultDetails__Constructor)
}, fields: const {
  'ptsFor': $$GameResultDetails_fields_ptsFor,
  'ptsAgainst': $$GameResultDetails_fields_ptsAgainst,
  'result': $$GameResultDetails_fields_result
}, getters: const [
  'ptsFor',
  'ptsAgainst',
  'result'
], setters: const [
  'ptsFor',
  'ptsAgainst',
  'result'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_GamePlace__Constructor([positionalParams, namedParams]) => new GamePlace();

const $$GamePlace_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$GamePlace_fields_placeId =
    const DeclarationMirror(name: 'placeId', type: String);
const $$GamePlace_fields_address =
    const DeclarationMirror(name: 'address', type: String);
const $$GamePlace_fields_notes =
    const DeclarationMirror(name: 'notes', type: String);

const GamePlaceClassMirror =
    const ClassMirror(name: 'GamePlace', constructors: const {
  '': const FunctionMirror(name: '', $call: _GamePlace__Constructor)
}, fields: const {
  'name': $$GamePlace_fields_name,
  'placeId': $$GamePlace_fields_placeId,
  'address': $$GamePlace_fields_address,
  'notes': $$GamePlace_fields_notes
}, getters: const [
  'name',
  'placeId',
  'address',
  'notes'
], setters: const [
  'name',
  'placeId',
  'address',
  'notes'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_Game__Constructor([positionalParams, namedParams]) => new Game();

const $$Game_fields_uid = const DeclarationMirror(name: 'uid', type: String);
const $$Game_fields_name = const DeclarationMirror(name: 'name', type: String);
const $$Game_fields_time =
    const DeclarationMirror(name: 'time', type: TZDateTime);
const $$Game_fields_timezone =
    const DeclarationMirror(name: 'timezone', type: Location);
const $$Game_fields_arriveEarly =
    const DeclarationMirror(name: 'arriveEarly', type: int);
const $$Game_fields_gameLength =
    const DeclarationMirror(name: 'gameLength', type: int);
const $$Game_fields_notes =
    const DeclarationMirror(name: 'notes', type: String);
const $$Game_fields_opponentUid =
    const DeclarationMirror(name: 'opponentUid', type: String);
const $$Game_fields_teamUid =
    const DeclarationMirror(name: 'teamUid', type: String);
const $$Game_fields_uniform =
    const DeclarationMirror(name: 'uniform', type: String);
const $$Game_fields_type =
    const DeclarationMirror(name: 'type', type: EventType);
const $$Game_fields_result =
    const DeclarationMirror(name: 'result', type: GameResultDetails);
const $$Game_fields_place =
    const DeclarationMirror(name: 'place', type: GamePlace);

const GameClassMirror = const ClassMirror(name: 'Game', constructors: const {
  '': const FunctionMirror(name: '', $call: _Game__Constructor)
}, fields: const {
  'uid': $$Game_fields_uid,
  'name': $$Game_fields_name,
  'time': $$Game_fields_time,
  'timezone': $$Game_fields_timezone,
  'arriveEarly': $$Game_fields_arriveEarly,
  'gameLength': $$Game_fields_gameLength,
  'notes': $$Game_fields_notes,
  'opponentUid': $$Game_fields_opponentUid,
  'teamUid': $$Game_fields_teamUid,
  'uniform': $$Game_fields_uniform,
  'type': $$Game_fields_type,
  'result': $$Game_fields_result,
  'place': $$Game_fields_place
}, getters: const [
  'uid',
  'name',
  'time',
  'timezone',
  'arriveEarly',
  'gameLength',
  'notes',
  'opponentUid',
  'teamUid',
  'uniform',
  'type',
  'result',
  'place'
], setters: const [
  'uid',
  'name',
  'time',
  'timezone',
  'arriveEarly',
  'gameLength',
  'notes',
  'opponentUid',
  'teamUid',
  'uniform',
  'type',
  'result',
  'place'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'teamuid', type: String, isRequired: true),
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_WinRecord__Constructor([positionalParams, namedParams]) => new WinRecord();

const $$WinRecord_fields_win = const DeclarationMirror(name: 'win', type: int);
const $$WinRecord_fields_loss =
    const DeclarationMirror(name: 'loss', type: int);
const $$WinRecord_fields_tie = const DeclarationMirror(name: 'tie', type: int);

const WinRecordClassMirror =
    const ClassMirror(name: 'WinRecord', constructors: const {
  '': const FunctionMirror(name: '', $call: _WinRecord__Constructor)
}, fields: const {
  'win': $$WinRecord_fields_win,
  'loss': $$WinRecord_fields_loss,
  'tie': $$WinRecord_fields_tie
}, getters: const [
  'win',
  'loss',
  'tie'
], setters: const [
  'win',
  'loss',
  'tie'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_Opponent__Constructor([positionalParams, namedParams]) => new Opponent();

const $$Opponent_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$Opponent_fields_contact =
    const DeclarationMirror(name: 'contact', type: String);
const $$Opponent_fields_uid =
    const DeclarationMirror(name: 'uid', type: String);
const $$Opponent_fields_record =
    const DeclarationMirror(name: 'record', type: WinRecord);

const OpponentClassMirror =
    const ClassMirror(name: 'Opponent', constructors: const {
  '': const FunctionMirror(name: '', $call: _Opponent__Constructor)
}, fields: const {
  'name': $$Opponent_fields_name,
  'contact': $$Opponent_fields_contact,
  'uid': $$Opponent_fields_uid,
  'record': $$Opponent_fields_record
}, getters: const [
  'name',
  'contact',
  'uid',
  'record'
], setters: const [
  'name',
  'contact',
  'uid',
  'record'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_SeasonPlayer__Constructor([positionalParams, namedParams]) =>
    new SeasonPlayer();

const $$SeasonPlayer_fields_playerUid =
    const DeclarationMirror(name: 'playerUid', type: String);
const $$SeasonPlayer_fields_role =
    const DeclarationMirror(name: 'role', type: RoleInTeam);

const SeasonPlayerClassMirror =
    const ClassMirror(name: 'SeasonPlayer', constructors: const {
  '': const FunctionMirror(name: '', $call: _SeasonPlayer__Constructor)
}, fields: const {
  'playerUid': $$SeasonPlayer_fields_playerUid,
  'role': $$SeasonPlayer_fields_role
}, getters: const [
  'playerUid',
  'role'
], setters: const [
  'playerUid',
  'role'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_Season__Constructor([positionalParams, namedParams]) => new Season();

const $$Season_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$Season_fields_uid = const DeclarationMirror(name: 'uid', type: String);
const $$Season_fields_record =
    const DeclarationMirror(name: 'record', type: WinRecord);
const $$Season_fields_players =
    const DeclarationMirror(name: 'players', type: const [List, SeasonPlayer]);

const SeasonClassMirror =
    const ClassMirror(name: 'Season', constructors: const {
  '': const FunctionMirror(name: '', $call: _Season__Constructor)
}, fields: const {
  'name': $$Season_fields_name,
  'uid': $$Season_fields_uid,
  'record': $$Season_fields_record,
  'players': $$Season_fields_players
}, getters: const [
  'name',
  'uid',
  'record',
  'players'
], setters: const [
  'name',
  'uid',
  'record',
  'players'
], methods: const {
  'updateFrom': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'data',
          type: const [
            Map,
            const [String, dynamic]
          ],
          isRequired: true)
    ],
    name: 'updateFrom',
    returnType: null,
  )
});
_Team__Constructor([positionalParams, namedParams]) => new Team();

const $$Team_fields_name = const DeclarationMirror(name: 'name', type: String);
const $$Team_fields_earlyArrival =
    const DeclarationMirror(name: 'earlyArrival', type: int);
const $$Team_fields_currentSeason =
    const DeclarationMirror(name: 'currentSeason', type: String);
const $$Team_fields_gender =
    const DeclarationMirror(name: 'gender', type: Gender);
const $$Team_fields_league =
    const DeclarationMirror(name: 'league', type: String);
const $$Team_fields_sport = const DeclarationMirror(name: 'sport', type: Sport);
const $$Team_fields_uid = const DeclarationMirror(name: 'uid', type: String);
const $$Team_fields_record =
    const DeclarationMirror(name: 'record', type: WinRecord);
const $$Team_fields_admins =
    const DeclarationMirror(name: 'admins', type: const [List, String]);
const $$Team_fields_opponents =
    const DeclarationMirror(name: 'opponents', type: const [
  Map,
  const [String, Opponent]
]);
const $$Team_fields_seasons =
    const DeclarationMirror(name: 'seasons', type: const [
  Map,
  const [String, Season]
]);
const $$Team_fields_opponentStream = const DeclarationMirror(
    name: 'opponentStream',
    type: const [Stream, UpdateReason],
    annotations: const [ignore]);
const $$Team_fields_thisTeamStream = const DeclarationMirror(
    name: 'thisTeamStream',
    type: const [Stream, UpdateReason],
    annotations: const [ignore]);
const $$Team_fields__opponentController = const DeclarationMirror(
    name: '_opponentController', type: const [StreamController, UpdateReason]);
const $$Team_fields__updateThisTeam = const DeclarationMirror(
    name: '_updateThisTeam', type: const [StreamController, UpdateReason]);
const $$Team_fields__teamSnapshot = const DeclarationMirror(
    name: '_teamSnapshot', type: const [StreamSubscription, DocumentSnapshot]);
const $$Team_fields__gameSnapshot = const DeclarationMirror(
    name: '_gameSnapshot', type: const [StreamSubscription, QuerySnapshot]);
const $$Team_fields__opponentSnapshot = const DeclarationMirror(
    name: '_opponentSnapshot', type: const [StreamSubscription, QuerySnapshot]);

const TeamClassMirror = const ClassMirror(name: 'Team', constructors: const {
  '': const FunctionMirror(name: '', $call: _Team__Constructor)
}, fields: const {
  'name': $$Team_fields_name,
  'earlyArrival': $$Team_fields_earlyArrival,
  'currentSeason': $$Team_fields_currentSeason,
  'gender': $$Team_fields_gender,
  'league': $$Team_fields_league,
  'sport': $$Team_fields_sport,
  'uid': $$Team_fields_uid,
  'record': $$Team_fields_record,
  'admins': $$Team_fields_admins,
  'opponents': $$Team_fields_opponents,
  'seasons': $$Team_fields_seasons,
  'opponentStream': $$Team_fields_opponentStream,
  'thisTeamStream': $$Team_fields_thisTeamStream,
  '_opponentController': $$Team_fields__opponentController,
  '_updateThisTeam': $$Team_fields__updateThisTeam,
  '_teamSnapshot': $$Team_fields__teamSnapshot,
  '_gameSnapshot': $$Team_fields__gameSnapshot,
  '_opponentSnapshot': $$Team_fields__opponentSnapshot
}, getters: const [
  'name',
  'earlyArrival',
  'currentSeason',
  'gender',
  'league',
  'sport',
  'uid',
  'record',
  'admins',
  'opponents',
  'seasons',
  'opponentStream',
  'thisTeamStream',
  '_opponentController',
  '_updateThisTeam',
  '_teamSnapshot',
  '_gameSnapshot',
  '_opponentSnapshot'
], setters: const [
  'name',
  'earlyArrival',
  'currentSeason',
  'gender',
  'league',
  'sport',
  'uid',
  'record',
  'admins',
  'opponents',
  'seasons',
  'opponentStream',
  'thisTeamStream',
  '_opponentController',
  '_updateThisTeam',
  '_teamSnapshot',
  '_gameSnapshot',
  '_opponentSnapshot'
], methods: const {
  '_onOpponentUpdated': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'query', type: QuerySnapshot, isRequired: true)
    ],
    name: '_onOpponentUpdated',
    returnType: null,
  ),
  '_onTeamUpdated': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'snap', type: DocumentSnapshot, isRequired: true)
    ],
    name: '_onTeamUpdated',
    returnType: null,
  ),
  'updateSeason': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'doc', type: DocumentSnapshot, isRequired: true)
    ],
    name: 'updateSeason',
    returnType: null,
  ),
  'setupSnap': const FunctionMirror(
    name: 'setupSnap',
    returnType: null,
  )
});

// **************************************************************************
// Generator: InitMirrorsGenerator
// **************************************************************************

_initMirrors() {
  initClassMirrors({
    RoleInTeam: RoleInTeamClassMirror,
    Sport: SportClassMirror,
    Gender: GenderClassMirror,
    EventType: EventTypeClassMirror,
    GameResult: GameResultClassMirror,
    UpdateReason: UpdateReasonClassMirror,
    Player: PlayerClassMirror,
    GameResultDetails: GameResultDetailsClassMirror,
    GamePlace: GamePlaceClassMirror,
    Game: GameClassMirror,
    WinRecord: WinRecordClassMirror,
    Opponent: OpponentClassMirror,
    SeasonPlayer: SeasonPlayerClassMirror,
    Season: SeasonClassMirror,
    Team: TeamClassMirror
  });
}
