import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEdit,
  });

  Future<void> _showImagePickerOptions(BuildContext context) async {
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
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF666B42)),
                title: Text(l10n.gallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              if (user.profilePic != null && user.profilePic!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    l10n.removePhoto,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement remove photo
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF666B42)),
          ),
        );

        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.uploadProfilePic(image.path);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

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
      if (context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final completion = authProvider.profileCompletion;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Picture
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImagePickerOptions(context),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEECC47),
                          width: 1.5,
                        ),
                      ),
                      child: user.profilePic != null && user.profilePic!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.profilePic!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF838967),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Color(0xFF838967),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 32,
                              color: Color(0xFF838967),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _showImagePickerOptions(context),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF666B42),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.name ?? 'User'} ji',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          l10n.india,
                          style: const TextStyle(
                            color: Color(0xFF828282),
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: const Color(0xFF8B8B8B),
                        ),
                        Text(
                          _maskPhoneNumber(user.phoneNumber),
                          style: const TextStyle(
                            color: Color(0xFF828282),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Edit Button
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E4DA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF666B42),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.edit,
                        style: const TextStyle(
                          color: Color(0xFF666B42),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Profile Completion Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: completion < 100
                    ? const Color(0xFFFDE7D0)
                    : const Color(0xFFD7E4DA),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$completion%',
                    style: TextStyle(
                      color: completion < 100
                          ? const Color(0xFFE16000)
                          : const Color(0xFF666B42),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    completion < 100 ? l10n.incomplete : l10n.complete,
                    style: TextStyle(
                      color: completion < 100
                          ? const Color(0xFFE16000)
                          : const Color(0xFF666B42),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 10) return phone;
    return 'XXXX XXXX ${phone.substring(phone.length - 2)}';
  }
}
