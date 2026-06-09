import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/product.dart';

class ProductService {
  Future<Product> getProductById(String id) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/products/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception("Cannot load product details");
    }

    return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<List<Product>> getRelatedProducts(String id) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/products/$id/related"),
    );

    if (response.statusCode != 200) {
      throw Exception("Cannot load related products");
    }

    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> getProductsFiltered({
    String? keyword,
    double? minPrice,
    double? maxPrice,
    String? size,
    String? color,
    String? sort,
    String? categoryId,
  }) async {
    final Map<String, String> queryParams = {};
    if (keyword != null && keyword.isNotEmpty) queryParams["keyword"] = keyword;
    if (minPrice != null) queryParams["minPrice"] = minPrice.toString();
    if (maxPrice != null) queryParams["maxPrice"] = maxPrice.toString();
    if (size != null && size.isNotEmpty) queryParams["size"] = size;
    if (color != null && color.isNotEmpty) queryParams["color"] = color;
    if (sort != null && sort.isNotEmpty) queryParams["sort"] = sort;
    if (categoryId != null && categoryId.isNotEmpty) queryParams["categoryId"] = categoryId;

    final uri = Uri.parse("${ApiConstants.baseUrl}/api/products")
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception("Cannot load filtered products");
  }

  Future<List<Product>> getVisualSearchResults() async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/products/visual-search"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception("Cannot load visual search results");
  }
}
