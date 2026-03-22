import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileForm extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ProfileForm({
    super.key,
    required this.user,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _whatsappController;
  late TextEditingController _animalCountController;

  String? _selectedLanguage;
  String? _selectedWork;
  String? _selectedEducation;
  String? _selectedExperience;
  DateTime? _selectedBirthday;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _addressController = TextEditingController(
      text: widget.user.profileDetails?.address,
    );
    _whatsappController = TextEditingController(
      text: widget.user.profileDetails?.whatsAppNumber,
    );
    _animalCountController = TextEditingController(
      text: widget.user.profileDetails?.animalCount?.toString() ?? '',
    );

    // Initialize with backend values directly (no mapping needed)
    _selectedLanguage = widget.user.profileDetails?.language ?? 'Hindi'; // Default to Hindi
    _selectedWork = widget.user.profileDetails?.work;
    _selectedEducation = widget.user.profileDetails?.education;
    
    // Experience is stored as string in backend, use directly
    _selectedExperience = widget.user.profileDetails?.experienceYears;
    
    // Initialize birthday
    _selectedBirthday = widget.user.profileDetails?.birthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _animalCountController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF666B42),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _showImagePickerOptions() async {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF666B42)),
                title: Text(l10n.camera),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF666B42)),
                title: Text(l10n.gallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() => _isLoading = true);

        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.uploadProfilePic(image.path);

        if (mounted) {
          setState(() => _isLoading = false);

          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? l10n.profilePhotoUpdated : l10n.unableToUploadPhoto,
              ),
              backgroundColor: success ? const Color(0xFF666B42) : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.unableToUploadPhoto),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Prevent double submission
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    
    // Build profileDetails - only include non-null fields
    final profileDetails = <String, dynamic>{};
    
    if (_selectedLanguage != null) {
      profileDetails['language'] = _mapLanguageToBackend(_selectedLanguage!);
      debugPrint('🌐 Adding language to profileDetails: ${profileDetails['language']}');
    }
    // Only send address if it's not locked
    if (widget.user.profileDetails?.addressLocked != true && 
        _addressController.text.trim().isNotEmpty) {
      profileDetails['address'] = _addressController.text.trim();
      debugPrint('📍 Adding address to profileDetails: ${_addressController.text.trim()}');
    } else if (widget.user.profileDetails?.addressLocked == true) {
      debugPrint('🔒 Address is locked, not sending to backend');
    }
    if (_whatsappController.text.trim().isNotEmpty) {
      profileDetails['whatsAppNumber'] = _whatsappController.text.trim();
    }
    if (_selectedWork != null) {
      profileDetails['work'] = _mapWorkToBackend(_selectedWork!);
      debugPrint('💼 Adding work to profileDetails: ${profileDetails['work']}');
    }
    if (_selectedEducation != null) {
      profileDetails['education'] = _mapEducationToBackend(_selectedEducation!);
      debugPrint('🎓 Adding education to profileDetails: ${profileDetails['education']}');
    }
    if (_selectedExperience != null) {
      profileDetails['experienceYears'] = _mapExperienceToBackend(_selectedExperience!);
      debugPrint('📈 Adding experienceYears to profileDetails: ${profileDetails['experienceYears']}');
    }
    if (_selectedBirthday != null) {
      final birthdayString = _selectedBirthday!.toIso8601String();
      profileDetails['dob'] = birthdayString; // Backend uses 'dob', not 'birthday'
      debugPrint('📅 Adding dob to profileDetails: $birthdayString');
    } else {
      debugPrint('⚠️ Birthday is null, not adding to profileDetails');
    }
    if (_animalCountController.text.trim().isNotEmpty) {
      final count = int.tryParse(_animalCountController.text.trim());
      if (count != null) {
        profileDetails['animalCount'] = count;
        debugPrint('🐄 Adding animalCount to profileDetails: $count');
      } else {
        debugPrint('⚠️ Failed to parse animalCount: ${_animalCountController.text.trim()}');
      }
    } else {
      debugPrint('⚠️ Animal count is empty, not adding to profileDetails');
    }

    debugPrint('📦 Final profileDetails being sent: $profileDetails');

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      profileDetails: profileDetails,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success) {
      widget.onSave();
    } else {
      // Show error message to user
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 
              (l10n.isHindi 
                ? 'प्रोफाइल अपडेट करने में असमर्थ। कृपया दोबारा कोशिश करें।' 
                : 'Unable to update your profile. Please try again.'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Get localized dropdown options
    final languageOptions = l10n.languageOptions;
    final workOptions = l10n.workOptions;
    final educationOptions = l10n.educationOptions;
    final experienceOptions = l10n.experienceOptions;
    
    // Map stored values to current language options
    String? mappedLanguage = _selectedLanguage;
    String? mappedWork = _selectedWork;
    String? mappedEducation = _selectedEducation;
    
    // If stored value doesn't exist in current options, clear it
    if (mappedLanguage != null && !languageOptions.contains(mappedLanguage)) {
      mappedLanguage = null;
    }
    if (mappedWork != null && !workOptions.contains(mappedWork)) {
      mappedWork = null;
    }
    if (mappedEducation != null && !educationOptions.contains(mappedEducation)) {
      mappedEducation = null;
    }
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEECC47),
                          width: 2,
                        ),
                      ),
                      child: widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: widget.user.profilePic!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF838967),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Color(0xFF838967),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF838967),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF666B42),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Name
            _buildLabel(l10n.name),
            _buildTextField(
              controller: _nameController,
              hint: l10n.nameHint,
              validator: (v) => v?.isEmpty ?? true ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 18),

            // Language
            _buildLabel(l10n.language),
            _buildDropdown(
              value: mappedLanguage,
              hint: l10n.languageHint,
              items: languageOptions,
              onChanged: (v) => setState(() => _selectedLanguage = v),
            ),
            const SizedBox(height: 18),

            // Address (locked if addressLocked == true)
            _buildLabel(l10n.yourAddress),
            widget.user.profileDetails?.addressLocked == true
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF999999),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.user.profileDetails?.address ?? '',
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildTextField(
                    controller: _addressController,
                    hint: l10n.addressHint,
                    suffixText: l10n.tellAddress,
                  ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'ⓘ',
                  style: TextStyle(
                    color: Color(0xFF666B42),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.addressChangeOnce,
                  style: const TextStyle(
                    color: Color(0xFF666B42),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // WhatsApp & Phone
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l10n.whatsappNo),
                      _buildTextField(
                        controller: _whatsappController,
                        hint: l10n.enterNumber,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length != 10) {
                            return l10n.whatsappMustBe10Digits;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 21),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l10n.phoneNo),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          _maskPhone(widget.user.phoneNumber),
                          style: const TextStyle(
                            color: Color(0xFF585858),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Birthday
            _buildLabel(l10n.birthday),
            GestureDetector(
              onTap: _selectBirthday,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedBirthday != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedBirthday!)
                            : l10n.selectBirthday,
                        style: TextStyle(
                          color: _selectedBirthday != null
                              ? const Color(0xFF535735)
                              : const Color(0xFF828282),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF535735),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Work
            _buildLabel(l10n.work),
            _buildDropdown(
              value: mappedWork,
              hint: l10n.workHint,
              items: workOptions,
              onChanged: (v) => setState(() => _selectedWork = v),
            ),
            const SizedBox(height: 18),

            // Education
            _buildLabel(l10n.education),
            _buildDropdown(
              value: mappedEducation,
              hint: l10n.educationHint,
              items: educationOptions,
              onChanged: (v) => setState(() => _selectedEducation = v),
            ),
            const SizedBox(height: 18),

            // Animal Count
            _buildLabel(l10n.animalCount),
            _buildTextField(
              controller: _animalCountController,
              hint: l10n.animalCountHint,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),

            // Experience
            _buildLabel(l10n.experience),
            _buildDropdown(
              value: _selectedExperience,
              hint: l10n.experienceHint,
              items: experienceOptions,
              onChanged: (v) => setState(() => _selectedExperience = v),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF666B42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        l10n.save,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF141706),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? suffixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: enabled ? const Color(0xFF535735) : const Color(0xFF999999),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF828282),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          suffixText: suffixText,
          suffixStyle: const TextStyle(
            color: Color(0xFF666B42),
            fontSize: 12,
          ),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 55, // Fixed height to prevent cutoff
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF6F6F6F),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF535735),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF535735),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length < 10) return phone;
    return 'XXXX XXXX ${phone.substring(phone.length - 2)}';
  }

  // Mapping functions to convert display strings to backend enum values
  String _mapLanguageToBackend(String displayValue) {
    final l10n = AppLocalizations.of(context);
    debugPrint('🔄 Mapping language: "$displayValue" (isHindi: ${l10n.isHindi})');
    
    if (l10n.isHindi) {
      switch (displayValue) {
        case 'अंग्रेज़ी': 
          debugPrint('✅ Mapped अंग्रेज़ी → English');
          return 'English';
        case 'हिंदी': 
          debugPrint('✅ Mapped हिंदी → Hindi');
          return 'Hindi';
        default: 
          debugPrint('⚠️ No mapping found for "$displayValue", using as-is');
          return displayValue;
      }
    } else {
      // English display values are already backend values
      debugPrint('✅ English mode, using value as-is: "$displayValue"');
      return displayValue;
    }
  }

  String _mapWorkToBackend(String displayValue) {
    final l10n = AppLocalizations.of(context);
    debugPrint('🔄 Mapping work: "$displayValue" (isHindi: ${l10n.isHindi})');
    
    if (l10n.isHindi) {
      switch (displayValue) {
        case 'डेयरी का काम': 
          debugPrint('✅ Mapped डेयरी का काम → Dairy work');
          return 'Dairy work';
        case 'किसान': 
          debugPrint('✅ Mapped किसान → Farmer');
          return 'Farmer';
        case 'व्यापारी': 
          debugPrint('✅ Mapped व्यापारी → Businessman');
          return 'Businessman';
        case 'घर के लिए': 
          debugPrint('✅ Mapped घर के लिए → For home');
          return 'For home';
        case 'अन्य': 
          debugPrint('✅ Mapped अन्य → Other');
          return 'Other';
        default: 
          debugPrint('⚠️ No mapping found for "$displayValue", using as-is');
          return displayValue;
      }
    } else {
      // English display values are already backend values
      debugPrint('✅ English mode, using value as-is: "$displayValue"');
      return displayValue;
    }
  }

  String _mapEducationToBackend(String displayValue) {
    final l10n = AppLocalizations.of(context);
    debugPrint('🔄 Mapping education: "$displayValue" (isHindi: ${l10n.isHindi})');
    
    if (l10n.isHindi) {
      switch (displayValue) {
        case '5वीं': 
          debugPrint('✅ Mapped 5वीं → 5th');
          return '5th';
        case '6वीं': 
          debugPrint('✅ Mapped 6वीं → 6th');
          return '6th';
        case '7वीं': 
          debugPrint('✅ Mapped 7वीं → 7th');
          return '7th';
        case '8वीं': 
          debugPrint('✅ Mapped 8वीं → 8th');
          return '8th';
        case '9वीं': 
          debugPrint('✅ Mapped 9वीं → 9th');
          return '9th';
        case '10वीं': 
          debugPrint('✅ Mapped 10वीं → 10th');
          return '10th';
        case '11वीं': 
          debugPrint('✅ Mapped 11वीं → 11th');
          return '11th';
        case '12वीं': 
          debugPrint('✅ Mapped 12वीं → 12th');
          return '12th';
        case 'अन्य': 
          debugPrint('✅ Mapped अन्य → Other');
          return 'Other';
        default: 
          debugPrint('⚠️ No mapping found for "$displayValue", using as-is');
          return displayValue;
      }
    } else {
      // English display values are already backend values
      debugPrint('✅ English mode, using value as-is: "$displayValue"');
      return displayValue;
    }
  }

  String _mapExperienceToBackend(String displayValue) {
    final l10n = AppLocalizations.of(context);
    debugPrint('🔄 Mapping experience: "$displayValue" (isHindi: ${l10n.isHindi})');
    
    if (l10n.isHindi) {
      switch (displayValue) {
        case '0-5 साल': 
          debugPrint('✅ Mapped 0-5 साल → 0-5 Years');
          return '0-5 Years';
        case '5-10 साल': 
          debugPrint('✅ Mapped 5-10 साल → 5-10 Years');
          return '5-10 Years';
        case '10-15 साल': 
          debugPrint('✅ Mapped 10-15 साल → 10-15 Years');
          return '10-15 Years';
        case '15-20 साल': 
          debugPrint('✅ Mapped 15-20 साल → 15-20 Years');
          return '15-20 Years';
        case '20+ साल': 
          debugPrint('✅ Mapped 20+ साल → 20+ Years');
          return '20+ Years';
        default: 
          debugPrint('⚠️ No mapping found for "$displayValue", using as-is');
          return displayValue;
      }
    } else {
      // English display values are already backend values
      debugPrint('✅ English mode, using value as-is: "$displayValue"');
      return displayValue;
    }
  }
}
