import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_fuse/i10n/messages_all.dart';

class Messages {
  static Future<Messages> load(Locale locale) async {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _)  {
      Intl.defaultLocale = localeName;
      return new Messages();
    });
  }

  static Messages of(BuildContext context) {
    return Localizations.of<Messages>(context, Messages);
  }

  String get title {
    return Intl.message(
      'Team Fuse',
      name: 'title',
      desc: 'Title for the Team Fuse application',
    );
  }
}

class MessagesDelegate extends LocalizationsDelegate<Messages> {
  const MessagesDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<Messages> load(Locale locale) => Messages.load(locale);

  @override
  bool shouldReload(MessagesDelegate old) => false;
}