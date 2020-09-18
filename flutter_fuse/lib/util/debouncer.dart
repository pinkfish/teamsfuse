/*
  dart throttle/debouce

  This package is inspired by jquery throttle/debounce <http://benalman.com/projects/jquery-throttle-debounce-plugin>

  Debounces and calls with the list of changes.
*/

import 'dart:async';

import 'package:flutter/material.dart';

///
/// Debounces the request, so if lots of things happen at once it only
/// lets through one.
///
class Debouncer<Val> {
  /// Create the debouncer with the minimum delay and the callback.
  Debouncer(this._delay, this._callback,
      {this.atBegin = false, this.resetOnAdd});

  final Duration _delay;
  final ValueChanged<List<Val>> _callback;

  /// If the debouncer is at the begining.
  final bool atBegin;

  /// Reset the state when added.
  final bool resetOnAdd;

  final List<Val> _data = <Val>[];

  Timer _timeoutId;

  void _exec() {
    _callback(_data);
    _data.clear();
  }

  void _clear() {
    _timeoutId = null;
  }

  /// The value to try and becounce.
  void debounce(Val val) {
    _data.add(val);
    // cancel the previous timer if debounce is still being called before the delay period is over
    if (_timeoutId != null && resetOnAdd) {
      _timeoutId.cancel();
    }
    // if atBegin is true, 'exec' has to executed the first time debounce gets called
    if (atBegin && _timeoutId == null) {
      _exec();
    }
    if (_timeoutId == null) {
      // schedule a new call after delay time
      _timeoutId = Timer(_delay, atBegin ? _clear : _exec);
    }
  }
}
