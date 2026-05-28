import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';

  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() => _prefs.getString(_tokenKey);

  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(_emailKey, email);
  }

  String? getUserEmail() => _prefs.getString(_emailKey);

  Future<void> saveUserName(String name) async {
    await _prefs.setString(_nameKey, name);
  }

  String? getUserName() => _prefs.getString(_nameKey);

  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_nameKey);
  }

  bool get isLoggedIn => getToken() != null;
}
