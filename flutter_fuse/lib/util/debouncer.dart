/*
  dart throttle/debouce

  This package is inspired by jquery throttle/debounce <http://benalman.com/projects/jquery-throttle-debounce-plugin>

  Debounces and calls with the list of changes.
*/

import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer<Val> {
  final Duration _delay;
  final ValueChanged<List<Val>> _callback;
  bool atBegin;
  bool resetOnAdd;

  List<Val> _data = new List<Val>();

  Debouncer(this._delay, this._callback, {this.atBegin = false, this.resetOnAdd});

  Timer _timeoutId = null;

  void _exec() {
    _callback(_data);
    _data.clear();
  }

  void _clear() {
    _timeoutId = null;
  }

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
      _timeoutId = new Timer(_delay, atBegin ? _clear : _exec);
    }
  }
}
