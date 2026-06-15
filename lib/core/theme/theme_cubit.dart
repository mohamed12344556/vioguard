import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls the app-wide [ThemeMode] (light / dark).
///
/// The choice is persisted locally so it applies instantly on the next launch,
/// and can be hydrated from the backend profile preference via [setDarkMode].
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefsKey = 'is_dark_mode';

  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_initialMode(_prefs));

  static ThemeMode _initialMode(SharedPreferences prefs) {
    final stored = prefs.getBool(_prefsKey);
    if (stored == null) return ThemeMode.system;
    return stored ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => state == ThemeMode.dark;

  /// Applies and persists the dark-mode choice.
  Future<void> setDarkMode(bool isDark) async {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
    await _prefs.setBool(_prefsKey, isDark);
  }

  /// Hydrates the theme from a backend preference without overriding a choice
  /// the user has already made locally.
  Future<void> hydrateFromBackend(bool isDark) async {
    if (_prefs.getBool(_prefsKey) != null) return;
    await setDarkMode(isDark);
  }

  Future<void> toggle() => setDarkMode(!isDarkMode);
}
