import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';

class PaymentService {
  Future<List<Map<String, dynamic>>> getCards() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/cards"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception("Không thể tải danh sách thẻ thanh toán");
  }

  Future<Map<String, dynamic>> createCard(Map<String, dynamic> request) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/cards"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể thêm thẻ mới");
  }

  Future<Map<String, dynamic>> updateCard(String id, Map<String, dynamic> request) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/cards/$id"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể cập nhật thẻ");
  }

  Future<void> deleteCard(String id) async {
    final token = await TokenStorage.getToken();
    final response = await http.delete(
      Uri.parse("${ApiConstants.baseUrl}/api/cards/$id"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Không thể xóa thẻ");
    }
  }

  Future<Map<String, dynamic>> setDefaultCard(String id) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/cards/$id/default"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể đặt thẻ làm mặc định");
  }
}
