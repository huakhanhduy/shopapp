class Product {

  final String id;

  final String productName;

  final String imageUrl;

  final double regularPrice;

  final double discountPrice;

  final String shortDescription;

  final String productDescription;

  final double averageRating;

  final int quantity;

  Product({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.regularPrice,
    required this.discountPrice,
    this.shortDescription = "",
    this.productDescription = "",
    this.averageRating = 5.0,
    this.quantity = 10,
  });

  factory Product.fromJson(
      Map<String,dynamic> json) {

    return Product(

      id: json["id"] ?? "",

      productName:
      json["productName"] ?? "",

      imageUrl:
      json["imageUrl"] ?? "",

      regularPrice:
      (json["regularPrice"] ?? 0)
          .toDouble(),

      discountPrice:
      (json["discountPrice"] ?? 0)
          .toDouble(),

      shortDescription:
      json["shortDescription"] ?? "",

      productDescription:
      json["productDescription"] ?? "",

      averageRating:
      (json["averageRating"] ?? 5.0)
          .toDouble(),

      quantity:
      json["quantity"] ?? 10,
    );
  }
}