import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for lokal lagring av bruker-innstillinger
class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  SharedPreferences? _prefs;
  
  SettingsNotifier() : super({}) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    state = {
      'darkMode': _prefs?.getBool('darkMode') ?? false,
      'notificationsEnabled': _prefs?.getBool('notificationsEnabled') ?? true,
      'soundEnabled': _prefs?.getBool('soundEnabled') ?? true,
      'vibrationEnabled': _prefs?.getBool('vibrationEnabled') ?? true,
      'language': _prefs?.getString('language') ?? 'nb',
    };
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('darkMode', value);
    state = {...state, 'darkMode': value};
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool('notificationsEnabled', value);
    state = {...state, 'notificationsEnabled': value};
  }

  Future<void> setSoundEnabled(bool value) async {
    await _prefs?.setBool('soundEnabled', value);
    state = {...state, 'soundEnabled': value};
  }

  Future<void> setVibrationEnabled(bool value) async {
    await _prefs?.setBool('vibrationEnabled', value);
    state = {...state, 'vibrationEnabled': value};
  }

  Future<void> setLanguage(String value) async {
    await _prefs?.setString('language', value);
    state = {...state, 'language': value};
  }
}

/// Provider for SettingsNotifier
final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier();
});

/// Provider for lagrede kø-koder (favoritter)
class SavedQueuesNotifier extends StateNotifier<List<String>> {
  SharedPreferences? _prefs;
  static const String _key = 'saved_queue_codes';
  
  SavedQueuesNotifier() : super([]) {
    _loadSavedQueues();
  }

  Future<void> _loadSavedQueues() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs?.getStringList(_key) ?? [];
  }

  Future<void> saveQueue(String queueCode) async {
    if (!state.contains(queueCode)) {
      final newState = [...state, queueCode];
      await _prefs?.setStringList(_key, newState);
      state = newState;
    }
  }

  Future<void> removeQueue(String queueCode) async {
    final newState = state.where((code) => code != queueCode).toList();
    await _prefs?.setStringList(_key, newState);
    state = newState;
  }

  bool isSaved(String queueCode) {
    return state.contains(queueCode);
  }
}

/// Provider for SavedQueuesNotifier
final savedQueuesProvider = StateNotifierProvider<SavedQueuesNotifier, List<String>>((ref) {
  return SavedQueuesNotifier();
});

/// Provider for sist brukte kø-koder
class RecentQueuesNotifier extends StateNotifier<List<String>> {
  SharedPreferences? _prefs;
  static const String _key = 'recent_queue_codes';
  static const int _maxRecent = 10;
  
  RecentQueuesNotifier() : super([]) {
    _loadRecentQueues();
  }

  Future<void> _loadRecentQueues() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs?.getStringList(_key) ?? [];
  }

  Future<void> addRecent(String queueCode) async {
    // Fjern hvis finnes, legg til først, behold maks 10
    var newState = state.where((code) => code != queueCode).toList();
    newState = [queueCode, ...newState];
    if (newState.length > _maxRecent) {
      newState = newState.sublist(0, _maxRecent);
    }
    await _prefs?.setStringList(_key, newState);
    state = newState;
  }

  Future<void> clearRecent() async {
    await _prefs?.remove(_key);
    state = [];
  }
}

/// Provider for RecentQueuesNotifier
final recentQueuesProvider = StateNotifierProvider<RecentQueuesNotifier, List<String>>((ref) {
  return RecentQueuesNotifier();
});
