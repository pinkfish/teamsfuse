/// Signature for callbacks that filter an iterable.
typedef IterableFilter<T> = Iterable<T> Function(Iterable<T> input);

/// Signature for [FlutterErrorDetails.informationCollector] callback
/// and other callbacks that collect information into a string buffer.
typedef InformationCollector = void Function(StringBuffer information);

/// Class for information provided to [FlutterExceptionHandler] callbacks.
///
/// See [FusedError.onError].
class FusedErrorDetails {
  /// Creates a [FusedErrorDetails] object with the given arguments setting
  /// the object's properties.
  ///
  /// The framework calls this constructor when catching an exception that will
  /// subsequently be reported using [FusedError.onError].
  ///
  /// The [exception] must not be null; other arguments can be left to
  /// their default values. (`throw null` results in a
  /// [NullThrownError] exception.)
  const FusedErrorDetails(
      {this.exception,
      this.stack,
      this.library = 'Flutter framework',
      this.context,
      this.stackFilter,
      this.informationCollector,
      this.silent = false});

  /// The exception. Often this will be an [AssertionError], maybe specifically
  /// a [FusedError]. However, this could be any value at all.
  final dynamic exception;

  /// The stack trace from where the [exception] was thrown (as opposed to where
  /// it was caught).
  ///
  /// StackTrace objects are opaque except for their [toString] function.
  ///
  /// If this field is not null, then the [stackFilter] callback, if any, will
  /// be called with the result of calling [toString] on this object and
  /// splitting that result on line breaks. If there's no [stackFilter]
  /// callback, then [FusedError.defaultStackFilter] is used instead. That
  /// function expects the stack to be in the format used by
  /// [StackTrace.toString].
  final StackTrace stack;

  /// A human-readable brief name describing the library that caught the error
  /// message. This is used by the default error handler in the header dumped to
  /// the console.
  final String library;

  /// A human-readable description of where the error was caught (as opposed to
  /// where it was thrown).
  final String context;

  /// A callback which filters the [stack] trace. Receives an iterable of
  /// strings representing the frames encoded in the way that
  /// [StackTrace.toString()] provides. Should return an iterable of lines to
  /// output for the stack.
  ///
  /// If this is not provided, then [FusedError.dumpErrorToConsole] will use
  /// [FusedError.defaultStackFilter] instead.
  ///
  /// If the [FusedError.defaultStackFilter] behavior is desired, then the
  /// callback should manually call that function. That function expects the
  /// incoming list to be in the [StackTrace.toString()] format. The output of
  /// that function, however, does not always follow this format.
  ///
  /// This won't be called if [stack] is null.
  final IterableFilter<String> stackFilter;

  /// A callback which, when called with a [StringBuffer] will write to that buffer
  /// information that could help with debugging the problem.
  ///
  /// Information collector callbacks can be expensive, so the generated information
  /// should be cached, rather than the callback being called multiple times.
  ///
  /// The text written to the information argument may contain newlines but should
  /// not end with a newline.
  final InformationCollector informationCollector;

  /// Whether this error should be ignored by the default error reporting
  /// behavior in release mode.
  ///
  /// If this is false, the default, then the default error handler will always
  /// dump this error to the console.
  ///
  /// If this is true, then the default error handler would only dump this error
  /// to the console in checked mode. In release mode, the error is ignored.
  ///
  /// This is used by certain exception handlers that catch errors that could be
  /// triggered by environmental conditions (as opposed to logic errors). For
  /// example, the HTTP library sets this flag so as to not report every 404
  /// error to the console on end-user devices, while still allowing a custom
  /// error handler to see the errors even in release builds.
  final bool silent;

