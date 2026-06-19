import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/review.dart';

class ReviewService {
  Future<List<Review>> getReviews(String productId) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/products/$productId/reviews"),
    );

    if (response.statusCode != 200) {
      throw Exception("Cannot load product reviews");
    }

    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Review.fromJson(json)).toList();
  }

  Future<Review> createReview({
    required String productId,
    required int rating,
    required String comment,
    required List<XFile> images,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("You must be logged in to write a review");
    }

    final uri = Uri.parse("${ApiConstants.baseUrl}/api/products/$productId/reviews");
    final request = http.MultipartRequest("POST", uri);
    
    request.headers["Authorization"] = "Bearer $token";
    
    request.fields["rating"] = rating.toString();
    request.fields["comment"] = comment;

    for (final file in images) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          "images",
          bytes,
          filename: file.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body["message"] ?? "Cannot post review");
      } catch (_) {
        throw Exception("Cannot post review (Status: ${response.statusCode})");
      }
    }

    return Review.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<List<Review>> getMyReviews() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("You must be logged in to load reviews");
    }

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/products/reviews/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Cannot load your reviews");
    }

    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Review.fromJson(json)).toList();
  }
}
