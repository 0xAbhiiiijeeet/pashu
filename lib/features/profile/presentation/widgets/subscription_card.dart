import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';

class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({super.key});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool _loading = true;
  bool _hasSubscription = false;
  Map<String, dynamic>? _subscriptionData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionStatus();
  }

  Future<void> _fetchSubscriptionStatus() async {
    try {
      final subscriptionService = SubscriptionService(DioClient.instance);
      final res = await subscriptionService.getStatus();
      
      debugPrint('📊 Subscription response: $res');
      debugPrint('📊 Has subscription: ${res['hasSubscription']}');
      debugPrint('📊 Subscription data: ${res['data']}');
      
      if (mounted) {
        setState(() {
          _hasSubscription = res['hasSubscription'] == true;
          _subscriptionData = res['data'];
          _loading = false;
        });
        
        // Debug log the dates
        if (_subscriptionData != null) {
          debugPrint('📅 currentPeriodStart: ${_subscriptionData!['currentPeriodStart']}');
          debugPrint('📅 currentPeriodEnd: ${_subscriptionData!['currentPeriodEnd']}');
          debugPrint('📅 trialEndsAt: ${_subscriptionData!['trialEndsAt']}');
          debugPrint('📅 isTrial: ${_subscriptionData!['isTrial']}');
          debugPrint('📅 status: ${_subscriptionData!['status']}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching subscription: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _navigateToSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    ).then((_) {
      // Refresh subscription status after returning
      _fetchSubscriptionStatus();
    });
  }

  String _formatDate(String? dateStr, {bool isHindi = false}) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    try {
      final date = DateTime.parse(dateStr);
      // Use localized date format
      if (isHindi) {
        return DateFormat('dd MMM yyyy', 'hi').format(date);
      } else {
        return DateFormat('dd MMM yyyy', 'en').format(date);
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 17),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || !_hasSubscription) {
      // No subscription - show subscribe button
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 17),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF666B42), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFF666B42),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.isHindi
                        ? 'सदस्यता लें और अधिक लाभ पाएं'
                        : 'Subscribe for More Benefits',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.isHindi
                  ? '• विशेषज्ञों से असीमित कॉल\n• 24/7 पशु स्वास्थ्य सहायता\n• व्यक्तिगत देखभाल सलाह'
                  : '• Unlimited calls with experts\n• 24/7 animal health support\n• Personalized care advice',
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF666B42),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.isHindi ? 'अभी सदस्यता लें' : 'Subscribe Now',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Has subscription - show subscription details
    final status = _subscriptionData?['status'] ?? '';
    final isTrial = _subscriptionData?['isTrial'] == true;
    final trialEndsAt = _subscriptionData?['trialEndsAt'];
    final currentPeriodStart = _subscriptionData?['currentPeriodStart'];
    final currentPeriodEnd = _subscriptionData?['currentPeriodEnd'];
    final paidCount = _subscriptionData?['paidCount'] ?? 0;

    // Determine subscription title
    String title;
    String subtitle;
    if (isTrial) {
      title = l10n.isHindi ? '₹1 ट्रायल सक्रिय' : '₹1 Trial Active';
      subtitle = l10n.isHindi
          ? 'ट्रायल के बाद ₹999 प्रति माह'
          : '₹999 per month after trial';
    } else {
      title = l10n.isHindi ? '₹999 / माह' : '₹999 / month';
      subtitle = l10n.isHindi
          ? 'सक्रिय सदस्यता'
          : 'Active subscription';
    }

    // Status color and text
    Color statusColor;
    String statusText;
    bool showStatusBadge = true;
    
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = l10n.isHindi ? 'सक्रिय' : 'Active';
        break;
      case 'trial':
        statusColor = Colors.blue;
        statusText = l10n.isHindi ? 'ट्रायल' : 'Trial';
        break;
      case 'created':
        // Treat 'created' as active but don't show badge (webhook pending)
        statusColor = Colors.green;
        statusText = l10n.isHindi ? 'सक्रिय' : 'Active';
        showStatusBadge = false; // Hide badge for 'created' status
        break;
      case 'halted':
        statusColor = Colors.orange;
        statusText = l10n.isHindi ? 'रोका गया' : 'Halted';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = l10n.isHindi ? 'रद्द किया गया' : 'Cancelled';
        break;
      case 'expired':
        statusColor = Colors.grey;
        statusText = l10n.isHindi ? 'समाप्त' : 'Expired';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7A7A7A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (showStatusBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.starting,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(
                        currentPeriodStart,
                        isHindi: l10n.isHindi,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF666B42),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.ending,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(
                        isTrial ? trialEndsAt : currentPeriodEnd,
                        isHindi: l10n.isHindi,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF666B42),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status == 'active' || status == 'trial') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD7E4DA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Color(0xFF666B42),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTrial
                          ? (l10n.isHindi
                              ? 'ट्रायल ${_formatDate(trialEndsAt)} को समाप्त होगा'
                              : 'Trial ends on ${_formatDate(trialEndsAt)}')
                          : (l10n.isHindi
                              ? 'अगला भुगतान ${_formatDate(currentPeriodEnd)} को'
                              : 'Next payment on ${_formatDate(currentPeriodEnd)}'),
                      style: const TextStyle(
                        color: Color(0xFF666B42),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement cancel subscription
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.isHindi
                                ? 'सदस्यता रद्द करने के लिए हमसे संपर्क करें'
                                : 'Contact us to cancel subscription',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF666C3F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.cancelSubscription,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (paidCount > 0) ...[
            const SizedBox(height: 12),
            Text(
              l10n.isHindi
                  ? 'कुल भुगतान: $paidCount'
                  : 'Total payments: $paidCount',
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
