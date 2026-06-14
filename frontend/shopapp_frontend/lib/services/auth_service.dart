import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';

class AuthService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"];
    }
    throw Exception("Đăng nhập thất bại");
  }

  Future<String> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"];
    }
    final errorMsg = jsonDecode(response.body)["message"] ?? "Đăng ký thất bại";
    throw Exception(errorMsg);
  }

  Future<String> socialLogin({
    required String email,
    required String provider,
    required String providerId,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/social-login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "provider": provider,
        "providerId": providerId,
        "firstName": firstName,
        "lastName": lastName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"];
    }
    final errorMsg = jsonDecode(response.body)["message"] ?? "Đăng nhập bằng mạng xã hội thất bại";
    throw Exception(errorMsg);
  }

  Future<String> socialRegister({
    required String email,
    required String provider,
    required String providerId,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/social-register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "provider": provider,
        "providerId": providerId,
        "firstName": firstName,
        "lastName": lastName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"];
    }
    final errorMsg = jsonDecode(response.body)["message"] ?? "Đăng ký bằng mạng xã hội thất bại";
    throw Exception(errorMsg);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/users/me"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể tải thông tin cá nhân");
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/users/me"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể cập nhật thông tin cá nhân");
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/users/change-password"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<Map<String, dynamic>> getCustomerByEmail(String email) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/customers/email/$email"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể tải thông tin khách hàng");
  }
}