import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/milk_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/milk_entry_tile.dart';
import '../widgets/milk_summary_card.dart';
import 'add_customer_screen.dart';
import 'add_milk_entry_screen.dart';

class MilkKhataDashboardScreen extends StatefulWidget {
  const MilkKhataDashboardScreen({super.key});

  @override
  State<MilkKhataDashboardScreen> createState() =>
      _MilkKhataDashboardScreenState();
}

class _MilkKhataDashboardScreenState extends State<MilkKhataDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MilkProvider>();
      if (provider.status == 'initial') {
        provider.init();
      }
    });
  }

  Future<void> _navigateToAddCustomer() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    );

    if (result == true && mounted) {
      await context.read<MilkProvider>().init();
    }
  }

  Future<void> _navigateToAddMilkEntry() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddMilkEntryScreen()),
    );

    if (result == true && mounted) {
      await context.read<MilkProvider>().fetchEntriesForDate(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.milkKhata,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Consumer<MilkProvider>(
        builder: (context, milkProvider, child) {
          if (milkProvider.status == 'initial' || milkProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (milkProvider.status == 'error') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    milkProvider.errorMessage ?? l10n.somethingWentWrong,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => milkProvider.init(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final dayEntries = milkProvider.getEntriesForDate(_selectedDate);
          final summary = milkProvider.getSummaryForDate(_selectedDate);
          final customerCount = summary['customerCount'] as int? ?? 0;
          final totalCow = (summary['totalCow'] as num?)?.toDouble() ?? 0.0;
          final totalBuffalo =
              (summary['totalBuffalo'] as num?)?.toDouble() ?? 0.0;
          final totalAmount =
              (summary['totalAmount'] as num?)?.toDouble() ?? 0.0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.milkSoldTitle,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  l10n.milkSoldSubtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton.icon(
                              onPressed: _navigateToAddCustomer,
                              icon: const Icon(Icons.people, size: 16),
                              label: Text(l10n.addCustomer),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                foregroundColor: AppColors.textOnPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: AppColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.milkLedgerTitle,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  DateSelector(
                                    selectedDate: _selectedDate,
                                    onDateChanged: (date) async {
                                      setState(() => _selectedDate = date);
                                      await milkProvider.fetchEntriesForDate(
                                        date,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              MilkSummaryCard(
                                customerCount: customerCount,
                                cowMilkLiters: totalCow,
                                buffaloMilkLiters: totalBuffalo,
                                totalIncome: totalAmount,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _navigateToAddMilkEntry,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            l10n.addMilkEntry,
                            style: TextStyle(color: AppColors.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (dayEntries.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_drink_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 16),
                        Text(
                          l10n.noEntriesForDay,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => MilkEntryTile(entry: dayEntries[index]),
                    childCount: dayEntries.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
