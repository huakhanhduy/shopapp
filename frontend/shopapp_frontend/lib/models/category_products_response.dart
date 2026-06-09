import 'product.dart';

class CategoryProductsResponse {

  final String categoryId;

  final String categoryName;

  final String image;

  final List<Product> products;

  CategoryProductsResponse({

    required this.categoryId,

    required this.categoryName,

    required this.image,

    required this.products,
  });

  factory CategoryProductsResponse.fromJson(
      Map<String,dynamic> json
      ) {

    return CategoryProductsResponse(

      categoryId:
      json["categoryId"] ?? "",

      categoryName:
      json["categoryName"] ?? "",

      image:
      json["image"] ?? "",

      products:

      (json["products"] as List)

          .map(
            (e) =>
                Product.fromJson(e),
      )

          .toList(),
    );
  }
}