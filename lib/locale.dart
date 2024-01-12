import 'dart:async';

import 'package:flutter/widgets.dart';

class LocaleBloc {
  static final StreamController<Locale> _localeController = StreamController<Locale>.broadcast();

  static Stream<Locale> get localeStream => _localeController.stream;

  static void changeLocale(Locale newLocale) {
    _localeController.sink.add(newLocale);
  }

  static void changeLocaleFromLanguageSetup(String languageSetup) {
    final Locale locale = splitLanguage(languageSetup);
    _localeController.sink.add(locale);
  }

  static void dispose() {
    _localeController.close();
  }

  static Locale splitLanguage(String languageSetup) {
    final String language;
    final String languageScript;
    final String country;
    final Locale locale;

    final splitLanguage = languageSetup.split('_');
    switch (splitLanguage.length) {
      case 1:
        language = splitLanguage[0];
        locale = Locale.fromSubtags(languageCode: language);
        break;
      case 2:
        language = splitLanguage[0];
        country = splitLanguage[1];
        locale = Locale.fromSubtags(languageCode: language, countryCode: country);
        break;
      case 3:
        language = splitLanguage[0];
        languageScript = splitLanguage[1];
        country = splitLanguage[2];
        locale = Locale.fromSubtags(languageCode: language, countryCode: country, scriptCode: languageScript);
        break;
      default:
        locale = const Locale.fromSubtags(languageCode: 'en');
    }
    return locale;
  }
}
