import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';

class AddressService {
  Future<List<Map<String, dynamic>>> getAddresses() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/addresses"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception("Không thể tải danh sách địa chỉ");
  }

  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> request) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/addresses"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể thêm địa chỉ");
  }

  Future<Map<String, dynamic>> updateAddress(String id, Map<String, dynamic> request) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/addresses/$id"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể cập nhật địa chỉ");
  }

  Future<void> deleteAddress(String id) async {
    final token = await TokenStorage.getToken();
    final response = await http.delete(
      Uri.parse("${ApiConstants.baseUrl}/api/addresses/$id"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Không thể xóa địa chỉ");
    }
  }

  Future<Map<String, dynamic>> setDefaultAddress(String id) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/addresses/$id/default"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Không thể đặt làm mặc định");
  }
}
