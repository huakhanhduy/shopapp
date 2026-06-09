import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';

class PromoService {
  Future<List<Map<String, dynamic>>> getPromoCodes() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/promocodes"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception("Không thể tải danh sách mã giảm giá");
  }

  Future<Map<String, dynamic>> validatePromoCode(String code) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/promocodes/validate?code=$code"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Mã giảm giá không hợp lệ");
  }
}
