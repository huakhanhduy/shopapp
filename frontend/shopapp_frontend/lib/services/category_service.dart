import 'dart:convert';

import 'package:http/http.dart'
as http;

import '../core/constants/api_constants.dart';
import '../models/category.dart';
import '../models/category_products_response.dart';

class CategoryService {

  Future<List<Category>>
  getCategories() async {

    final response =
    await http.get(

      Uri.parse(
        "${ApiConstants.baseUrl}/api/categories",
      ),
    );

    if(response.statusCode != 200){

      throw Exception(
        "Cannot load categories",
      );
    }

    final data =
    jsonDecode(response.body);

    return data

        .map<Category>(
          (e) =>
              Category.fromJson(e),
    )

        .toList();
  }

  Future<CategoryProductsResponse>
  getProductsByCategory(
      String categoryId
      ) async {

    final response =
    await http.get(

      Uri.parse(

        "${ApiConstants.baseUrl}/api/categories/$categoryId/products",
      ),
    );

    if(response.statusCode != 200){

      throw Exception(
        "Cannot load products",
      );
    }

    return CategoryProductsResponse
        .fromJson(

      jsonDecode(
        response.body,
      ),
    );
  }
}