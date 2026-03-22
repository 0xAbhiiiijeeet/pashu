class ProblemModel {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final bool isActive;

  const ProblemModel({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.isActive,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) => ProblemModel(
        id: json['_id'] as String? ?? json['id'] as String,
        title: json['title'] as String? ?? '',
        titleEn: json['titleEn'] as String? ?? json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        descriptionEn: json['descriptionEn'] as String? ?? json['description'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'titleEn': titleEn,
        'description': description,
        'descriptionEn': descriptionEn,
        'isActive': isActive,
      };
}
