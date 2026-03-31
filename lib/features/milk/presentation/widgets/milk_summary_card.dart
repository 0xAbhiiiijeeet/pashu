import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class MilkSummaryCard extends StatelessWidget {
  const MilkSummaryCard({
    super.key,
    required this.customerCount,
    required this.cowMilkLiters,
    required this.buffaloMilkLiters,
    required this.totalIncome,
  });

  final int customerCount;
  final double cowMilkLiters;
  final double buffaloMilkLiters;
  final double totalIncome;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _SummaryItem(
            value: customerCount.toString(),
            label: 'ग्राहक',
            valueColor: AppColors.primary,
          ),
          const VerticalDivider(
            thickness: 1,
            color: AppColors.divider,
            width: 24,
          ),
          _SummaryItem(
            value: cowMilkLiters.toStringAsFixed(1),
            label: 'गाय (लीटर)',
            valueColor: AppColors.primary,
          ),
          const VerticalDivider(
            thickness: 1,
            color: AppColors.divider,
            width: 24,
          ),
          _SummaryItem(
            value: buffaloMilkLiters.toStringAsFixed(1),
            label: 'भैंस (लीटर)',
            valueColor: AppColors.primary,
          ),
          const VerticalDivider(
            thickness: 1,
            color: AppColors.divider,
            width: 24,
          ),
          _SummaryItem(
            value: '₹${totalIncome.toStringAsFixed(0)}',
            label: 'आय',
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
