import 'product.dart';

class HomeSection {
  final String tagName;
  final String subtitle;

  final List<Product> products;

  HomeSection({
    required this.tagName,
    required this.subtitle,
    required this.products,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      tagName: json["tagName"] ?? "",

      subtitle: json["subtitle"] ?? "",

      products: (json["products"] ?? [])
          .map<Product>((e) => Product.fromJson(e))
          .toList(),
    );
  }
}
