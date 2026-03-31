import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../bookings/domain/models/booking_model.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../problems/presentation/providers/problems_provider.dart';
import '../../../problems/domain/models/problem_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'booking_bottom_sheet.dart';
import 'sticky_chip_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vertical bullet point used in the Benefits card
// ─────────────────────────────────────────────────────────────────────────────

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF797979),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Benefits card shown at the top of the home tab
// ─────────────────────────────────────────────────────────────────────────────

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main content ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title — full width
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.toAvoidLosses,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      TextSpan(
                        text: l10n.callBookedWith,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Date — full width
                Text(
                  l10n.todayBetween,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                  ),
                ),

                const SizedBox(height: 10),

                // Bullet points on left, telephone image on right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BulletPoint(l10n.savingsPerYear),
                          _BulletPoint(l10n.extraEarnings),
                          _BulletPoint(l10n.homeRemedy),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/images/telephone.png',
                      width: 85,
                      height: 85,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Footer strip ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF5F5F5),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/charm_notes-tick.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.whatMitraTells,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wide chip — used for the first 2 items in Talk-to-Bhai section
// ─────────────────────────────────────────────────────────────────────────────

class _WideChip extends StatelessWidget {
  final ProblemModel problem;
  final bool isSelected;
  final VoidCallback onTap;

  const _WideChip({
    required this.problem,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(38),
              ),
              child: problem.image != null && problem.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: CachedNetworkImage(
                        imageUrl: '${ApiEndpoints.baseUrl}${problem.image}',
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF666B42),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.pets,
                          size: 28,
                          color: Color(0xFF838967),
                        ),
                      ),
                    )
                  : const Icon(Icons.pets, size: 28, color: Color(0xFF838967)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                problem.getLocalizedTitle(l10n.isHindi),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF535735)
                      : const Color(0xFF969696),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
// Small square chip used in 4-column grids
// ─────────────────────────────────────────────────────────────────────────────

class _SmallChip extends StatelessWidget {
  final ProblemModel problem;
  final bool isSelected;
  final VoidCallback onTap;

