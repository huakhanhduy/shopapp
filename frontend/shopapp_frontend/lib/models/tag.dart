class Tag {

  final String tagName;
  final String icon;

  Tag({
    required this.tagName,
    required this.icon,
  });

  factory Tag.fromJson(
      Map<String,dynamic> json) {

    return Tag(
      tagName:
      json["tagName"] ?? "",

      icon:
      json["icon"] ?? "",
    );
  }
}