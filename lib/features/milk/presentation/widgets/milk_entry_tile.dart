import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/milk_entry_model.dart';

class MilkEntryTile extends StatelessWidget {
  final MilkEntry entry;
  final VoidCallback? onTap;

  const MilkEntryTile({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.mintGreen,
                child: Text(
                  entry.customerName.isNotEmpty 
                      ? entry.customerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (entry.cowMilk > 0)
                          _MilkChip(
                            label: 'गाय: ${entry.cowMilk}L',
                            color: AppColors.cream.withValues(alpha: 0.3),
                            textColor: AppColors.golden,
                          ),
                        if (entry.cowMilk > 0 && entry.buffaloMilk > 0)
                          const SizedBox(width: 6),
                        if (entry.buffaloMilk > 0)
                          _MilkChip(
                            label: 'भैंस: ${entry.buffaloMilk}L',
                            color: AppColors.mintGreen,
                            textColor: AppColors.sage,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (entry.totalAmount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${entry.totalAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${entry.totalLiters.toStringAsFixed(1)}L',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '${entry.totalLiters.toStringAsFixed(1)}L',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilkChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _MilkChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}