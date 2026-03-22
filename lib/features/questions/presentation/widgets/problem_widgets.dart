import 'package:flutter/material.dart';

import '../../domain/models/problem_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Single problem chip — icon circle + label
// ─────────────────────────────────────────────────────────────────────────────

class ProblemChip extends StatelessWidget {
  final ProblemItem item;
  final bool isSelected;

  const ProblemChip({
    super.key,
    required this.item,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: 79,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFE8EDD8) : const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isSelected
                ? const BorderSide(color: Color(0xFF838967), width: 1.5)
                : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle — swap with Image.asset once real assets land
            Container(
              width: 52,
              height: 52,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(38)),
                ),
              ),
              child: item.iconAsset != null && item.iconAsset!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: Image.asset(
                        item.iconAsset!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.pets,
                      size: 24,
                      color: Color(0xFF838967),
                    ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF535735)
                      : const Color(0xFF969696),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section title + chip grid
// ─────────────────────────────────────────────────────────────────────────────

class ProblemSectionWidget extends StatelessWidget {
  final ProblemSection section;
  final Set<String> selectedLabels;
  final ValueChanged<String> onChipTap;

  const ProblemSectionWidget({
    super.key,
    required this.section,
    required this.selectedLabels,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            section.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.05,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: section.items.map((item) {
            return ProblemChip(
              item: ProblemItem(
                label: item.label,
                iconAsset: item.iconAsset,
                onTap: () => onChipTap(item.label),
              ),
              isSelected: selectedLabels.contains(item.label),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category heading + all its sections
// ─────────────────────────────────────────────────────────────────────────────

class ProblemCategoryWidget extends StatelessWidget {
  final ProblemCategory category;
  final Set<String> selectedLabels;
  final ValueChanged<String> onChipTap;

  const ProblemCategoryWidget({
    super.key,
    required this.category,
    required this.selectedLabels,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            category.categoryTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        ...category.sections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ProblemSectionWidget(
              section: section,
              selectedLabels: selectedLabels,
              onChipTap: onChipTap,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Talk to Animal Brother" header section
// ─────────────────────────────────────────────────────────────────────────────

class TalkToBrotherSection extends StatelessWidget {
  final List<ProblemItem> items;
  final Set<String> selectedLabels;
  final ValueChanged<String> onChipTap;
  final VoidCallback? onSomethingElse;

  const TalkToBrotherSection({
    super.key,
    required this.items,
    required this.selectedLabels,
    required this.onChipTap,
    this.onSomethingElse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Talk to Animal Brother',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            height: 1.10,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return ProblemChip(
              item: ProblemItem(
                label: item.label,
                iconAsset: item.iconAsset,
                onTap: () => onChipTap(item.label),
              ),
              isSelected: selectedLabels.contains(item.label),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onSomethingElse,
          child: Container(
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'or something else',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
