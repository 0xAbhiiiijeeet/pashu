import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/name_bottom_sheet.dart';
import '../../../../shared/widgets/pashu_mitra_nav_bar.dart';
import '../../../../shared/widgets/whatsapp_fab.dart';
import '../widgets/home_tab.dart';
import '../widgets/bookings_tab.dart';
import '../../../posts/presentation/widgets/posts_feed_tab.dart';
import '../../../marketplace/presentation/screens/marketplace_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOnboarding());
  }

  Future<void> _checkOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.needsOnboarding) return;
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Cannot dismiss until name is entered
      enableDrag: false, // Cannot drag to dismiss
      backgroundColor: Colors.transparent,
      builder: (_) => const NameBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar (green primary) ───────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Image.asset(
            'assets/images/pashu_mitra.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
        ],
      ),

      // ── Body (tab switcher) ──────────────────────────────────────────
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeTab(),
            const PostsFeedTab(),
            const MarketplaceTab(),
            BookingsTab(
              onBookCallTap: () {
                // Switch to Home tab to select problems
                setState(() => _currentIndex = 0);
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: PashuMitraNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
      
      floatingActionButton: Builder(
        builder: (context) {
          final localeProvider = context.watch<LocaleProvider>();
          final isHindi = localeProvider.locale.languageCode == 'hi';
          return WhatsAppFAB(
            customMessage: isHindi 
              ? 'नमस्ते! मुझे पशु मित्र के साथ मदद चाहिए'
              : 'Hello! I need help from Pashu Mitra ',
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
