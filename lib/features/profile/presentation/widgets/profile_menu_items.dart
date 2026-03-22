import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../debug/presentation/screens/remote_config_debug_screen.dart';

class ProfileMenuItems extends StatelessWidget {
  final VoidCallback? onCheckUpdates;
  
  const ProfileMenuItems({
    super.key,
    this.onCheckUpdates,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.people_outline,
            title: l10n.tellFriends,
            onTap: () => _shareAppLink(context),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            title: l10n.talkToUs,
            onTap: () => _openWhatsApp(context),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.system_update,
            title: l10n.isHindi ? 'अपडेट चेक करें' : 'Check for Updates',
            onTap: onCheckUpdates ?? () {},
          ),
          // Debug menu (only in debug mode)
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.settings_remote,
              title: 'Remote Config Debug',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RemoteConfigDebugScreen(),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.logout,
            title: l10n.logout,
            onTap: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              
              // Pop all screens and let _AuthGate show LoginScreen
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareAppLink(BuildContext context) async {
    // Get app URL from Remote Config
    final appLink = ApiEndpoints.appUrl;
    
    try {
      await Clipboard.setData(ClipboardData(text: appLink));
      
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.linkCopied),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF666B42),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error copying link: $e');
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToCopyLink),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    const phoneNumber = '918930364530'; // +91 89303 64530
    
    final localeProvider = context.read<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    
    final messageText = isHindi 
      ? 'नमस्ते, मुझे पशु मित्र के साथ मदद चाहिए'
      : 'Hello, I need help from Pashu Mitra';
    
    final message = Uri.encodeComponent(messageText);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$message';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.couldNotOpenWhatsApp),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening WhatsApp: $e');
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOpeningWhatsApp),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
