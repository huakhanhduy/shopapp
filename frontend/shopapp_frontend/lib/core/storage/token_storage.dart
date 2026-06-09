import 'token_storage_stub.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_io.dart';

abstract class TokenStorageImpl {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clear();
}

class TokenStorage {
  static final TokenStorageImpl _impl = getTokenStorageImpl();

  static Future<void> saveToken(String token) => _impl.saveToken(token);
  static Future<String?> getToken() => _impl.getToken();
  static Future<void> clear() => _impl.clear();
}