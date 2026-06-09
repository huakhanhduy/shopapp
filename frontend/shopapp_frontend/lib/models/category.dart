class Category {

  final String id;

  final String categoryName;

  final String image;

  final String? parentName;

  Category({
    required this.id,
    required this.categoryName,
    required this.image,
    this.parentName,
  });

  factory Category.fromJson(
      Map<String,dynamic> json) {

    String? pName;
    if (json["parent"] != null) {
      pName = json["parent"]["categoryName"];
    }

    return Category(

      id: json["id"] ?? "",

      categoryName:
      json["categoryName"] ?? "",

      image:
      json["image"] ?? "",

      parentName: pName,
    );
  }
}