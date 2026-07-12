import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kTokenKey = 'jwt_token';

class AuthTokenNotifier extends StateNotifier<String?> {
  AuthTokenNotifier(this._prefs, String? initial) : super(initial);

  final SharedPreferences? _prefs;

  Future<void> setToken(String token) async {
    await _prefs?.setString(_kTokenKey, token);
    state = token;
  }

  Future<void> clearToken() async {
    await _prefs?.remove(_kTokenKey);
    state = null;
  }
}

// Default: in-memory only. main.dart overrides with SharedPreferences-backed instance.
final authTokenProvider =
    StateNotifierProvider<AuthTokenNotifier, String?>(
  (ref) => AuthTokenNotifier(null, null),
);