  /// Converts the [exception] to a string.
  ///
  /// This applies some additional logic to make [AssertionError] exceptions
  /// prettier, to handle exceptions that stringify to empty strings, to handle
  /// objects that don't inherit from [Exception] or [Error], and so forth.
  String exceptionAsString() {
    String longMessage;
    if (exception is AssertionError) {
      // Regular _AssertionErrors thrown by assert() put the message last, after
      // some code snippets. This leads to ugly messages. To avoid this, we move
      // the assertion message up to before the code snippets, separated by a
      // newline, if we recognise that format is being used.
      final String message = exception.message;
      final fullMessage = exception.toString();
      if (message is String && message != fullMessage) {
        if (fullMessage.length > message.length) {
          final position = fullMessage.lastIndexOf(message);
          if (position == fullMessage.length - message.length &&
              position > 2 &&
              fullMessage.substring(position - 2, position) == ': ') {
            longMessage =
                '${message.trimRight()}\n${fullMessage.substring(0, position - 2)}';
          }
        }
      }
      longMessage ??= fullMessage;
    } else if (exception is String) {
      longMessage = exception;
    } else if (exception is Error || exception is Exception) {
      longMessage = exception.toString();
    } else {
      longMessage = '  ${exception.toString()}';
    }
    longMessage = longMessage.trimRight();
    if (longMessage.isEmpty) longMessage = '  <no message available>';
    return longMessage;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if ((library != null && library != '') ||
        (context != null && context != '')) {
      if (library != null && library != '') {
        buffer.write('Error caught by $library');
        if (context != null && context != '') buffer.write(', ');
      } else {
        buffer.writeln('Exception ');
      }
      if (context != null && context != '') buffer.write('thrown $context');
      buffer.writeln('.');
    } else {
      buffer.write('An error was caught.');
    }
    buffer.writeln(exceptionAsString());
    if (informationCollector != null) informationCollector(buffer);
    if (stack != null) {
      Iterable<String> stackLines = stack.toString().trimRight().split('\n');
      if (stackFilter != null) {
        stackLines = stackFilter(stackLines);
      } else {
        stackLines = FusedError.defaultStackFilter(stackLines);
      }
      buffer.writeAll(stackLines, '\n');
    }
    return buffer.toString().trimRight();
  }
}

/// Error class used to report Flutter-specific assertion failures and
/// contract violations.
class FusedError extends AssertionError {
  /// Creates a [FusedError].
  ///
  /// See [message] for details on the format that the message should
  /// take.
  ///
  /// Include as much detail as possible in the full error message,
  /// including specifics about the state of the app that might be
  /// relevant to debugging the error.
  FusedError(String message) : super(message);

  /// The message associated with this error.
  ///
  /// The message may have newlines in it. The first line should be a terse
  /// description of the error, e.g. "Incorrect GlobalKey usage" or "setState()
  /// or markNeedsBuild() called during build". Subsequent lines should contain
  /// substantial additional information, ideally sufficient to develop a
  /// correct solution to the problem.
  ///
  /// In some cases, when a FlutterError is reported to the user, only the first
  /// line is included. For example, Flutter will typically only fully report
  /// the first exception at runtime, displaying only the first line of
  /// subsequent errors.
  ///
  /// All sentences in the error should be correctly punctuated (i.e.,
  /// do end the error message with a period).
  @override
  String get message => super.message;

  @override
  String toString() => message;

  static int _errorCount = 0;

  /// Resets the count of errors used by [dumpErrorToConsole] to decide whether
  /// to show a complete error message or an abbreviated one.
  ///
  /// After this is called, the next error message will be shown in full.
  static void resetErrorCount() {
    _errorCount = 0;
  }

  /// The width to which [dumpErrorToConsole] will wrap lines.
  ///
  /// This can be used to ensure strings will not exceed the length at which
  /// they will wrap, e.g. when placing ASCII art diagrams in messages.
  static const int wrapWidth = 100;

