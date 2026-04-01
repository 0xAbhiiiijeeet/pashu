import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/customer_model.dart';
import '../providers/milk_provider.dart';
import '../widgets/common_widgets.dart';
import 'add_customer_screen.dart';

class AddMilkEntryScreen extends StatefulWidget {
  const AddMilkEntryScreen({super.key});

  @override
  State<AddMilkEntryScreen> createState() => _AddMilkEntryScreenState();
}

class _AddMilkEntryScreenState extends State<AddMilkEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  final _cowMilkController = TextEditingController();
  final _buffaloMilkController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedShift = 'Morning';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _cowMilkController.dispose();
    _buffaloMilkController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _totalLiters {
    final cow = double.tryParse(_cowMilkController.text) ?? 0;
    final buffalo = double.tryParse(_buffaloMilkController.text) ?? 0;
    return cow + buffalo;
  }

  double? get _totalAmount {
    final price = double.tryParse(_priceController.text);
    if (price == null || _totalLiters == 0) return null;
    return _totalLiters * price;
  }

  Future<void> _saveEntry() async {
    final isHindi = AppLocalizations.of(context).isHindi;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? 'कृपया ग्राहक चुनें' : 'Please select a customer',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_totalLiters == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi
                ? 'कम से कम एक दूध की मात्रा दर्ज करें'
                : 'Enter at least one milk quantity',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final milkProvider = context.read<MilkProvider>();
      final selectedCustomer = milkProvider.customers.firstWhere(
        (customer) => customer.id == _selectedCustomerId,
      );

      final success = await milkProvider.addMilkEntry(
        customerId: selectedCustomer.id,
        customerName: selectedCustomer.name,
        cowMilk: double.tryParse(_cowMilkController.text) ?? 0,
        buffaloMilk: double.tryParse(_buffaloMilkController.text) ?? 0,
        pricePerLiter: double.tryParse(_priceController.text) ?? 0,
        date: _selectedDate,
        shift: _selectedShift,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi
                  ? 'दूध एंट्री सफलतापूर्वक सेव हुई'
                  : 'Milk entry saved successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              milkProvider.errorMessage ??
                  (isHindi
                      ? 'एंट्री सेव करने में समस्या आई'
                      : 'Failed to save entry'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? 'त्रुटि: $e' : 'Error: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openAddCustomer() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    );

    if (added == true && mounted) {
      await context.read<MilkProvider>().fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLocalizations.of(context).isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isHindi ? 'दूध एंट्री जोड़ें' : 'Add Milk Entry',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Consumer<MilkProvider>(
        builder: (context, milkProvider, child) {
          final customers = milkProvider.customers;

          if (customers.isEmpty && milkProvider.status == 'loaded') {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isHindi
                          ? 'पहले ग्राहक जोड़ें'
                          : 'Add a customer first',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isHindi
                          ? 'दूध एंट्री करने से पहले कम से कम एक ग्राहक जोड़ना जरूरी है'
                          : 'Please add at least one customer before creating a milk entry',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _openAddCustomer,
                      icon: const Icon(Icons.person_add),
                      label: Text(
                        isHindi ? 'ग्राहक जोड़ें' : 'Add Customer',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: isHindi ? 'दूध ' : 'Milk ',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: isHindi ? 'एंट्री' : 'Entry',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isHindi
                              ? 'ग्राहक, शिफ्ट, तारीख और दूध की जानकारी दर्ज करें'
                              : 'Enter customer, shift, date and milk details',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _CustomerSelector(
                          customers: customers,
                          selectedCustomerId: _selectedCustomerId,
                          isHindi: isHindi,
                          onChanged: (value) {
                            setState(() => _selectedCustomerId = value);
                          },
                          onAddCustomer: _openAddCustomer,
                        ),
                        const SizedBox(height: 20),
                        _ShiftSelector(
                          value: _selectedShift,
                          isHindi: isHindi,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedShift = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isHindi ? 'तारीख' : 'Date',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DateSelector(
                          selectedDate: _selectedDate,
                          onDateChanged: (date) {
                            setState(() => _selectedDate = date);
                          },
                        ),
                        const SizedBox(height: 20),
                        MilkInputField(
                          label: isHindi ? 'गाय का दूध (लीटर)' : 'Cow Milk (Liters)',
                          hint: isHindi ? 'जैसे: 2.5' : 'e.g. 2.5',
                          controller: _cowMilkController,
                          isOptional: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed < 0) {
                                return isHindi
                                    ? 'सही मात्रा दर्ज करें'
                                    : 'Enter a valid quantity';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        QuickEntryButtons(controller: _cowMilkController),
                        const SizedBox(height: 20),
                        MilkInputField(
                          label: isHindi
                              ? 'भैंस का दूध (लीटर)'
                              : 'Buffalo Milk (Liters)',
                          hint: isHindi ? 'जैसे: 3.0' : 'e.g. 3.0',
                          controller: _buffaloMilkController,
                          isOptional: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed < 0) {
                                return isHindi
                                    ? 'सही मात्रा दर्ज करें'
                                    : 'Enter a valid quantity';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        QuickEntryButtons(controller: _buffaloMilkController),
                        const SizedBox(height: 20),
                        MilkInputField(
                          label: isHindi
                              ? 'प्रति लीटर मूल्य (₹)'
                              : 'Price Per Liter (₹)',
                          hint: isHindi ? 'जैसे: 60' : 'e.g. 60',
                          controller: _priceController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isHindi
                                  ? 'कृपया मूल्य दर्ज करें'
                                  : 'Please enter price';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null || parsed <= 0) {
                              return isHindi
                                  ? 'सही मूल्य दर्ज करें'
                                  : 'Enter a valid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _cowMilkController,
                          builder: (_, __, ___) {
                            return ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _buffaloMilkController,
                              builder: (_, __, ___) {
                                return ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _priceController,
                                  builder: (_, __, ___) {
                                    if (_totalLiters == 0) {
                                      return const SizedBox.shrink();
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.mintGreen,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.sage.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isHindi ? 'कुल दूध' : 'Total Milk',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                isHindi
                                                    ? '${_totalLiters.toStringAsFixed(2)} लीटर'
                                                    : '${_totalLiters.toStringAsFixed(2)} liters',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_totalAmount != null)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  isHindi ? 'कुल राशि' : 'Total Amount',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                Text(
                                                  '₹${_totalAmount!.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveEntry,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textOnPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.save_alt_outlined),
                      label: Text(
                        _isLoading
                            ? (isHindi ? 'सेव हो रहा है...' : 'Saving...')
                            : (isHindi ? 'एंट्री सेव करें' : 'Save Entry'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomerSelector extends StatelessWidget {
  const _CustomerSelector({
    required this.customers,
    required this.selectedCustomerId,
    required this.isHindi,
    required this.onChanged,
    required this.onAddCustomer,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final bool isHindi;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddCustomer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isHindi ? 'ग्राहक चुनें' : 'Select Customer',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAddCustomer,
              icon: const Icon(Icons.person_add, size: 18),
              label: Text(isHindi ? 'नया जोड़ें' : 'Add New'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedCustomerId,
          hint: Text(isHindi ? 'ग्राहक चुनें' : 'Select customer'),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          items: customers
              .map(
                (customer) => DropdownMenuItem<String>(
                  value: customer.id,
                  child: Text(customer.name),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (value) => value == null
              ? (isHindi
                  ? 'कृपया ग्राहक चुनें'
                  : 'Please select a customer')
              : null,
        ),
      ],
    );
  }
}

class _ShiftSelector extends StatelessWidget {
  const _ShiftSelector({
    required this.value,
    required this.isHindi,
    required this.onChanged,
  });

  final String value;
  final bool isHindi;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi ? 'शिफ्ट' : 'Shift',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 'Morning',
              child: Text(isHindi ? 'सुबह' : 'Morning'),
            ),
            DropdownMenuItem(
              value: 'Evening',
              child: Text(isHindi ? 'शाम' : 'Evening'),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
