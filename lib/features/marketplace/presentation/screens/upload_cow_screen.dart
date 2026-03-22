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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);

    setState(() => _isSubmitting = true);

    final provider = context.read<MarketplaceProvider>();
    List<String> imageUrls = [];

    // Only upload if images are selected
    if (_selectedImagePaths.isNotEmpty) {
      setState(() => _isUploadingImages = true);
      final uploadedUrls = await provider.uploadImages(_selectedImagePaths);
      setState(() => _isUploadingImages = false);

      if (uploadedUrls == null || uploadedUrls.isEmpty) {
        setState(() => _isSubmitting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? l10n.failedToUploadImages),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      imageUrls = uploadedUrls;
    }

    // Create cow sale
    final cowDetails = CowDetails(
      breed: _breedController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      price: double.parse(_priceController.text.trim()),
      milkYield: double.parse(_yieldController.text.trim()),
      images: imageUrls,
      description: _descriptionController.text.trim(),
    );

    final success = await provider.createCowSale(cowDetails);

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
        title: Text(l10n.sellYourCow),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Breed
            TextFormField(
              controller: _breedController,
              decoration: InputDecoration(
                labelText: l10n.breed,
                hintText: l10n.breedHint,
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

            // Images Section
            Text(
              l10n.cowImages,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Image Grid
            if (_selectedImagePaths.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImagePaths.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 8),
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
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
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
              ),
            const SizedBox(height: 8),

            // Add Images Button
            OutlinedButton.icon(
              onPressed: _selectedImagePaths.length < 5 ? _pickImages : null,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                _selectedImagePaths.isEmpty
                    ? l10n.addImages
                    : l10n.addMoreImages(_selectedImagePaths.length),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

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