  /// Prints the given exception details to the console.
  ///
  /// The first time this is called, it dumps a very verbose message to the
  /// console using [debugPrint].
  ///
  /// Subsequent calls only dump the first line of the exception, unless
  /// `forceReport` is set to true (in which case it dumps the verbose message).
  ///
  /// Call [resetErrorCount] to cause this method to go back to acting as if it
  /// had not been called before (so the next message is verbose again).
  ///
  /// The default behavior for the [onError] handler is to call this function.
  static void dumpErrorToConsole(FusedErrorDetails details,
      {bool forceReport = false}) {
    assert(details != null);
    assert(details.exception != null);
    var reportError = details.silent != true; // could be null
    assert(() {
      // In checked mode, we ignore the "silent" flag.
      reportError = true;
      return true;
    }());
    if (!reportError && !forceReport) return;
    if (_errorCount == 0 || forceReport) {
      final header =
          '\u2550\u2550\u2561 EXCEPTION CAUGHT BY ${details.library} \u255E'
              .toUpperCase();
      final footer = '\u2550' * wrapWidth;
      print('$header${"\u2550" * (footer.length - header.length)}');
      final verb =
          'thrown${details.context != null ? " ${details.context}" : ""}';
      if (details.exception is NullThrownError) {
        print('The null value was $verb.');
      } else if (details.exception is num) {
        print('The number ${details.exception} was $verb.');
      } else {
        String errorName;
        if (details.exception is AssertionError) {
          errorName = 'assertion';
        } else if (details.exception is String) {
          errorName = 'message';
        } else if (details.exception is Error ||
            details.exception is Exception) {
          errorName = '${details.exception.runtimeType}';
        } else {
          errorName = '${details.exception.runtimeType} object';
        }
        // Many exception classes put their type at the head of their message.
        // This is redundant with the way we display exceptions, so attempt to
        // strip out that header when we see it.
        final prefix = '${details.exception.runtimeType}: ';
        var message = details.exceptionAsString();
        if (message.startsWith(prefix)) {
          message = message.substring(prefix.length);
        }
        print('The following $errorName was $verb:\n$message');
      }
      Iterable<String> stackLines = (details.stack != null)
          ? details.stack.toString().trimRight().split('\n')
          : null;
      if ((details.exception is AssertionError) &&
          (details.exception is! FusedError)) {
        var ourFault = true;
        if (stackLines != null) {
          final stackList = stackLines.take(2).toList();
          if (stackList.length >= 2) {
            // TODO(ianh): This has bitrotted and is no longer matching. https://github.com/flutter/flutter/issues/4021
            final throwPattern =
                RegExp(r'^#0 +_AssertionError._throwNew \(dart:.+\)$');
            final assertPattern =
                RegExp(r'^#1 +[^(]+ \((.+?):([0-9]+)(?::[0-9]+)?\)$');
            if (throwPattern.hasMatch(stackList[0])) {
              final Match assertMatch = assertPattern.firstMatch(stackList[1]);
              if (assertMatch != null) {
                assert(assertMatch.groupCount == 2);
                final ourLibraryPattern = RegExp(r'^package:flutter/');
                ourFault = ourLibraryPattern.hasMatch(assertMatch.group(1));
              }
            }
          }
        }
        if (ourFault) {
          print(
              '\nEither the assertion indicates an error in the framework itself, or we should '
              'provide substantially more information in this error message to help you determine '
              'and fix the underlying cause.');
          print(
              'In either case, please report this assertion by filing a bug on GitHub:');
          print('  https://github.com/flutter/flutter/issues/new');
        }
      }
      if (details.stack != null) {
        print('\nWhen the exception was thrown, this was the stack:');
        if (details.stackFilter != null) {
          stackLines = details.stackFilter(stackLines);
        } else {
          stackLines = defaultStackFilter(stackLines);
        }
        for (var line in stackLines) {
          print(line);
        }
      }
      if (details.informationCollector != null) {
        final information = StringBuffer();
        details.informationCollector(information);
        print('\n${information.toString().trimRight()}');
      }
      print(footer);
    } else {
      print(
          'Another exception was thrown: ${details.exceptionAsString().split("\n")[0].trimLeft()}');
    }
    _errorCount += 1;
  }

  /// Converts a stack to a string that is more readable by omitting stack
  /// frames that correspond to Dart internals.
  ///
  /// This is the default filter used by [dumpErrorToConsole] if the
  /// [FlutterErrorDetails] object has no [FlutterErrorDetails.stackFilter]
  /// callback.
  ///
  /// This function expects its input to be in the format used by
  /// [StackTrace.toString()]. The output of this function is similar to that
  /// format but the frame numbers will not be consecutive (frames are elided)
  /// and the final line may be prose rather than a stack frame.
  static Iterable<String> defaultStackFilter(Iterable<String> frames) {
    const filteredPackages = <String>[
      'dart:async-patch',
      'dart:async',
      'package:stack_trace',
    ];
    const filteredClasses = <String>[
      '_AssertionError',
      '_FakeAsync',
      '_FrameCallbackEntry',
    ];
    final stackParser =
        RegExp(r'^#[0-9]+ +([^.]+).* \(([^/\\]*)[/\\].+:[0-9]+(?::[0-9]+)?\)$');
    final packageParser = RegExp(r'^([^:]+):(.+)$');
    final result = <String>[];
    final skipped = <String>[];
    for (var line in frames) {
      final Match match = stackParser.firstMatch(line);
      if (match != null) {
        assert(match.groupCount == 2);
        if (filteredPackages.contains(match.group(2))) {
          final Match packageMatch = packageParser.firstMatch(match.group(2));
          if (packageMatch != null && packageMatch.group(1) == 'package') {
            skipped.add(
                'package ${packageMatch.group(2)}'); // avoid "package package:foo"
          } else {
            skipped.add('package ${match.group(2)}');
          }
          continue;
        }
        if (filteredClasses.contains(match.group(1))) {
          skipped.add('class ${match.group(1)}');
          continue;
        }
      }
      result.add(line);
    }
    if (skipped.length == 1) {
      result.add('(elided one frame from ${skipped.single})');
    } else if (skipped.length > 1) {
      final where = Set<String>.from(skipped).toList()..sort();
      if (where.length > 1) where[where.length - 1] = 'and ${where.last}';
      if (where.length > 2) {
        result
            .add('(elided ${skipped.length} frames from ${where.join(", ")})');
      } else {
        result.add('(elided ${skipped.length} frames from ${where.join(" ")})');
      }
    }
    return result;
  }
}
