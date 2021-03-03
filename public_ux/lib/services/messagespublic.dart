import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../i10n/messages_all.dart';

///
/// The main messages class for the system, all the strings that need
/// to be translated.
///
class MessagesPublic {
  final String locale;

  MessagesPublic(this.locale);

  /// Load the messages for the specific locale.
  static Future<MessagesPublic> load(Locale locale) async {
    var name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    var localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _) {
      Intl.defaultLocale = localeName;
      return MessagesPublic(localeName);
    });
  }

  /// The test version.
  static Future<MessagesPublic> loadTest(Locale locale) async {
    return MessagesPublic(locale.toString());
  }

  /// The messages in the system from the context.
  static MessagesPublic of(BuildContext context) {
    return Localizations.of<MessagesPublic>(context, MessagesPublic);
  }
}

///
/// The delegate for the messages to load it with fluff.
///
class MessagesPublicDelegate extends LocalizationsDelegate<MessagesPublic> {
  const MessagesPublicDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  Future<MessagesPublic> load(Locale locale) => MessagesPublic.load(locale);

  @override
  bool shouldReload(MessagesPublicDelegate old) => false;
}

///
/// The delegate for the messages to load it with fluff.
///
class MessagesPublicTestDelegate extends LocalizationsDelegate<MessagesPublic> {
  const MessagesPublicTestDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  Future<MessagesPublic> load(Locale locale) => MessagesPublic.loadTest(locale);

  @override
  bool shouldReload(MessagesPublicDelegate old) => false;
}
