import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../i10n/messages_all.dart';

///
/// The main messages class for the system, all the strings that need
/// to be translated.
///
class Messages {
  final String locale;

  Messages(this.locale);

  String get loading => Intl.message("Loading...",
      locale: locale,
      desc: "THe message to display when tomsehting is loading");

  String get deleted => Intl.message("Deleted.",
      locale: locale,
      desc: "THe message to display when tomsehting is deleted");

  /// Load the messages for the specific locale.
  static Future<Messages> load(Locale locale) async {
    var name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    var localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _) {
      Intl.defaultLocale = localeName;
      return Messages(localeName);
    });
  }

  /// The test version.
  static Future<Messages> loadTest(Locale locale) async {
    return Messages(locale.toString());
  }

  /// The messages in the system from the context.
  static Messages of(BuildContext context) {
    return Localizations.of<Messages>(context, Messages);
  }
}

///
/// The delegate for the messages to load it with fluff.
///
class MessagesDelegate extends LocalizationsDelegate<Messages> {
  const MessagesDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  Future<Messages> load(Locale locale) => Messages.load(locale);

  @override
  bool shouldReload(MessagesDelegate old) => false;
}

///
/// The delegate for the messages to load it with fluff.
///
class MessagesTestDelegate extends LocalizationsDelegate<Messages> {
  const MessagesTestDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  Future<Messages> load(Locale locale) => Messages.loadTest(locale);

  @override
  bool shouldReload(MessagesDelegate old) => false;
}

class QuoteAndAuthor {
  String quote;

  String author;

  QuoteAndAuthor({this.quote, this.author});
}
