import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_local/config/global.dart';

import 'package:hyper_local/config/localization_bloc/localization_event.dart';
import 'package:hyper_local/config/localization_bloc/localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  static const String _defaultLanguage = 'en';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('fr'),
    Locale('ar'),
    Locale('te'),
    Locale('gu'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'fr': 'Français',
    'ar': 'العربية',
    'te': 'తెలుగు',
    'gu': 'ગુજરાતી',
  };

  static const Map<String, String> languageNamesEnglish = {
    'en': 'English',
    'hi': 'Hindi',
    'fr': 'French',
    'ar': 'Arabic',
    'te': 'Telugu',
    'gu': 'Gujarati',
  };

  static const List<String> rtlLanguages = ['ar'];

  LocalizationBloc() : super(const LocalizationState()) {
    on<LoadSavedLocale>(_onLoadSavedLocale);
    on<ChangeLocale>(_onChangeLocale);
    on<ResetLocale>(_onResetLocale);
  }

  Future<void> _onLoadSavedLocale(
    LoadSavedLocale event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      final savedLanguage = await Global.getLanguage() ?? _defaultLanguage;
      emit(state.copyWith(locale: Locale(savedLanguage)));
    } catch (e) {
      emit(state.copyWith(locale: const Locale(_defaultLanguage)));
    }
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<LocalizationState> emit,
  ) async {
    if (!supportedLocales.any((l) => l.languageCode == event.languageCode)) {
      return;
    }

    final newLocale = Locale(event.languageCode);

    try {
      await Global.setLanguage(event.languageCode);
    } catch (e) {
      //
    }

    if (rtlLanguages.contains(event.languageCode)) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    emit(state.copyWith(locale: newLocale));
  }

  Future<void> _onResetLocale(
    ResetLocale event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      await Global.setLanguage(_defaultLanguage);
    } catch (e) {
      //
    }
    emit(state.copyWith(locale: const Locale(_defaultLanguage)));
  }

  // Helper getters (same API surface as old LocalizationService)
  String get currentLanguageCode => state.languageCode;
  bool get isRTL => state.isRTL;

  String getLanguageName(String code) => languageNames[code] ?? code;
  String getLanguageNameEnglish(String code) =>
      languageNamesEnglish[code] ?? code;

  List<Map<String, dynamic>> getAvailableLanguages() {
    return supportedLocales.map((locale) {
      final code = locale.languageCode;
      return {
        'code': code,
        'name': languageNames[code] ?? code,
        'nameEnglish': languageNamesEnglish[code] ?? code,
        'isRTL': rtlLanguages.contains(code),
      };
    }).toList();
  }
}
