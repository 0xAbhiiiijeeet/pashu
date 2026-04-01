import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/milk_provider.dart';
import '../widgets/common_widgets.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _milkTypePreference = 'Both';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final milkProvider = context.read<MilkProvider>();
      final success = await milkProvider.addCustomer(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        milkTypePreference: _milkTypePreference,
      );

      if (!mounted) return;

      final isHindi = AppLocalizations.of(context).isHindi;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi
                  ? 'ग्राहक सफलतापूर्वक जोड़ा गया'
                  : 'Customer added successfully',
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
                      ? 'ग्राहक जोड़ने में समस्या आई'
                      : 'Failed to add customer'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      final isHindi = AppLocalizations.of(context).isHindi;
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

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLocalizations.of(context).isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isHindi ? 'ग्राहक जोड़ें' : 'Add Customer',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Form(
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
                            text: isHindi ? 'नया ग्राहक ' : 'New ',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: isHindi ? 'जोड़ें' : 'Customer',
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
                          ? 'ग्राहक का नाम, फोन नंबर, पता और दूध की पसंद दर्ज करें'
                          : 'Enter customer name, phone number, address and milk preference',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    MilkInputField(
                      label: isHindi ? 'ग्राहक का नाम' : 'Customer Name',
                      hint: isHindi ? 'जैसे: राजेश कुमार' : 'e.g. Rajesh Kumar',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\u0900-\u097F\s]'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isHindi
                              ? 'कृपया ग्राहक का नाम दर्ज करें'
                              : 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MilkInputField(
                      label: isHindi ? 'फोन नंबर' : 'Phone Number',
                      hint: isHindi ? 'जैसे: 9876543212' : 'e.g. 9876543212',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isHindi
                              ? 'कृपया फोन नंबर दर्ज करें'
                              : 'Please enter phone number';
                        }
                        if (value.length != 10) {
                          return isHindi
                              ? 'कृपया 10 अंकों का मोबाइल नंबर दर्ज करें'
                              : 'Please enter a 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MilkInputField(
                      label: isHindi ? 'पता' : 'Address',
                      hint: isHindi ? 'जैसे: Village A' : 'e.g. Village A',
                      controller: _addressController,
                      keyboardType: TextInputType.streetAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isHindi
                              ? 'कृपया पता दर्ज करें'
                              : 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isHindi ? 'दूध की पसंद' : 'Milk Preference',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _milkTypePreference,
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
                          value: 'Cow',
                          child: Text(isHindi ? 'गाय' : 'Cow'),
                        ),
                        DropdownMenuItem(
                          value: 'Buffalo',
                          child: Text(isHindi ? 'भैंस' : 'Buffalo'),
                        ),
                        DropdownMenuItem(
                          value: 'Both',
                          child: Text(isHindi ? 'दोनों' : 'Both'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _milkTypePreference = value);
                        }
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
                  onPressed: _isLoading ? null : _submit,
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
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isLoading
                        ? (isHindi ? 'सेव हो रहा है...' : 'Saving...')
                        : (isHindi ? 'सेव करें' : 'Save'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
      ),
    );
  }
}
