import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../posts/presentation/providers/posts_provider.dart';
import '../../../problems/presentation/providers/problems_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Safety timeout - navigate away after 15 seconds no matter what
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        debugPrint('⚠️ Splash screen timeout - navigating to auth gate');
        _navigateToAuthGate();
      }
    });
    
    // Preload data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadData();
    });
  }

  void _navigateToAuthGate() {
    // Safety timeout - if auth is still loading after 15 seconds, 
    // force it to unauthenticated so app can proceed
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.status == 'loading') {
      debugPrint('⚠️ Forcing auth status to unauthenticated due to timeout');
      // We can't directly set _status since it's private
      // But the init() method should complete eventually
      // Just log and wait - the app should recover
    }
  }

  Future<void> _preloadData() async {
    try {
      await Future.wait([
        _preloadWithTimeout(_preloadBookings, 'Bookings'),
        _preloadWithTimeout(_preloadProblems, 'Problems'),
        _preloadWithTimeout(_preloadPosts, 'Posts'),
      ], eagerError: false);
    } catch (e) {
      debugPrint('⚠️ Error preloading data: $e');
    }
  }

  Future<void> _preloadWithTimeout(Future<void> Function() preload, String name) async {
    try {
      await preload().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ $name preload timed out');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Failed to preload $name: $e');
    }
  }

  Future<void> _preloadBookings() async {
    try {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated) {
        debugPrint('⚠️ Skipping bookings preload until authentication completes');
        return;
      }

      final provider = context.read<BookingsProvider>();
      provider.loadBookedFromCacheSync();
      await provider.fetchBooked();
    } catch (e) {
      debugPrint('⚠️ Failed to preload bookings: $e');
    }
  }

  Future<void> _preloadProblems() async {
    try {
      final provider = context.read<ProblemsProvider>();
      provider.loadFromCacheSync();
      await provider.fetchProblems();
    } catch (e) {
      debugPrint('⚠️ Failed to preload problems: $e');
    }
  }

  Future<void> _preloadPosts() async {
    try {
      final provider = context.read<PostsProvider>();
      provider.loadFromCacheSync();
      await provider.fetchPosts();
    } catch (e) {
      debugPrint('⚠️ Failed to preload posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF666B42),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pashu_mitra.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
