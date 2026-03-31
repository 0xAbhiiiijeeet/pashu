import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_totalLiters == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कम से कम एक दूध की मात्रा दर्ज करें'),
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
          const SnackBar(
            content: Text('दूध एंट्री सफलतापूर्वक दर्ज की गई!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(milkProvider.errorMessage ?? 'एंट्री दर्ज करने में त्रुटि हुई'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('त्रुटि: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'दूध एंट्री जोड़ें',
          style: TextStyle(fontWeight: FontWeight.w600),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'पहले ग्राहक जोड़ें',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'दूध एंट्री करने के लिए पहले कम से कम एक ग्राहक जोड़ना जरूरी है',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCustomerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('ग्राहक जोड़ें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                  ),
                ],
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
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'दूध ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: 'एंट्री',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'ग्राहक, शिफ्ट, तारीख और दूध की जानकारी दर्ज करें',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _CustomerSelector(
                          customers: customers,
                          selectedCustomerId: _selectedCustomerId,
                          onChanged: (value) {
                            setState(() => _selectedCustomerId = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        _ShiftSelector(
                          value: _selectedShift,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedShift = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'तारीख',
                          style: TextStyle(
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
                          label: 'गाय का दूध (लीटर)',
                          hint: 'जैसे: 2.5',
                          controller: _cowMilkController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed < 0) {
                                return 'सही मात्रा दर्ज करें';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        QuickEntryButtons(controller: _cowMilkController),
                        const SizedBox(height: 20),
                        MilkInputField(
                          label: 'भैंस का दूध (लीटर)',
                          hint: 'जैसे: 3.0',
                          controller: _buffaloMilkController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed < 0) {
                                return 'सही मात्रा दर्ज करें';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        QuickEntryButtons(controller: _buffaloMilkController),
                        const SizedBox(height: 20),
                        MilkInputField(
                          label: 'प्रति लीटर मूल्य (₹)',
                          hint: 'जैसे: 60',
                          controller: _priceController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'कृपया मूल्य दर्ज करें';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null || parsed <= 0) {
                              return 'सही मूल्य दर्ज करें';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder(
                          valueListenable: _cowMilkController,
                          builder: (_, __, ___) => ValueListenableBuilder(
                            valueListenable: _buffaloMilkController,
                            builder: (_, __, ___) => ValueListenableBuilder(
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
                                      color: AppColors.sage.withValues(alpha: 0.3),
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
                                          const Text(
                                            'कुल दूध',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            '${_totalLiters.toStringAsFixed(2)} लीटर',
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
                                            const Text(
                                              'कुल राशि',
                                              style: TextStyle(
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
                            ),
                          ),
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
                        _isLoading ? 'दर्ज हो रहा है...' : 'एंट्री दर्ज करें',
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
    required this.onChanged,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ग्राहक चुनें',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCustomerId,
          hint: const Text('ग्राहक चुनें'),
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
          validator: (value) => value == null ? 'कृपया ग्राहक चुनें' : null,
        ),
      ],
    );
  }
}

class _ShiftSelector extends StatelessWidget {
  const _ShiftSelector({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'शिफ्ट',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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
          items: const [
            DropdownMenuItem(value: 'Morning', child: Text('Morning')),
            DropdownMenuItem(value: 'Evening', child: Text('Evening')),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
