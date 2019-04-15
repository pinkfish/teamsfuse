// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'winrecord.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WinRecord extends WinRecord {
  @override
  final num win;
  @override
  final num loss;
  @override
  final num tie;

  factory _$WinRecord([void Function(WinRecordBuilder) updates]) =>
      (new WinRecordBuilder()..update(updates)).build();

  _$WinRecord._({this.win, this.loss, this.tie}) : super._() {
    if (win == null) {
      throw new BuiltValueNullFieldError('WinRecord', 'win');
    }
    if (loss == null) {
      throw new BuiltValueNullFieldError('WinRecord', 'loss');
    }
    if (tie == null) {
      throw new BuiltValueNullFieldError('WinRecord', 'tie');
    }
  }

  @override
  WinRecord rebuild(void Function(WinRecordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WinRecordBuilder toBuilder() => new WinRecordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WinRecord &&
        win == other.win &&
        loss == other.loss &&
        tie == other.tie;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, win.hashCode), loss.hashCode), tie.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('WinRecord')
          ..add('win', win)
          ..add('loss', loss)
          ..add('tie', tie))
        .toString();
  }
}

class WinRecordBuilder implements Builder<WinRecord, WinRecordBuilder> {
  _$WinRecord _$v;

  num _win;
  num get win => _$this._win;
  set win(num win) => _$this._win = win;

  num _loss;
  num get loss => _$this._loss;
  set loss(num loss) => _$this._loss = loss;

  num _tie;
  num get tie => _$this._tie;
  set tie(num tie) => _$this._tie = tie;

  WinRecordBuilder();

  WinRecordBuilder get _$this {
    if (_$v != null) {
      _win = _$v.win;
      _loss = _$v.loss;
      _tie = _$v.tie;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WinRecord other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$WinRecord;
  }

  @override
  void update(void Function(WinRecordBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$WinRecord build() {
    final _$result = _$v ?? new _$WinRecord._(win: win, loss: loss, tie: tie);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
