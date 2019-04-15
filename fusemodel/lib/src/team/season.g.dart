// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Season extends Season {
  @override
  final String name;
  @override
  final String uid;
  @override
  final String teamUid;
  @override
  final WinRecord record;
  @override
  final BuiltList<SeasonPlayer> players;

  factory _$Season([void Function(SeasonBuilder) updates]) =>
      (new SeasonBuilder()..update(updates)).build();

  _$Season._({this.name, this.uid, this.teamUid, this.record, this.players})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('Season', 'name');
    }
    if (uid == null) {
      throw new BuiltValueNullFieldError('Season', 'uid');
    }
    if (teamUid == null) {
      throw new BuiltValueNullFieldError('Season', 'teamUid');
    }
    if (record == null) {
      throw new BuiltValueNullFieldError('Season', 'record');
    }
    if (players == null) {
      throw new BuiltValueNullFieldError('Season', 'players');
    }
  }

  @override
  Season rebuild(void Function(SeasonBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SeasonBuilder toBuilder() => new SeasonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Season &&
        name == other.name &&
        uid == other.uid &&
        teamUid == other.teamUid &&
        record == other.record &&
        players == other.players;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, name.hashCode), uid.hashCode), teamUid.hashCode),
            record.hashCode),
        players.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Season')
          ..add('name', name)
          ..add('uid', uid)
          ..add('teamUid', teamUid)
          ..add('record', record)
          ..add('players', players))
        .toString();
  }
}

class SeasonBuilder implements Builder<Season, SeasonBuilder> {
  _$Season _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  String _teamUid;
  String get teamUid => _$this._teamUid;
  set teamUid(String teamUid) => _$this._teamUid = teamUid;

  WinRecordBuilder _record;
  WinRecordBuilder get record => _$this._record ??= new WinRecordBuilder();
  set record(WinRecordBuilder record) => _$this._record = record;

  ListBuilder<SeasonPlayer> _players;
  ListBuilder<SeasonPlayer> get players =>
      _$this._players ??= new ListBuilder<SeasonPlayer>();
  set players(ListBuilder<SeasonPlayer> players) => _$this._players = players;

  SeasonBuilder();

  SeasonBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _uid = _$v.uid;
      _teamUid = _$v.teamUid;
      _record = _$v.record?.toBuilder();
      _players = _$v.players?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Season other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Season;
  }

  @override
  void update(void Function(SeasonBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Season build() {
    _$Season _$result;
    try {
      _$result = _$v ??
          new _$Season._(
              name: name,
              uid: uid,
              teamUid: teamUid,
              record: record.build(),
              players: players.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'record';
        record.build();
        _$failedField = 'players';
        players.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Season', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
