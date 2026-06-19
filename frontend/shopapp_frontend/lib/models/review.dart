import 'product.dart';

class Review {
  final String id;
  final String userName;
  final String customerId;
  final String customerEmail;
  final int rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final Product? product;

  Review({
    required this.id,
    required this.userName,
    required this.customerId,
    required this.customerEmail,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
    this.product,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final userJson = (json['customer'] ?? json['user']) as Map<String, dynamic>?;
    final firstName = userJson?['firstName'] ?? '';
    final lastName = userJson?['lastName'] ?? '';
    final userName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : (userJson?['email'] ?? 'Anonymous');

    final imagesJson = json['images'] as List<dynamic>?;
    final List<String> images = imagesJson?.map((e) => e.toString()).toList() ?? [];

    Product? productObj;
    if (json['product'] != null) {
      productObj = Product.fromJson(json['product'] as Map<String, dynamic>);
    }

    return Review(
      id: json['id'] ?? '',
      userName: userName,
      customerId: userJson?['id'] ?? '',
      customerEmail: userJson?['email'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      images: images,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      product: productObj,
    );
  }
}
