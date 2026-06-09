import 'home_section.dart';

class HomeResponse {
  final List<String> banners;

  final List<HomeSection> sections;

  HomeResponse({required this.banners, required this.sections});

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      banners: List<String>.from(json["banners"] ?? []),

      sections: (json["sections"] ?? [])
          .map<HomeSection>((e) => HomeSection.fromJson(e))
          .toList(),
    );
  }
}