  const _SmallChip({
    required this.problem,
    required this.isSelected,
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
          color: isSelected ? const Color(0xFFE8EDD8) : const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isSelected
                ? const BorderSide(color: Color(0xFF838967), width: 1.5)
                : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: problem.image != null && problem.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(38),
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
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF535735)
                    : const Color(0xFF969696),
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
// 4-column grid of small chips
// ─────────────────────────────────────────────────────────────────────────────

class _FourColumnGrid extends StatelessWidget {
  final List<ProblemModel> problems;
  final String? selectedId;
  final ValueChanged<String> onTap;

  const _FourColumnGrid({
    required this.problems,
    required this.selectedId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
          isSelected: selectedId == problem.id,
          onTap: () => onTap(problem.id),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home tab — the full scrollable home content
// ─────────────────────────────────────────────────────────────────────────────

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _selectedId;

  // Header state
  int _selectedCategoryIndex = 0;
  late AutoScrollController _scrollController;

  void _toggle(String problemId) {
    setState(() {
      // Single select: if already selected, deselect; otherwise select the new one
      _selectedId = (_selectedId == problemId) ? null : problemId;
    });
  }

  void _onChipTap(String problemId, String problemLabel) {
    _toggle(problemId);
    showBookingBottomSheet(
      context,
      problemId: problemId,
      problemLabel: problemLabel,
    );
  }

  void _scrollToCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
    _scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController();
    // Bookings and Problems are already loaded from cache and fetched in their init() methods
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeBkg = context.watch<BookingsProvider>().activeBooking;
    final problemsProvider = context.watch<ProblemsProvider>();
    
    final allProblems = problemsProvider.problems.where((p) => p.isActive).toList();
    final problemsByCategory = problemsProvider.problemsByCategory;
    final categories = problemsByCategory.keys.toList();
    
    // Create localized category names for the sticky header
    final localizedCategories = categories.map((category) {
      final problemsInCategory = problemsByCategory[category] ?? [];
      if (problemsInCategory.isNotEmpty) {
        return problemsInCategory.first.getLocalizedCategory(l10n.isHindi);
      }
      return category;
    }).toList();
    
    // Take first 2 for wide chips, rest for small chips
    final wideProblems = allProblems.take(2).toList();
    final smallProblems = allProblems.skip(2).take(12).toList(); // Take next 12 for grid

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Booked call banner (shown when a pending booking exists) ──
              if (activeBkg != null) ...[
                _BookedCallBanner(booking: activeBkg),
                const SizedBox(height: 14)
              ],

              // ── Benefits card ─────────────────────────────────────────────
              const _BenefitsCard(),

              const SizedBox(height: 16),

              // ── Milk Khata Button ─────────────────────────────────────────
              _MilkKhataButton(),

              const SizedBox(height: 24),

              // ── Talk to pashu bhai ────────────────────────────────────────
              Text(
                l10n.talkToPashuMitra,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                ),
              ),
              const SizedBox(height: 12),

              // Show loading or error state for problems
              if (problemsProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (problemsProvider.errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          l10n.failedToLoadProblems,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => problemsProvider.fetchProblems(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (allProblems.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No problems available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else ...[
                // Wide chips (first 2) — one row
                if (wideProblems.length >= 2)
                  Row(
                    children: [
                      Expanded(
                        child: _WideChip(
                          problem: wideProblems[0],
                          isSelected: _selectedId == wideProblems[0].id,
                          onTap: () => _onChipTap(wideProblems[0].id, wideProblems[0].titleEn),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _WideChip(
                          problem: wideProblems[1],
                          isSelected: _selectedId == wideProblems[1].id,
                          onTap: () => _onChipTap(wideProblems[1].id, wideProblems[1].titleEn),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                // 4-column grid (remaining items)
                if (smallProblems.isNotEmpty)
                  _FourColumnGrid(
                    problems: smallProblems,
                    selectedId: _selectedId,
                    onTap: (id) {
                      final problem = problemsProvider.getProblemById(id);
                      if (problem != null) {
                        _onChipTap(id, problem.titleEn);
                      }
                    },
                  ),

                const SizedBox(height: 12),

                // "or something else" pill
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/animal-problems'),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.orSomethingElse,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Animal Problems categories ─────────────────────────────────────
                if (categories.isNotEmpty) ...[
                  Text(
                    l10n.animalProblems,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ]),
          ),
        ),

        // ── Sticky Header (Chips) ────────────────────────────────────────────────
        if (categories.isNotEmpty && !problemsProvider.isLoading)
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyChipHeaderDelegate(
              categories: localizedCategories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: _scrollToCategory,
            ),
          ),

        // ── The Animal Problem Sections ──────────────────────────────────────────
        if (categories.isNotEmpty && !problemsProvider.isLoading)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categories[index];
                  final problems = problemsByCategory[category] ?? [];
                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: _scrollController,
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _AnimalProblemSection(
                        category: category,
                        problems: problems,
                        selectedId: _selectedId,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animal problem section: bold title + 4-column grid
// ─────────────────────────────────────────────────────────────────────────────

class _AnimalProblemSection extends StatelessWidget {
  final String category;
  final List<ProblemModel> problems;
  final String? selectedId;
  final Function(String, String) onChipTap;

  const _AnimalProblemSection({
    required this.category,
    required this.problems,
    required this.selectedId,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Use the first problem's localized category for display
    final displayCategory = problems.isNotEmpty
        ? problems.first.getLocalizedCategory(l10n.isHindi)
        : category;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            displayCategory,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ),
        _FourColumnGrid(
          problems: problems,
          selectedId: selectedId,
          onTap: (id) {
            final problem = problems.firstWhere((p) => p.id == id);
            onChipTap(id, problem.getLocalizedTitle(l10n.isHindi));
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner shown at the top when user has an active upcoming booking
// ─────────────────────────────────────────────────────────────────────────────

class _BookedCallBanner extends StatelessWidget {
  final BookingModel booking;
  const _BookedCallBanner({required this.booking});

  /// Maps the scheduledTime hour to a human-readable slot range label.
  String _getSlotLabel(AppLocalizations l10n) {
    final h = booking.scheduledTime.hour;
    if (h < 12) return l10n.between9to12;
    if (h < 15) return l10n.between12to3;
    return l10n.between3to6;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFD7E4DA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.callBookedTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.friendWillCall,
                  style: const TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getSlotLabel(l10n),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF666B42),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Milk Khata Button
// ─────────────────────────────────────────────────────────────────────────────

class _MilkKhataButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/milk-khata');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.book,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'दूध खाता',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ग्राहकों का दूध हिसाब रखें',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
