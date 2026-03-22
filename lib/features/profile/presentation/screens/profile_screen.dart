import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/force_update_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/widgets/whatsapp_fab.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_form.dart';
import '../widgets/subscription_card.dart';
import '../widgets/profile_menu_items.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isRefreshing = false;
  Key _subscriptionCardKey = UniqueKey();
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      debugPrint('Error loading version: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    final localeProvider = context.read<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF666B42)),
                  SizedBox(height: 16),
                  Text('Checking for updates...'),
                ],
              ),
            ),
          ),
        ),
      );
      
      final updateService = ForceUpdateService(DioClient.instance);
      final updateInfo = await updateService.checkForUpdate();
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (updateInfo.isUpdateRequired) {
        await ForceUpdateService.showUpdateDialog(
          context,
          updateInfo,
          isHindi: isHindi,
        );
      } else {
        // Show "up to date" message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isHindi 
                  ? 'आपका ऐप अप टू डेट है!'
                  : 'Your app is up to date!',
              ),
              backgroundColor: const Color(0xFF666B42),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi 
                ? 'अपडेट जांचने में असमर्थ। कृपया दोबारा कोशिश करें।'
                : 'Unable to check for updates. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.fetchCurrentUser();
      
      // Refresh subscription card by changing its key
      setState(() {
        _subscriptionCardKey = UniqueKey();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.user?.profileDetails?.language == 'Hindi'
                  ? 'प्रोफाइल अपडेट की गई'
                  : 'Profile refreshed',
            ),
            backgroundColor: const Color(0xFF666B42),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.user?.profileDetails?.language == 'Hindi'
                  ? 'प्रोफाइल रिफ्रेश करने में असमर्थ। कृपया दोबारा कोशिश करें।'
                  : 'Unable to refresh your profile. Please try again.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = authProvider.user;
    final isHindi = localeProvider.locale.languageCode == 'hi';

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // If editing, ask for confirmation before going back
        if (_isEditing) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(isHindi ? 'परिवर्तन छोड़ें?' : 'Discard changes?'),
              content: Text(
                isHindi 
                  ? 'क्या आप बिना सहेजे वापस जाना चाहते हैं?' 
                  : 'Do you want to go back without saving?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    isHindi ? 'रद्द करें' : 'Cancel',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    isHindi ? 'छोड़ें' : 'Discard',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          
          if (shouldPop == true && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        floatingActionButton: _isEditing ? null : WhatsAppFAB(
          customMessage: isHindi 
            ? 'नमस्ते, मुझे पशु मित्र पर मदद चाहिए'
            : 'Hello, I need help from Pashu Mitra',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEditing
                ? (isHindi ? 'प्रोफाइल संपादित करें' : 'Edit Profile')
                : '${user.name ?? (isHindi ? 'आपकी प्रोफाइल' : 'Your Profile')} ji',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (!_isEditing)
              GestureDetector(
                onTap: () => localeProvider.toggleLanguage(),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  constraints: const BoxConstraints(
                    minHeight: 40, // Responsive height
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCAB78F),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'En',
                        style: TextStyle(
                          color: isHindi ? Colors.black : const Color(0xFF666B42),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.black26,
                      ),
                      Text(
                        'हिं',
                        style: TextStyle(
                          color: isHindi ? const Color(0xFF666B42) : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: _isEditing
              ? ProfileForm(
                  user: user,
                  onSave: () {
                    setState(() => _isEditing = false);
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isHindi 
                            ? 'प्रोफाइल सफलतापूर्वक अपडेट की गई' 
                            : 'Profile updated successfully',
                        ),
                        backgroundColor: const Color(0xFF666B42),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  onCancel: () => setState(() => _isEditing = false),
                )
              : SingleChildScrollView(
                  child: RefreshIndicator(
                    onRefresh: _refreshProfile,
                    color: const Color(0xFF666B42),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ProfileHeader(
                          user: user,
                          onEdit: () => setState(() => _isEditing = true),
                        ),
                        const SizedBox(height: 16),
                        SubscriptionCard(key: _subscriptionCardKey),
                        const SizedBox(height: 16),
                        ProfileMenuItems(onCheckUpdates: _checkForUpdates),
                        const SizedBox(height: 24),
                        _buildFooter(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    
    return Column(
      children: [
        Text(
          '$_version ($_buildNumber)',
          style: const TextStyle(
            color: Color(0xFF909090),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFE3E3E3),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink(isHindi ? 'गोपनीयता' : 'Privacy'),
            _buildDot(),
            _buildFooterLink(isHindi ? 'नियम' : 'Terms'),
            _buildDot(),
            _buildFooterLink(isHindi ? 'रिफंड और रद्दीकरण' : 'Refund & Cancellation'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isHindi
              ? '© 2026 पशु मित्र। सर्वाधिकार सुरक्षित।'
              : '© 2026 Pashu Mitra. All rights reserved.',
          style: const TextStyle(
            color: Color(0xFFBCB9B9),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9C9C9C),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(
          color: Color(0xFF9C9C9C),
          fontSize: 20,
        ),
      ),
    );
  }
}
