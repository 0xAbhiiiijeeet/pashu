import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class SellCattleScreen extends StatefulWidget {
  const SellCattleScreen({super.key});

  @override
  State<SellCattleScreen> createState() => _SellCattleScreenState();
}

class _SellCattleScreenState extends State<SellCattleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAnimalType;
  String? _selectedBreed;
  String? _selectedLocation;
  final _priceController = TextEditingController();
  final _milkController = TextEditingController();
  bool _hasPhoto = false;

  final List<String> _animalTypes = ['गाय', 'भैंस'];
  final List<String> _breeds = [
    'HF क्रॉस',
    'मुर्रा',
    'गिर',
    'जर्सी',
    'नीली रावी',
    'साहीवाल',
    'अन्य',
  ];
  final List<String> _locations = [
    'Pune',
    'Nashik',
    'Nagpur',
    'Kolhapur',
    'Aurangabad',
    'Mumbai',
    'अन्य',
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _milkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पशु की जानकारी सफलतापूर्वक दर्ज की गई!'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'पशु बेचें',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'फ्री पशु ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: 'दर्ज करें',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1459+ ख़रीददार आपका पशु देख रहे हैं',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Photo upload
                  GestureDetector(
                    onTap: () => setState(() => _hasPhoto = !_hasPhoto),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasPhoto ? AppColors.primary : Colors.grey.shade300,
                          width: _hasPhoto ? 2 : 1,
                        ),
                      ),
                      child: _hasPhoto
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Container(
                                    color: AppColors.mintGreen,
                                    child: const Center(
                                      child: Icon(
                                        Icons.pets,
                                        size: 60,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _hasPhoto = false),
                                    child: const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.black54,
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'पशु की फ़ोटो जोड़ें',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'टैप करके फ़ोटो चुनें',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Animal type
                  const _SectionLabel(label: 'पशु का प्रकार'),
                  const SizedBox(height: 8),
                  Row(
                    children: _animalTypes.map((type) {
                      final selected = _selectedAnimalType == type;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedAnimalType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedAnimalType == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'पशु का प्रकार चुनें',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Breed
                  const _SectionLabel(label: 'नस्ल'),
                  const SizedBox(height: 8),
                  _FormDropdown(
                    hint: 'नस्ल चुनें',
                    value: _selectedBreed,
                    items: _breeds,
                    onChanged: (value) => setState(() => _selectedBreed = value),
                    validator: (value) => value == null ? 'नस्ल चुनें' : null,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  const _SectionLabel(label: 'क़ीमत (₹)'),
                  const SizedBox(height: 8),
                  _FormTextField(
                    controller: _priceController,
                    hint: 'जैसे: 90000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefix: const Text(
                      '₹ ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'क़ीमत दर्ज करें';
                      if (int.tryParse(value) == null) return 'सही क़ीमत दर्ज करें';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Milk capacity
                  const _SectionLabel(label: 'दूध क्षमता (लीटर/दिन)'),
                  const SizedBox(height: 8),
                  _FormTextField(
                    controller: _milkController,
                    hint: 'जैसे: 10',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))
                    ],
                    suffix: const Text(
                      'लीटर/दिन',
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'दूध क्षमता दर्ज करें';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Location
                  const _SectionLabel(label: 'स्थान'),
                  const SizedBox(height: 8),
                  _FormDropdown(
                    hint: 'स्थान चुनें',
                    value: _selectedLocation,
                    items: _locations,
                    onChanged: (value) => setState(() => _selectedLocation = value),
                    validator: (value) => value == null ? 'स्थान चुनें' : null,
                  ),
                  const SizedBox(height: 24),

                  // Free listing badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.verified_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'यह लिस्टिंग बिल्कुल फ्री है!',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Submit button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'पशु दर्ज करें',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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

// ─── Local helper widgets ─────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _FormDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hint,
        style: const TextStyle(color: Colors.black38, fontSize: 14),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _FormTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        prefix: prefix,
        suffix: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}