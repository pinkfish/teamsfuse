// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Team extends Team {
  @override
  final String name;
  @override
  final num arriveEarlyInternal;
  @override
  final String currentSeason;
  @override
  final Gender gender;
  @override
  final String league;
  @override
  final Sport sport;
  @override
  final String uid;
  @override
  final String photoUrl;
  @override
  final bool archived;
  @override
  final String userUid;
  @override
  final String clubUid;
  @override
  final bool publicOnly;
  @override
  final bool trackAttendenceInternal;
  @override
  final BuiltList<String> admins;
  @override
  final BuiltMap<String, Opponent> opponents;
  @override
  final BuiltMap<String, Season> seasons;

  factory _$Team([void Function(TeamBuilder) updates]) =>
      (new TeamBuilder()..update(updates)).build();

  _$Team._(
      {this.name,
      this.arriveEarlyInternal,
      this.currentSeason,
      this.gender,
      this.league,
      this.sport,
      this.uid,
      this.photoUrl,
      this.archived,
      this.userUid,
      this.clubUid,
      this.publicOnly,
      this.trackAttendenceInternal,
      this.admins,
      this.opponents,
      this.seasons})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('Team', 'name');
    }
    if (arriveEarlyInternal == null) {
      throw new BuiltValueNullFieldError('Team', 'arriveEarlyInternal');
    }
    if (currentSeason == null) {
      throw new BuiltValueNullFieldError('Team', 'currentSeason');
    }
    if (gender == null) {
      throw new BuiltValueNullFieldError('Team', 'gender');
    }
    if (league == null) {
      throw new BuiltValueNullFieldError('Team', 'league');
    }
    if (sport == null) {
      throw new BuiltValueNullFieldError('Team', 'sport');
    }
    if (uid == null) {
      throw new BuiltValueNullFieldError('Team', 'uid');
    }
    if (photoUrl == null) {
      throw new BuiltValueNullFieldError('Team', 'photoUrl');
    }
    if (archived == null) {
      throw new BuiltValueNullFieldError('Team', 'archived');
    }
    if (userUid == null) {
      throw new BuiltValueNullFieldError('Team', 'userUid');
    }
    if (clubUid == null) {
      throw new BuiltValueNullFieldError('Team', 'clubUid');
    }
    if (publicOnly == null) {
      throw new BuiltValueNullFieldError('Team', 'publicOnly');
    }
    if (trackAttendenceInternal == null) {
      throw new BuiltValueNullFieldError('Team', 'trackAttendenceInternal');
    }
    if (admins == null) {
      throw new BuiltValueNullFieldError('Team', 'admins');
    }
    if (opponents == null) {
      throw new BuiltValueNullFieldError('Team', 'opponents');
    }
    if (seasons == null) {
      throw new BuiltValueNullFieldError('Team', 'seasons');
    }
  }

  @override
  Team rebuild(void Function(TeamBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeamBuilder toBuilder() => new TeamBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Team &&
        name == other.name &&
        arriveEarlyInternal == other.arriveEarlyInternal &&
        currentSeason == other.currentSeason &&
        gender == other.gender &&
        league == other.league &&
        sport == other.sport &&
        uid == other.uid &&
        photoUrl == other.photoUrl &&
        archived == other.archived &&
        userUid == other.userUid &&
        clubUid == other.clubUid &&
        publicOnly == other.publicOnly &&
        trackAttendenceInternal == other.trackAttendenceInternal &&
        admins == other.admins &&
        opponents == other.opponents &&
        seasons == other.seasons;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    0,
                                                                    name
                                                                        .hashCode),
                                                                arriveEarlyInternal
                                                                    .hashCode),
                                                            currentSeason
                                                                .hashCode),
                                                        gender.hashCode),
                                                    league.hashCode),
                                                sport.hashCode),
                                            uid.hashCode),
                                        photoUrl.hashCode),
                                    archived.hashCode),
                                userUid.hashCode),
                            clubUid.hashCode),
                        publicOnly.hashCode),
                    trackAttendenceInternal.hashCode),
                admins.hashCode),
            opponents.hashCode),
        seasons.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Team')
          ..add('name', name)
          ..add('arriveEarlyInternal', arriveEarlyInternal)
          ..add('currentSeason', currentSeason)
          ..add('gender', gender)
          ..add('league', league)
          ..add('sport', sport)
          ..add('uid', uid)
          ..add('photoUrl', photoUrl)
          ..add('archived', archived)
          ..add('userUid', userUid)
          ..add('clubUid', clubUid)
          ..add('publicOnly', publicOnly)
          ..add('trackAttendenceInternal', trackAttendenceInternal)
          ..add('admins', admins)
          ..add('opponents', opponents)
          ..add('seasons', seasons))
        .toString();
  }
}

