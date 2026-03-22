import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  // ⚠️ TEST KEY — swap to rzp_live_XXXX before production
  static const String _testKeyId = 'rzp_test_SLwqBOmzonmj2y';

  late Razorpay _razorpay;
  final void Function(PaymentSuccessResponse) onSuccess;
  final void Function(PaymentFailureResponse) onFailure;
  final void Function(ExternalWalletResponse) onExternalWallet;

  RazorpayService({
    required this.onSuccess,
    required this.onFailure,
    required this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  /// Opens the Razorpay checkout for a subscription
  void openCheckout({
    required String subscriptionId,
    required String userName,
    required String userPhone,
    required String userEmail,
    required bool isTrial,
  }) {
    debugPrint('💳 Opening Razorpay checkout...');
    debugPrint('💳 Subscription ID: $subscriptionId');
    debugPrint('💳 Is Trial: $isTrial');

    final options = {
      'key': _testKeyId,
      'subscription_id': subscriptionId, // IMPORTANT: use subscription_id, NOT amount
      'name': 'Pashumitra',
      'description': isTrial ? '₹1 Trial Subscription (1 day)' : '₹999/year Subscription',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#666B42', // Pashumitra green
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ Error opening Razorpay: $e');
    }
  }

  void dispose() {
    debugPrint('💳 Disposing Razorpay service');
    _razorpay.clear();
  }
}
