import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/locale_provider.dart';

class WhatsAppFAB extends StatelessWidget {
  final String? customMessage;
  
  const WhatsAppFAB({
    super.key,
    this.customMessage,
  });

  static const String _phoneNumber = '918930364530'; // +91 89303 64530
  
  Future<void> _openWhatsApp(BuildContext context) async {
    final localeProvider = context.read<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    
    String defaultMessage;
    if (customMessage != null) {
      // If custom message is provided, use it as is (screens will provide localized versions)
      defaultMessage = customMessage!;
    } else {
      // Default message based on language
      defaultMessage = isHindi 
        ? 'नमस्ते, मुझे पशु मित्र के साथ मदद चाहिए'
        : 'Hello, I need help with Pashu Mitra';
    }
    
    final message = Uri.encodeComponent(defaultMessage);
    final whatsappUrl = 'https://wa.me/$_phoneNumber?text=$message';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isHindi 
                ? 'व्हाट्सएप इंस्टॉल नहीं है। कृपया व्हाट्सएप इंस्टॉल करें।'
                : 'WhatsApp is not installed. Please install WhatsApp.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening WhatsApp: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isHindi 
              ? 'व्हाट्सएप खोलने में असमर्थ। कृपया दोबारा कोशिश करें।'
              : 'Unable to open WhatsApp. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class WhatsAppFABWrapper extends StatelessWidget {
  final Widget child;
  final String? customMessage;
  final bool showFAB;
  
  const WhatsAppFABWrapper({
    super.key,
    required this.child,
    this.customMessage,
    this.showFAB = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: showFAB 
        ? WhatsAppFAB(customMessage: customMessage)
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
