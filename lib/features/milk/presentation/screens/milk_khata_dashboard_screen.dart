import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/milk_summary_card.dart';
import '../widgets/milk_entry_tile.dart';
import '../widgets/common_widgets.dart';
import '../providers/milk_provider.dart';
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

  void _navigateToAddCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    );
    
    // Refresh data if customer was added
    if (result == true && mounted) {
      context.read<MilkProvider>().init();
    }
  }

  void _navigateToAddMilkEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMilkEntryScreen(),
      ),
    );
    
    // Refresh data if entry was added
    if (result == true && mounted) {
      context.read<MilkProvider>().init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'दूध खाता',
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
          // Handle loading and error states first
          if (milkProvider.status == 'initial') {
            // Trigger initialization if not already started
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (milkProvider.status == 'initial') {
                milkProvider.init();
              }
            });
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (milkProvider.isLoading) {
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
                    milkProvider.errorMessage ?? 'कुछ गलत हुआ है',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => milkProvider.init(),
                    child: const Text('पुनः प्रयास करें'),
                  ),
                ],
              ),
            );
          }

          final todayEntries = milkProvider.getEntriesForDate(_selectedDate);
          final summary = milkProvider.getSummaryForDate(_selectedDate);

          // Ensure summary has valid values
          final customerCount = summary['customerCount'] as int? ?? 0;
          final totalCow = (summary['totalCow'] as num?)?.toDouble() ?? 0.0;
          final totalBuffalo = (summary['totalBuffalo'] as num?)?.toDouble() ?? 0.0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'कितना ',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'दूध बेचा',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'आज ग्राहकों को बेचा गया दूध दर्ज करें',
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
                            width: 120, // Fixed width to prevent infinite constraints
                            child: ElevatedButton.icon(
                              onPressed: _navigateToAddCustomer,
                              icon: const Icon(Icons.people, size: 16),
                              label: const Text('ग्राहक जोड़ें'),
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
                      
                      // Summary card with date selector
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'दूध का हिसाब',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  DateSelector(
                                    selectedDate: _selectedDate,
                                    onDateChanged: (d) {
                                      setState(() => _selectedDate = d);
                                      milkProvider.fetchEntriesForDate(d);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              MilkSummaryCard(
                                customerCount: customerCount,
                                cowMilkLiters: totalCow,
                                buffaloMilkLiters: totalBuffalo,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Add Milk Entry button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _navigateToAddMilkEntry,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'दूध एंट्री जोड़ें',
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
              
              // Entries list or empty state
              if (todayEntries.isEmpty)
                const SliverFillRemaining(
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
                          'इस दिन के लिए कोई ग्राहक प्रविष्टि नहीं मिली',
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
                    (context, index) => MilkEntryTile(
                      entry: todayEntries[index],
                      onTap: () {
                        // TODO: Navigate to entry details or edit screen
                      },
                    ),
                    childCount: todayEntries.length,
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