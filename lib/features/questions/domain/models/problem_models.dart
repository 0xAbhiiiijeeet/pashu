import 'package:flutter/foundation.dart';

/// Domain models for the Animal Problems feature.
class ProblemItem {
  final String label;
  final String? iconAsset; // e.g. 'assets/icons/fever.png'
  final VoidCallback? onTap;

  const ProblemItem({
    required this.label,
    this.iconAsset,
    this.onTap,
  });
}

class ProblemSection {
  final String title;
  final List<ProblemItem> items;

  const ProblemSection({required this.title, required this.items});
}

class ProblemCategory {
  final String categoryTitle;
  final List<ProblemSection> sections;

  const ProblemCategory({
    required this.categoryTitle,
    required this.sections,
  });
}
