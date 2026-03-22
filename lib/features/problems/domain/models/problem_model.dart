class ProblemModel {
  final String id;
  final String title;
  final String titleEn;
  final String? description;
  final String? descriptionEn;
  final String category;
  final String categoryEn;
  final String? image;
  final bool isActive;

  const ProblemModel({
    required this.id,
    required this.title,
    required this.titleEn,
    this.description,
    this.descriptionEn,
    required this.category,
    required this.categoryEn,
    this.image,
    this.isActive = true,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      description: json['description']?.toString(),
      descriptionEn: json['descriptionEn']?.toString(),
      category: json['category']?.toString() ?? '',
      categoryEn: json['categoryEn']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'titleEn': titleEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'category': category,
      'categoryEn': categoryEn,
      'image': image,
      'isActive': isActive,
    };
  }

  // Localization helpers
  String getLocalizedTitle(bool isHindi) => isHindi ? title : titleEn;
  String? getLocalizedDescription(bool isHindi) => isHindi ? description : descriptionEn;
  String getLocalizedCategory(bool isHindi) => isHindi ? category : categoryEn;
}
