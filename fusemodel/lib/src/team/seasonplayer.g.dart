// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seasonplayer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SeasonPlayer extends SeasonPlayer {
  @override
  final String playerUid;
  @override
  final RoleInTeam role;
  @override
  final String jerseyNumber;
  @override
  final String position;

  factory _$SeasonPlayer([void Function(SeasonPlayerBuilder) updates]) =>
      (new SeasonPlayerBuilder()..update(updates)).build();

  _$SeasonPlayer._(
      {this.playerUid, this.role, this.jerseyNumber, this.position})
      : super._() {
    if (playerUid == null) {
      throw new BuiltValueNullFieldError('SeasonPlayer', 'playerUid');
    }
    if (role == null) {
      throw new BuiltValueNullFieldError('SeasonPlayer', 'role');
    }
    if (jerseyNumber == null) {
      throw new BuiltValueNullFieldError('SeasonPlayer', 'jerseyNumber');
    }
    if (position == null) {
      throw new BuiltValueNullFieldError('SeasonPlayer', 'position');
    }
  }

  @override
  SeasonPlayer rebuild(void Function(SeasonPlayerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SeasonPlayerBuilder toBuilder() => new SeasonPlayerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SeasonPlayer &&
        playerUid == other.playerUid &&
        role == other.role &&
        jerseyNumber == other.jerseyNumber &&
        position == other.position;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, playerUid.hashCode), role.hashCode),
            jerseyNumber.hashCode),
        position.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SeasonPlayer')
          ..add('playerUid', playerUid)
          ..add('role', role)
          ..add('jerseyNumber', jerseyNumber)
          ..add('position', position))
        .toString();
  }
}

class SeasonPlayerBuilder
    implements Builder<SeasonPlayer, SeasonPlayerBuilder> {
  _$SeasonPlayer _$v;

  String _playerUid;
  String get playerUid => _$this._playerUid;
  set playerUid(String playerUid) => _$this._playerUid = playerUid;

  RoleInTeam _role;
  RoleInTeam get role => _$this._role;
  set role(RoleInTeam role) => _$this._role = role;

  String _jerseyNumber;
  String get jerseyNumber => _$this._jerseyNumber;
  set jerseyNumber(String jerseyNumber) => _$this._jerseyNumber = jerseyNumber;

  String _position;
  String get position => _$this._position;
  set position(String position) => _$this._position = position;

  SeasonPlayerBuilder();

  SeasonPlayerBuilder get _$this {
    if (_$v != null) {
      _playerUid = _$v.playerUid;
      _role = _$v.role;
      _jerseyNumber = _$v.jerseyNumber;
      _position = _$v.position;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SeasonPlayer other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$SeasonPlayer;
  }

  @override
  void update(void Function(SeasonPlayerBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$SeasonPlayer build() {
    final _$result = _$v ??
        new _$SeasonPlayer._(
            playerUid: playerUid,
            role: role,
            jerseyNumber: jerseyNumber,
            position: position);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
