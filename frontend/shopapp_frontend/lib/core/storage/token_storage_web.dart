// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'token_storage.dart';

class TokenStorageWeb implements TokenStorageImpl {
  @override
  Future<void> saveToken(String token) async {
    html.window.sessionStorage['token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return html.window.sessionStorage['token'];
  }

  @override
  Future<void> clear() async {
    html.window.sessionStorage.remove('token');
  }
}

TokenStorageImpl getTokenStorageImpl() => TokenStorageWeb();
