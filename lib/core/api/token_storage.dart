import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  // Profile image is stored per-user so a different account doesn't inherit it.
  static const String _imagePathPrefix = 'profile_image_';

  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  String _imageKeyFor(String email) => '$_imagePathPrefix$email';

  /// Persists the local file path of the current user's profile image.
  Future<void> saveProfileImagePath(String path) async {
    final email = getUserEmail();
    if (email == null || email.isEmpty) return;
    await _prefs.setString(_imageKeyFor(email), path);
  }

  /// Returns the saved profile image path for the current user, if any.
  String? getProfileImagePath() {
    final email = getUserEmail();
    if (email == null || email.isEmpty) return null;
    return _prefs.getString(_imageKeyFor(email));
  }

  Future<void> clearProfileImagePath() async {
    final email = getUserEmail();
    if (email == null || email.isEmpty) return;
    await _prefs.remove(_imageKeyFor(email));
  }

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
    // Clear the per-user image key first — it depends on the stored email.
    await clearProfileImagePath();
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_nameKey);
  }

  bool get isLoggedIn => getToken() != null;
}
