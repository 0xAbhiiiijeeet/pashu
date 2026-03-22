import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/milk_calculator_provider.dart';

class CalculationHistoryList extends StatelessWidget {
  const CalculationHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculationHistory),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MilkCalculatorProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCalculationsYet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.startCalculating,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                final calc = provider.history[index];
                final dateStr = DateFormat('dd MMM yyyy').format(calc.calculationDate);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, calc.id),
                            ),
                          ],
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.pets,
                          label: l10n.animals,
                          value: '${calc.animalCount}',
                        ),
                        _InfoRow(
                          icon: Icons.water_drop,
                          label: l10n.avgMilkAnimal,
                          value: '${calc.averageMilkPerAnimal.toStringAsFixed(1)} L',
                        ),
                        _InfoRow(
                          icon: Icons.production_quantity_limits,
                          label: l10n.totalProduced,
                          value: '${calc.totalMilkProduced.toStringAsFixed(1)} L',
                        ),
                        _InfoRow(
                          icon: Icons.home,
                          label: l10n.homeUse,
                          value: '${calc.homeConsumption.toStringAsFixed(1)} L',
                        ),
                        _InfoRow(
                          icon: Icons.sell,
                          label: l10n.milkSold,
                          value: '${calc.totalMilkSold.toStringAsFixed(1)} L',
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.currency_rupee,
                          label: l10n.dailyIncome,
                          value: '₹${calc.totalDailyIncome.toStringAsFixed(0)}',
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCalculation),
        content: Text(l10n.areYouSureDeleteCalculation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<MilkCalculatorProvider>();
      final success = await provider.deleteCalculation(id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.calculationDeleted : l10n.failedToDelete,
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isHighlight ? AppColors.primary : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isHighlight ? 15 : 14,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
                color: isHighlight ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
