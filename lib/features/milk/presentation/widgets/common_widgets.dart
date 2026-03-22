import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

// ─── DateSelector ────────────────────────────────────────────────────────────
class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) widget.onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(formatted, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── CustomerDropdown ────────────────────────────────────────────────────────
class CustomerDropdown extends StatelessWidget {
  final List<String> customers;
  final String? selectedCustomer;
  final ValueChanged<String?> onChanged;

  const CustomerDropdown({
    super.key,
    required this.customers,
    required this.selectedCustomer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCustomer,
      hint: const Text('ग्राहक चुनें'),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: customers
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'कृपया ग्राहक चुनें' : null,
    );
  }
}

// ─── MilkInputField ──────────────────────────────────────────────────────────
class MilkInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isOptional;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLength;

  const MilkInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isOptional = false,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.inputFormatters,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 6),
              const Text(
                '(वैकल्पिक)',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surface,
            counterText: maxLength != null ? null : '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// ─── QuickEntryButtons ───────────────────────────────────────────────────────
class QuickEntryButtons extends StatelessWidget {
  final TextEditingController controller;
  final List<double> values;

  const QuickEntryButtons({
    super.key,
    required this.controller,
    this.values = const [0.25, 0.5, 1.0],
  });

  void _addValue(double value) {
    final current = double.tryParse(controller.text) ?? 0;
    final newValue = current + value;
    controller.text = newValue.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OutlinedButton(
            onPressed: () => _addValue(value),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: Text(
              '+${value}L',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }
}