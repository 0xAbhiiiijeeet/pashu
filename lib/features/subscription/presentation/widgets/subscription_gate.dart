import 'package:flutter/material.dart';

import '../../../../core/services/subscription_service.dart';
import '../../../../core/network/dio_client.dart';
import '../screens/subscription_screen.dart';

class SubscriptionGate {
  // Cache subscription status for 30 seconds to avoid redundant API calls
  static Map<String, dynamic>? _cachedStatus;
  static DateTime? _cacheTime;
  static const _cacheDuration = Duration(seconds: 30);
  
  static void clearCache() {
    _cachedStatus = null;
    _cacheTime = null;
  }
  
  static Future<bool> checkAccess(BuildContext context) async {
    try {
      Map<String, dynamic> res;
      
      // Check if cache is valid
      if (_cachedStatus != null && 
          _cacheTime != null && 
          DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        debugPrint('✅ Using cached subscription status');
        res = _cachedStatus!;
      } else {
        // Fetch fresh status
        debugPrint('🔄 Fetching fresh subscription status');
        final subscriptionService = SubscriptionService(DioClient.instance);
        res = await subscriptionService.getStatus();
        
        // Cache the result
        _cachedStatus = res;
        _cacheTime = DateTime.now();
      }
      
      final hasAccess = res['hasSubscription'] == true &&
          ['active', 'trial', 'created'].contains(res['data']?['status']);
      
      if (hasAccess) {
        return true;
      } else {
        // Clear cache when no access
        clearCache();
        
        // Show subscription screen
        if (!context.mounted) return false;
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const SubscriptionScreen(),
          ),
        );
        return result == true;
      }
    } catch (e) {
      debugPrint('❌ Error checking subscription: $e');
      // Clear cache on error
      clearCache();
      
      // On error, show subscription screen to be safe
      if (!context.mounted) return false;
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionScreen(),
        ),
      );
      return result == true;
    }
  }
}
