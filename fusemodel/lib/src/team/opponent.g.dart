// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opponent.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Opponent extends Opponent {
  @override
  final String name;
  @override
  final String teamUid;
  @override
  final String contact;
  @override
  final String uid;
  @override
  final BuiltList<String> leagueTeamUid;
  @override
  final BuiltMap<String, WinRecord> record;

  factory _$Opponent([void updates(OpponentBuilder b)]) =>
      (new OpponentBuilder()..update(updates)).build();

  _$Opponent._(
      {this.name,
      this.teamUid,
      this.contact,
      this.uid,
      this.leagueTeamUid,
      this.record})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('Opponent', 'name');
    }
    if (teamUid == null) {
      throw new BuiltValueNullFieldError('Opponent', 'teamUid');
    }
    if (contact == null) {
      throw new BuiltValueNullFieldError('Opponent', 'contact');
    }
    if (uid == null) {
      throw new BuiltValueNullFieldError('Opponent', 'uid');
    }
    if (leagueTeamUid == null) {
      throw new BuiltValueNullFieldError('Opponent', 'leagueTeamUid');
    }
    if (record == null) {
      throw new BuiltValueNullFieldError('Opponent', 'record');
    }
  }

  @override
  Opponent rebuild(void updates(OpponentBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  OpponentBuilder toBuilder() => new OpponentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Opponent &&
        name == other.name &&
        teamUid == other.teamUid &&
        contact == other.contact &&
        uid == other.uid &&
        leagueTeamUid == other.leagueTeamUid &&
        record == other.record;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, name.hashCode), teamUid.hashCode),
                    contact.hashCode),
                uid.hashCode),
            leagueTeamUid.hashCode),
        record.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Opponent')
          ..add('name', name)
          ..add('teamUid', teamUid)
          ..add('contact', contact)
          ..add('uid', uid)
          ..add('leagueTeamUid', leagueTeamUid)
          ..add('record', record))
        .toString();
  }
}

class OpponentBuilder implements Builder<Opponent, OpponentBuilder> {
  _$Opponent _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _teamUid;
  String get teamUid => _$this._teamUid;
  set teamUid(String teamUid) => _$this._teamUid = teamUid;

  String _contact;
  String get contact => _$this._contact;
  set contact(String contact) => _$this._contact = contact;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  ListBuilder<String> _leagueTeamUid;
  ListBuilder<String> get leagueTeamUid =>
      _$this._leagueTeamUid ??= new ListBuilder<String>();
  set leagueTeamUid(ListBuilder<String> leagueTeamUid) =>
      _$this._leagueTeamUid = leagueTeamUid;

  MapBuilder<String, WinRecord> _record;
  MapBuilder<String, WinRecord> get record =>
      _$this._record ??= new MapBuilder<String, WinRecord>();
  set record(MapBuilder<String, WinRecord> record) => _$this._record = record;

  OpponentBuilder();

  OpponentBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _teamUid = _$v.teamUid;
      _contact = _$v.contact;
      _uid = _$v.uid;
      _leagueTeamUid = _$v.leagueTeamUid?.toBuilder();
      _record = _$v.record?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Opponent other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Opponent;
  }

  @override
  void update(void updates(OpponentBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Opponent build() {
    _$Opponent _$result;
    try {
      _$result = _$v ??
          new _$Opponent._(
              name: name,
              teamUid: teamUid,
              contact: contact,
              uid: uid,
              leagueTeamUid: leagueTeamUid.build(),
              record: record.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'leagueTeamUid';
        leagueTeamUid.build();
        _$failedField = 'record';
        record.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Opponent', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