class TeamBuilder implements Builder<Team, TeamBuilder> {
  _$Team _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  num _arriveEarlyInternal;
  num get arriveEarlyInternal => _$this._arriveEarlyInternal;
  set arriveEarlyInternal(num arriveEarlyInternal) =>
      _$this._arriveEarlyInternal = arriveEarlyInternal;

  String _currentSeason;
  String get currentSeason => _$this._currentSeason;
  set currentSeason(String currentSeason) =>
      _$this._currentSeason = currentSeason;

  Gender _gender;
  Gender get gender => _$this._gender;
  set gender(Gender gender) => _$this._gender = gender;

  String _league;
  String get league => _$this._league;
  set league(String league) => _$this._league = league;

  Sport _sport;
  Sport get sport => _$this._sport;
  set sport(Sport sport) => _$this._sport = sport;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  String _photoUrl;
  String get photoUrl => _$this._photoUrl;
  set photoUrl(String photoUrl) => _$this._photoUrl = photoUrl;

  bool _archived;
  bool get archived => _$this._archived;
  set archived(bool archived) => _$this._archived = archived;

  String _userUid;
  String get userUid => _$this._userUid;
  set userUid(String userUid) => _$this._userUid = userUid;

  String _clubUid;
  String get clubUid => _$this._clubUid;
  set clubUid(String clubUid) => _$this._clubUid = clubUid;

  bool _publicOnly;
  bool get publicOnly => _$this._publicOnly;
  set publicOnly(bool publicOnly) => _$this._publicOnly = publicOnly;

  bool _trackAttendenceInternal;
  bool get trackAttendenceInternal => _$this._trackAttendenceInternal;
  set trackAttendenceInternal(bool trackAttendenceInternal) =>
      _$this._trackAttendenceInternal = trackAttendenceInternal;

  ListBuilder<String> _admins;
  ListBuilder<String> get admins =>
      _$this._admins ??= new ListBuilder<String>();
  set admins(ListBuilder<String> admins) => _$this._admins = admins;

  MapBuilder<String, Opponent> _opponents;
  MapBuilder<String, Opponent> get opponents =>
      _$this._opponents ??= new MapBuilder<String, Opponent>();
  set opponents(MapBuilder<String, Opponent> opponents) =>
      _$this._opponents = opponents;

  MapBuilder<String, Season> _seasons;
  MapBuilder<String, Season> get seasons =>
      _$this._seasons ??= new MapBuilder<String, Season>();
  set seasons(MapBuilder<String, Season> seasons) => _$this._seasons = seasons;

  TeamBuilder();

  TeamBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _arriveEarlyInternal = _$v.arriveEarlyInternal;
      _currentSeason = _$v.currentSeason;
      _gender = _$v.gender;
      _league = _$v.league;
      _sport = _$v.sport;
      _uid = _$v.uid;
      _photoUrl = _$v.photoUrl;
      _archived = _$v.archived;
      _userUid = _$v.userUid;
      _clubUid = _$v.clubUid;
      _publicOnly = _$v.publicOnly;
      _trackAttendenceInternal = _$v.trackAttendenceInternal;
      _admins = _$v.admins?.toBuilder();
      _opponents = _$v.opponents?.toBuilder();
      _seasons = _$v.seasons?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Team other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Team;
  }

  @override
  void update(void Function(TeamBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Team build() {
    _$Team _$result;
    try {
      _$result = _$v ??
          new _$Team._(
              name: name,
              arriveEarlyInternal: arriveEarlyInternal,
              currentSeason: currentSeason,
              gender: gender,
              league: league,
              sport: sport,
              uid: uid,
              photoUrl: photoUrl,
              archived: archived,
              userUid: userUid,
              clubUid: clubUid,
              publicOnly: publicOnly,
              trackAttendenceInternal: trackAttendenceInternal,
              admins: admins.build(),
              opponents: opponents.build(),
              seasons: seasons.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'admins';
        admins.build();
        _$failedField = 'opponents';
        opponents.build();
        _$failedField = 'seasons';
        seasons.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Team', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
