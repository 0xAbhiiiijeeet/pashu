import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/marketplace_provider.dart';
import '../../domain/models/cow_sale_model.dart';

class UploadCowScreen extends StatefulWidget {
  const UploadCowScreen({super.key});

  @override
  State<UploadCowScreen> createState() => _UploadCowScreenState();
}

class _UploadCowScreenState extends State<UploadCowScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAnimalType = 'cow';
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _priceController = TextEditingController();
  final _yieldController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _selectedImagePaths = [];
  bool _isSubmitting = false;
  bool _isUploadingImages = false;

  @override
  void dispose() {
    _breedController.dispose();
    _ageController.dispose();
    _priceController.dispose();
    _yieldController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImagePaths.addAll(images.map((img) => img.path));
          // Limit to 5 images
          if (_selectedImagePaths.length > 5) {
            _selectedImagePaths.removeRange(5, _selectedImagePaths.length);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToPickImages}: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
  }

  String get _animalLabel => _selectedAnimalType == 'buffalo' ? 'Buffalo' : 'Cow';
  String get _animalLabelHindi => _selectedAnimalType == 'buffalo' ? 'भैंस' : 'गाय';

  void _previewImage(String imagePath) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    if (_selectedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAddAtLeastOneImage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<MarketplaceProvider>();

    final cowDetails = CowDetails(
      animalType: _selectedAnimalType,
      breed: _breedController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      price: double.parse(_priceController.text.trim()),
      milkYield: double.parse(_yieldController.text.trim()),
      images: _selectedImagePaths,
      description: _descriptionController.text.trim(),
    );

    setState(() => _isUploadingImages = true);
    final success = await provider.createCowSale(
      cowDetails,
      imagePaths: _selectedImagePaths,
    );
    setState(() => _isUploadingImages = false);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cowListingSubmitted),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? l10n.failedToSubmitListing),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedAnimalType == 'buffalo'
            ? (l10n.isHindi ? 'अपनी भैंस बेचें' : 'Sell Your Buffalo')
            : l10n.sellYourCow),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _UploadHeroCard(
              title: l10n.isHindi ? 'फोटो पहले जोड़ें' : 'Add photos first',
              subtitle: l10n.isHindi
                  ? 'साफ तस्वीरें डालें ताकि खरीदार तुरंत समझ सके कि आप ${_animalLabelHindi.toLowerCase()} बेच रहे हैं।'
                  : 'Add clear photos first so buyers can instantly understand what you are selling.',
            ),
            const SizedBox(height: 16),

            Text(
              l10n.isHindi ? 'क्या बेच रहे हैं?' : 'What are you selling?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _AnimalTypeCard(
                    label: l10n.isHindi ? 'गाय' : 'Cow',
                    icon: Icons.pets,
                    selected: _selectedAnimalType == 'cow',
                    onTap: () => setState(() => _selectedAnimalType = 'cow'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnimalTypeCard(
                    label: l10n.isHindi ? 'भैंस' : 'Buffalo',
                    icon: Icons.agriculture,
                    selected: _selectedAnimalType == 'buffalo',
                    onTap: () =>
                        setState(() => _selectedAnimalType = 'buffalo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Text(
              l10n.isHindi ? 'तस्वीरें' : 'Photos',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.isHindi
                  ? 'कम से कम 1 और अधिकतम 5 फोटो डालें। किसी फोटो पर टैप करके प्रीव्यू देखें।'
                  : 'Add at least 1 and up to 5 photos. Tap any photo to preview it.',
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 12),

            if (_selectedImagePaths.isNotEmpty)
              SizedBox(
                height: 156,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImagePaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _previewImage(_selectedImagePaths[index]),
                          child: Container(
                            width: 132,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(_selectedImagePaths[index]),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    left: 8,
                                    right: 8,
                                    bottom: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        l10n.isHindi ? 'प्रीव्यू' : 'Preview',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              Container(
                height: 156,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD9DFC7)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo_outlined,
                      size: 42,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.isHindi
                          ? '${_animalLabelHindi} की पहली फोटो जोड़ें'
                          : 'Add the first photo of your $_animalLabel',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.isHindi
                          ? 'अच्छी फोटो से आपकी लिस्ट जल्दी बिकती है।'
                          : 'Good photos help your listing get noticed faster.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _selectedImagePaths.length < 5 ? _pickImages : null,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _selectedImagePaths.isEmpty
                    ? l10n.addImages
                    : l10n.addMoreImages(_selectedImagePaths.length),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              l10n.isHindi ? 'जानकारी भरें' : 'Listing details',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _breedController,
              decoration: InputDecoration(
                labelText: l10n.breed,
                hintText: _selectedAnimalType == 'buffalo'
                    ? (l10n.isHindi
                        ? 'जैसे, मुर्रा, जाफराबादी'
                        : 'e.g., Murrah, Jaffarabadi')
                    : l10n.breedHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterBreed;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Age
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: l10n.ageYears,
                hintText: 'e.g., 4',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterAge;
                }
                final age = int.tryParse(value);
                if (age == null || age <= 0) {
                  return l10n.pleaseEnterValidAge;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: l10n.priceRupees,
                hintText: 'e.g., 45000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterPrice;
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return l10n.pleaseEnterValidPrice;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Milk Yield
            TextFormField(
              controller: _yieldController,
              decoration: InputDecoration(
                labelText: l10n.milkYieldLiters,
                hintText: 'e.g., 12',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterYield;
                }
                final yield_ = double.tryParse(value);
                if (yield_ == null || yield_ < 0) {
                  return l10n.pleaseEnterValidYield;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.describeCow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterDescription;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isUploadingImages
                                ? l10n.uploadingImages
                                : l10n.submitting,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : Text(
                        l10n.submitForApproval,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadHeroCard extends StatelessWidget {
  const _UploadHeroCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF707B3C), Color(0xFF8D9850)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.photo_library_outlined, color: Colors.white, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _AnimalTypeCard extends StatelessWidget {
  const _AnimalTypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F3E1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFD7DCC6),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.primary : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
