import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/services/subscription_service.dart';
import '../../../../core/services/razorpay_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/widgets/whatsapp_fab.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/subscription_gate.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = false;
  String? _statusMessage;
  late RazorpayService _rzp;
  late SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(DioClient.instance);
    _rzp = RazorpayService(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
    _checkExistingStatus();
  }

  Future<void> _checkExistingStatus() async {
    try {
      final res = await _subscriptionService.getStatus();
      if (res['hasSubscription'] == true) {
        final status = res['data']['status'];
        if (status == 'active' || status == 'trial') {
          // Already subscribed — navigate away
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    }
  }

  Future<void> _startTrial() async {
    setState(() => _loading = true);
    try {
      final res = await _subscriptionService.startTrial();
      if (res['success'] == true) {
        final subId = res['data']['subscriptionId'];
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.user;

        _rzp.openCheckout(
          subscriptionId: subId,
          userName: user?.name ?? 'User',
          userPhone: user?.phoneNumber ?? '',
          userEmail: '${user?.phoneNumber}@pashumitra.com',
          isTrial: true,
        );
      } else {
        _showError(res['message'] ?? 'Unable to start subscription. Please try again.');
      }
    } catch (e) {
      _showError('Please check your internet connection and try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _startSubscription() async {
    setState(() => _loading = true);
    try {
      final res = await _subscriptionService.createSubscription();
      if (res['success'] == true) {
        final subId = res['data']['subscriptionId'];
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.user;

        _rzp.openCheckout(
          subscriptionId: subId,
          userName: user?.name ?? 'User',
          userPhone: user?.phoneNumber ?? '',
          userEmail: '${user?.phoneNumber}@pashumitra.com',
          isTrial: false,
        );
      } else {
        _showError(res['message'] ?? 'Unable to start subscription. Please try again.');
      }
    } catch (e) {
      _showError('Please check your internet connection and try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('✅ Payment success: ${response.paymentId}');
    
    // Clear subscription cache to fetch fresh status
    SubscriptionGate.clearCache();
    
    // Show activation dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ActivationDialog(
          onComplete: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(true); // Return to previous screen
          },
        ),
      );
    }
    
    // Poll status in background
    await _pollForActive();
  }

  Future<void> _pollForActive({int retries = 10}) async {
    for (int i = 0; i < retries; i++) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final res = await _subscriptionService.getStatus();
        final status = res['data']?['status'];
        
        debugPrint('📊 Poll attempt ${i + 1}/$retries - Status: $status');
        
        // Check if subscription is activated
        if (status == 'active' || status == 'trial') {
          debugPrint('✅ Subscription activated!');
          if (mounted) {
            // Dispose Razorpay service
            _rzp.dispose();
            // Pop all screens and let _AuthGate show HomeScreen
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        }
        
        // Accept "created" status after 5 seconds (5 attempts)
        if (i >= 4 && status == 'created') {
          debugPrint('⚠️ Status is "created" after ${i + 1} attempts, accepting as success');
          if (mounted) {
            // Dispose Razorpay service
            _rzp.dispose();
            // Pop all screens and let _AuthGate show HomeScreen
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        }
      } catch (e) {
        debugPrint('❌ Error polling status (attempt ${i + 1}): $e');
        // On error, continue polling unless it's the last attempt
        if (i == retries - 1) {
          debugPrint('⚠️ Max retries reached with errors, closing anyway');
          if (mounted) {
            // Dispose Razorpay service
            _rzp.dispose();
            // Pop all screens and let _AuthGate show HomeScreen
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        }
      }
    }
    
    // Max retries reached - close dialog anyway
    debugPrint('⏱️ Max retries reached, closing dialog');
    if (mounted) {
      // Dispose Razorpay service
      _rzp.dispose();
      // Pop all screens and let _AuthGate show HomeScreen
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    debugPrint('❌ Payment failed: ${response.message}');
    _showError('Payment processing issue. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External wallet: ${response.walletName}');
    _showError('External wallet selected: ${response.walletName}');
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _rzp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Builder(
        builder: (context) {
          final localeProvider = context.watch<LocaleProvider>();
          final isHindi = localeProvider.locale.languageCode == 'hi';
          return WhatsAppFAB(
            customMessage: isHindi 
              ? 'नमस्ते, मुझे पशु मित्र पर मदद चाहिए'
              : 'Hello, I need help from Pashu Mitra',
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: const Color(0xFF666B42),
        title: Text(
          l10n.isHindi ? 'सदस्यता लें' : 'Subscribe to Pashumitra',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green.shade900),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Trial option
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.green.shade200, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.isHindi ? 'सबसे लोकप्रिय' : 'MOST POPULAR',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.isHindi ? '₹1 में आज़माएं' : 'Try for ₹1',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF666B42),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.isHindi
                                ? '1 दिन का ट्रायल, फिर ₹999/माह'
                                : '1-day trial, then ₹999/month',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _startTrial,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF666B42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                l10n.isHindi
                                    ? '₹1 ट्रायल शुरू करें'
                                    : 'Start ₹1 Trial',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Full subscription option
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            '₹999 / ${l10n.isHindi ? 'माह' : 'month'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF666B42),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.isHindi
                                ? 'पूर्ण सदस्यता, वार्षिक बिलिंग'
                                : 'Full subscription, billed annually',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _loading ? null : _startSubscription,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF666B42),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                l10n.isHindi ? 'अभी सदस्यता लें' : 'Subscribe Now',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF666B42),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Benefits section
                  Text(
                    l10n.isHindi ? 'सदस्यता के लाभ:' : 'Subscription Benefits:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefit(
                    l10n.isHindi
                        ? '✓ विशेषज्ञों से असीमित कॉल'
                        : '✓ Unlimited calls with experts',
                  ),
                  _buildBenefit(
                    l10n.isHindi
                        ? '✓ 24/7 पशु स्वास्थ्य सहायता'
                        : '✓ 24/7 animal health support',
                  ),
                  _buildBenefit(
                    l10n.isHindi
                        ? '✓ व्यक्तिगत देखभाल सलाह'
                        : '✓ Personalized care advice',
                  ),
                  _buildBenefit(
                    l10n.isHindi
                        ? '✓ प्रीमियम सामग्री तक पहुंच'
                        : '✓ Access to premium content',
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF666B42), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}


// Activation Dialog Widget
class _ActivationDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _ActivationDialog({required this.onComplete});

  @override
  State<_ActivationDialog> createState() => _ActivationDialogState();
}

class _ActivationDialogState extends State<_ActivationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _dots = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Animate dots
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _dots = (_dots + 1) % 4);
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated checkmark
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF666B42).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF666B42),
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              l10n.isHindi ? 'भुगतान सफल!' : 'Payment Successful!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666B42),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Activating message with animated dots
            Text(
              (l10n.isHindi ? 'सक्रिय हो रहा है' : 'Activating') +
                  '.' * _dots,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Progress indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFF666B42),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            
            // Info text
            Text(
              l10n.isHindi
                  ? 'कृपया प्रतीक्षा करें...'
                  : 'Please wait...',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
