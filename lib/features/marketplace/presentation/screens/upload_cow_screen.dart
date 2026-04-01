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
            // 1. ANIMAL TYPE SELECTION
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
                    onTap: () => setState(() => _selectedAnimalType = 'buffalo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. IMAGE PREVIEW SECTION (MOVED TO TOP)
            Text(
              l10n.isHindi ? 'तस्वीरें' : 'Photos',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (_selectedImagePaths.isNotEmpty)
              SizedBox(
                height: 140,
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
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_selectedImagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
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
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 40),
                    const SizedBox(height: 8),
                    Text(
                      l10n.isHindi ? 'कोई फोटो नहीं चुनी गई' : 'No photos selected',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // 3. ADD IMAGES BUTTON (MOVED TO TOP)
            OutlinedButton.icon(
              onPressed: _selectedImagePaths.length < 5 ? _pickImages : null,
              icon: const Icon(Icons.add_a_photo),
              label: Text(
                _selectedImagePaths.isEmpty
                    ? l10n.addImages
                    : l10n.addMoreImages(_selectedImagePaths.length),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // 4. LISTING DETAILS
            Text(
              l10n.isHindi ? 'जानकारी भरें' : 'Listing details',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // Breed
            TextFormField(
              controller: _breedController,
              decoration: InputDecoration(
                labelText: l10n.breed,
                hintText: _selectedAnimalType == 'buffalo'
                    ? (l10n.isHindi ? 'जैसे, मुर्रा, जाफराबादी' : 'e.g., Murrah, Jaffarabadi')
                    : l10n.breedHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.pleaseEnterBreed : null,
            ),
            const SizedBox(height: 16),

            // Age
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: l10n.ageYears,
                hintText: 'e.g., 4',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.pleaseEnterAge;
                if (int.tryParse(v) == null || int.parse(v) <= 0) return l10n.pleaseEnterValidAge;
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.pleaseEnterPrice;
                if (double.tryParse(v) == null || double.parse(v) <= 0) return l10n.pleaseEnterValidPrice;
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.pleaseEnterYield;
                if (double.tryParse(v) == null || double.parse(v) < 0) return l10n.pleaseEnterValidYield;
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.pleaseEnterDescription : null,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(_isUploadingImages ? l10n.uploadingImages : l10n.submitting),
                  ],
                )
                    : Text(l10n.submitForApproval, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFD7DCC6),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.primary : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}