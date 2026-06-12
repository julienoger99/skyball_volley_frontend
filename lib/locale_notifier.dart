import 'package:flutter/material.dart';

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr'));

  static const supported = [
    Locale('fr'),
    Locale('en'),
    Locale('pt'),
  ];

  void setLocale(Locale locale) => value = locale;
}

final localeNotifier = LocaleNotifier();
