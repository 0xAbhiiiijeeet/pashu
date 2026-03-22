import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../providers/milk_provider.dart';
import 'add_customer_screen.dart';

class AddMilkEntryScreen extends StatefulWidget {
  const AddMilkEntryScreen({super.key});

  @override
  State<AddMilkEntryScreen> createState() => _AddMilkEntryScreenState();
}

class _AddMilkEntryScreenState extends State<AddMilkEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomer;
  final _cowMilkController = TextEditingController();
  final _buffaloMilkController = TextEditingController();
  final _priceController = TextEditingController();
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
    if (_formKey.currentState?.validate() ?? false) {
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
        final success = await milkProvider.addMilkEntry(
          customerName: _selectedCustomer!,
          cowMilk: double.tryParse(_cowMilkController.text) ?? 0,
          buffaloMilk: double.tryParse(_buffaloMilkController.text) ?? 0,
          pricePerLiter: double.tryParse(_priceController.text),
        );
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('दूध एंट्री सफलतापूर्वक दर्ज की गई!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(milkProvider.errorMessage ?? 'एंट्री दर्ज करने में त्रुटि हुई'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('त्रुटि: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
          final customerNames = milkProvider.customers.map((c) => c.name).toList();
          
          // If no customers available, show message
          if (customerNames.isEmpty && milkProvider.status == 'loaded') {
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
              body: Center(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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
                        // Section header
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
                          'ग्राहक और दूध की जानकारी दर्ज करें',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // Customer dropdown
                        const Text(
                          'ग्राहक चुनें',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomerDropdown(
                          customers: customerNames,
                          selectedCustomer: _selectedCustomer,
                          onChanged: (v) => setState(() => _selectedCustomer = v),
                        ),
                        const SizedBox(height: 20),
                        
                        // Cow milk
                        MilkInputField(
                          label: 'गाय का दूध (लीटर)',
                          hint: 'जैसे: 2.5',
                          controller: _cowMilkController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final d = double.tryParse(v);
                              if (d == null || d < 0) return 'सही मात्रा दर्ज करें';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        QuickEntryButtons(controller: _cowMilkController),
                        const SizedBox(height: 20),
                        
                        // Buffalo milk
                        MilkInputField(
                          label: 'भैंस का दूध (लीटर)',
                          hint: 'जैसे: 3.0',
                          controller: _buffaloMilkController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final d = double.tryParse(v);
                              if (d == null || d < 0) return 'सही मात्रा दर्ज करें';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        QuickEntryButtons(controller: _buffaloMilkController),
                        const SizedBox(height: 20),
                        
                        // Price per liter (optional)
                        MilkInputField(
                          label: 'प्रति लीटर मूल्य (₹)',
                          hint: 'जैसे: 50',
                          controller: _priceController,
                          isOptional: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final d = double.tryParse(v);
                              if (d == null || d <= 0) return 'सही मूल्य दर्ज करें';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Live preview card
                        ValueListenableBuilder(
                          valueListenable: _cowMilkController,
                          builder: (_, __, ___) => ValueListenableBuilder(
                            valueListenable: _buffaloMilkController,
                            builder: (_, __, ___) => ValueListenableBuilder(
                              valueListenable: _priceController,
                              builder: (_, __, ___) {
                                if (_totalLiters == 0) return const SizedBox.shrink();
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                          crossAxisAlignment: CrossAxisAlignment.end,
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
                
                // Save button
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