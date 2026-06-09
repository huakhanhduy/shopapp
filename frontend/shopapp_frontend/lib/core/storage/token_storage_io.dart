import 'package:shared_preferences/shared_preferences.dart';
import 'token_storage.dart';

class TokenStorageIO implements TokenStorageImpl {
  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}

TokenStorageImpl getTokenStorageImpl() => TokenStorageIO();
