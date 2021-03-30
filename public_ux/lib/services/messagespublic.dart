import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

///
/// The main messages class for the system, all the strings that need
/// to be translated.
///
class MessagesPublic {
  final String locale;

  MessagesPublic(this.locale);

  String get search => Intl.message('Search...',
      desc: 'Title in the search box', locale: locale);

  String get noResults => Intl.message('No Results',
      desc: 'Description in the search results if there is no result',
      locale: locale);

  String get detailsOfflineInformation =>
      Intl.message('\u2022 Works offline with no internet',
          desc: 'Feature description for the app in a list', locale: locale);
  String get detailsMultipleTeamsInformation =>
      Intl.message('\u2022 Handles multiple teams and players in one view',
          desc: 'Feature description for the app in a list', locale: locale);
  String get detailsLeagueControlInformation =>
      Intl.message('\u2022 League control allowing shared offical results',
          desc: 'Feature description for the app in a list', locale: locale);
  String get detailsNotificationsInformation =>
      Intl.message('\u2022 Notifications via mobile and email',
          desc: 'Feature description for the app in a list', locale: locale);
  String get detailsMobileFirstInformation =>
      Intl.message('\u2022 Mobile first! Designed for the phone',
          desc: 'Feature description for the app in a list', locale: locale);

  String get appDescription => Intl.message(
      'TeamsFuse is a cross platform app that '
      'makes dealing with your sports teams easy and simple. '
      'It handles things in a simple consistent manner, allowing for '
      'multiuple players and teams to interact simply and easily with '
      'the main calendar view.',
      desc: 'Description for the app',
      locale: locale);

  String get leagueDescription => Intl.message(
      ' Leagues allow the organization of teams and games into a league. The team can '
      'setup their own team information on top of the league, so the public details '
      'in the league are only the results of the games and their locations. The '
      'league can control and setup official results, also allowing the teams to '
      'record their own results during games.',
      desc: 'Description of the league system',
      locale: locale);

  String get leagueDetailsResults =>
      Intl.message('\u2022 Official results and team results',
          desc: 'Feaute of the leagues in the app', locale: locale);
  String get leagueDetailsGameControl =>
      Intl.message('\u2022 League controlled game time/place details',
          desc: 'Feaute of the leagues in the app', locale: locale);
  String get leagueDetailsTeamInterface => Intl.message(
      '\u2022 Team controlled additional information and roster details',
      desc: 'Feaute of the leagues in the app',
      locale: locale);
  String get leagueDetailsLeagueStats =>
      Intl.message('\u2022 Team win records and ranking',
          desc: 'Feaute of the leagues in the app', locale: locale);
  String get leagueDetailsLeagueOlder =>
      Intl.message('\u2022 Older season details for comparison',
          desc: 'Feaute of the leagues in the app', locale: locale);

  String get featuresHeader => Intl.message('Features',
      desc: 'Title for the features section', locale: locale);

  String get tournamentsDescription => Intl.message(
      'Tournaments allow the organization of teams and games into a tournament. The '
      'team can setup their own team information on top of the tournament, so the '
      'public details in the tournament are only the results of the games and their '
      'locations. The tournament can control and setup official results, also '
      'allowing the teams to record their own results during games.',
      locale: locale,
      desc: 'Description of the tourament details');
  String get tournamentDetailsResults =>
      Intl.message('\u2022 Official results and team results',
          desc: 'Feaute of the leagues in the app', locale: locale);
  String get tournamentDetailsTimePlace =>
      Intl.message('\u2022 Tournament controlled game time/place details',
          desc: 'Feature of the leagues in the app', locale: locale);
  String get tournamentDetailsAdditonalDetails => Intl.message(
      '\u2022 Team controlled additional information and roster details',
      desc: 'Feature of the leagues in the app',
      locale: locale);
  String get tournamentDetailsRanking =>
      Intl.message('\u2022 Team win records and ranking',
          desc: 'Feaute of the leagues in the app', locale: locale);
  String get tournamentDetailsPerTeam =>
      Intl.message('\u2022 Multiple tournaments/leagues per team/season',
          desc: 'Feaute of the leagues in the app', locale: locale);

  String get headerAbout => Intl.message('About', desc: 'About section header');
  String get headerTournament =>
      Intl.message('Tournament', desc: 'Tounament section header');
  String get headerLeague =>
      Intl.message('League', desc: 'League section header');
  String get media => Intl.message('Media', desc: 'Media section header');

  String get playersButton =>
      Intl.message('PLAYERS', desc: 'Button to show the players in a club');
  String get teamsButton =>
      Intl.message('TEAMS', desc: 'Button to show the teams in a club');
  String get coachesButton =>
      Intl.message('COACHES', desc: 'Button to show the coaches in a club');
  String get newsButton =>
      Intl.message('NEWS', desc: 'Button to show the coaches in a club');
  String get aboutButton =>
      Intl.message('ABOUT', desc: 'Button to show the coaches in a club');

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
