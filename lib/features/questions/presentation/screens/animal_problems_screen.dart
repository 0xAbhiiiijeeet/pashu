import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/widgets/whatsapp_fab.dart';
import '../../../problems/domain/models/problem_model.dart';
import '../../../problems/presentation/providers/problems_provider.dart';
import '../../../home/presentation/widgets/booking_bottom_sheet.dart';
import '../../../home/presentation/widgets/sticky_chip_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Embeddable body — used by both AnimalProblemsScreen and HomeScreen tab 1
// ─────────────────────────────────────────────────────────────────────────────

class AnimalProblemsBody extends StatefulWidget {
  const AnimalProblemsBody({super.key});

  @override
  State<AnimalProblemsBody> createState() => _AnimalProblemsBodyState();
}

class _AnimalProblemsBodyState extends State<AnimalProblemsBody> {
  int _selectedCategoryIndex = 0;
  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
    _scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _onChipTap(ProblemModel problem) {
    // Open booking bottom sheet with problem info
    final l10n = AppLocalizations.of(context);
    showBookingBottomSheet(
      context,
      problemId: problem.id,
      problemLabel: problem.getLocalizedTitle(l10n.isHindi),
    );
  }

  void _onSomethingElse() {
    final l10n = AppLocalizations.of(context);
    final problemsProvider = context.read<ProblemsProvider>();
    
    // Find a "General" category problem, or use the first available problem
    ProblemModel? generalProblem;
    
    // Try to find General category
    try {
      generalProblem = problemsProvider.problems.firstWhere(
        (p) => p.categoryEn.toLowerCase() == 'general' || 
               p.category.toLowerCase() == 'सामान्य',
      );
    } catch (e) {
      // If no General category found, use the first problem
      if (problemsProvider.problems.isNotEmpty) {
        generalProblem = problemsProvider.problems.first;
      }
    }
    
    // If still no problem found, show error
    if (generalProblem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noProblemsAvailable)),
      );
      return;
    }
    
    // Open booking bottom sheet directly with the problem
    showBookingBottomSheet(
      context,
      problemId: generalProblem.id,
      problemLabel: generalProblem.getLocalizedTitle(l10n.isHindi),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problemsProvider = context.watch<ProblemsProvider>();

    debugPrint('🐾 AnimalProblemsBody: ${problemsProvider.problems.length} problems loaded');
    debugPrint('🐾 Loading: ${problemsProvider.isLoading}, Error: ${problemsProvider.errorMessage}');

    // Group problems by category
    final problemsByCategory = <String, List<ProblemModel>>{};
    for (final problem in problemsProvider.problems) {
      final category = problem.getLocalizedCategory(l10n.isHindi);
      if (!problemsByCategory.containsKey(category)) {
        problemsByCategory[category] = [];
      }
      problemsByCategory[category]!.add(problem);
    }

    final categories = problemsByCategory.keys.toList();
    debugPrint('🐾 Categories: ${categories.length}');

    if (problemsProvider.isLoading && problemsProvider.problems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (problemsProvider.errorMessage != null && problemsProvider.problems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.failedToLoadProblems,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => problemsProvider.fetchProblems(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (problemsByCategory.isEmpty) {
      return Center(child: Text(l10n.noProblemsAvailable));
    }

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Sticky Category Header ────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyChipHeaderDelegate(
                categories: categories,
                selectedIndex: _selectedCategoryIndex,
                onCategorySelected: _scrollToCategory,
              ),
            ),

            // ── Problem Sections ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    final problems = problemsByCategory[category]!;
                    return AutoScrollTag(
                      key: ValueKey(index),
                      controller: _scrollController,
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _AnimalProblemSection(
                          category: category,
                          problems: problems,
                          onChipTap: _onChipTap,
                        ),
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
          ],
        ),

        // ── Floating "Something Else" Button ──────────────────────────────
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _onSomethingElse,
            backgroundColor: const Color(0xFFD7E4DA),
            elevation: 4,
            label: Text(
              l10n.isHindi ? 'कुछ और समस्या है?' : 'Something else?',
              style: const TextStyle(
                color: Color(0xFF535735),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF535735),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animal problem section: title + 4-column grid
// ─────────────────────────────────────────────────────────────────────────────

class _AnimalProblemSection extends StatelessWidget {
  final String category;
  final List<ProblemModel> problems;
  final ValueChanged<ProblemModel> onChipTap;

  const _AnimalProblemSection({
    required this.category,
    required this.problems,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemCount: problems.length,
          itemBuilder: (context, i) {
            final problem = problems[i];
            return _SmallChip(
              problem: problem,
              onTap: () => onChipTap(problem),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small square chip used in 4-column grids
// ─────────────────────────────────────────────────────────────────────────────

class _SmallChip extends StatelessWidget {
  final ProblemModel problem;
  final VoidCallback onTap;

  const _SmallChip({
    required this.problem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle with image
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: problem.image != null && problem.image!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: '${ApiEndpoints.baseUrl}${problem.image}',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF666B42),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.pets,
                          size: 24,
                          color: Color(0xFF838967),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.pets,
                      size: 24,
                      color: Color(0xFF838967),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              problem.getLocalizedTitle(l10n.isHindi),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF969696),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Standalone screen — used when navigated to directly via the router
// ─────────────────────────────────────────────────────────────────────────────

class AnimalProblemsScreen extends StatelessWidget {
  const AnimalProblemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Builder(
        builder: (context) {
          final localeProvider = context.watch<LocaleProvider>();
          final isHindi = localeProvider.locale.languageCode == 'hi';
          return WhatsAppFAB(
            customMessage: isHindi 
              ? 'नमस्ते, मुझे पशु मित्र पर मदद चाहिए'
              : 'Hello, I need help from Pashu Mitra',
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: const Color(0xFF666B42),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image.asset(
          'assets/images/pashu_mitra.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: const AnimalProblemsBody(),
    );
  }
}
