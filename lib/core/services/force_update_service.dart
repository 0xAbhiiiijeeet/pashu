import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/dio_client.dart';
import '../constants/api_endpoints.dart';

class ForceUpdateService {
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.pashumitra.app';
  
  final DioClient _dioClient;
  
  ForceUpdateService(this._dioClient);

  /// Check if app update is required
  Future<UpdateInfo> checkForUpdate() async {
    try {
      debugPrint('🔄 Checking for app updates...');
      
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      debugPrint('📱 Current version: $currentVersion');
      
      // Call API to get latest version info
      // Backend expects: GET /api/settings/version-check?version=1.0.0&platform=android
      final response = await _dioClient.get(
        '${ApiEndpoints.versionCheck}?version=$currentVersion&platform=android',
      );
      
      // Check if response is HTML (404 error page)
      if (response.data is String && response.data.toString().contains('<!DOCTYPE html>')) {
        debugPrint('❌ Version check endpoint not found (404)');
        return UpdateInfo(
          isUpdateRequired: false,
          isForceUpdate: false,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          updateLink: _playStoreUrl,
        );
      }
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        debugPrint('❌ Version check API returned error');
        return UpdateInfo(
          isUpdateRequired: false,
          isForceUpdate: false,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          updateLink: _playStoreUrl,
        );
      }
      
      // Backend response format:
      // {
      //   "success": true,
      //   "updateAvailable": true,
      //   "forceUpdate": false,
      //   "latestVersion": "1.1.0",
      //   "updateLink": "https://play.google.com/..."
      // }
      final updateAvailable = data['updateAvailable'] as bool? ?? false;
      final forceUpdate = data['forceUpdate'] as bool? ?? false;
      final latestVersion = data['latestVersion'] as String? ?? currentVersion;
      final updateLink = data['updateLink'] as String? ?? _playStoreUrl;
      
      debugPrint('📱 Latest version: $latestVersion');
      debugPrint('📱 Update available: $updateAvailable');
      debugPrint('📱 Force update: $forceUpdate');
      
      return UpdateInfo(
        isUpdateRequired: updateAvailable,
        isForceUpdate: forceUpdate,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        updateLink: updateLink,
      );
      
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
      // On error, don't block the app
      final packageInfo = await PackageInfo.fromPlatform();
      return UpdateInfo(
        isUpdateRequired: false,
        isForceUpdate: false,
        currentVersion: packageInfo.version,
        latestVersion: packageInfo.version,
        updateLink: _playStoreUrl,
      );
    }
  }
  
  /// Show update dialog
  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo updateInfo, {
    bool isHindi = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.isForceUpdate,
      builder: (BuildContext context) {
        return PopScope(
          canPop: !updateInfo.isForceUpdate,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.system_update,
                  color: Color(0xFF666B42),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    updateInfo.isForceUpdate
                        ? (isHindi ? 'अपडेट आवश्यक' : 'Update Required')
                        : (isHindi ? 'अपडेट उपलब्ध' : 'Update Available'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666B42),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  updateInfo.isForceUpdate
                      ? (isHindi 
                           ? 'आपको ऐप का नवीनतम संस्करण डाउनलोड करना होगा।'
                           : 'You need to download the latest version of the app.')
                      : (isHindi 
                           ? 'ऐप का नया संस्करण उपलब्ध है। बेहतर अनुभव के लिए अपडेट करें।'
                           : 'A new version of the app is available. Update for better experience.'),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isHindi ? 'वर्तमान संस्करण:' : 'Current Version:',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(updateInfo.currentVersion),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isHindi ? 'नवीनतम संस्करण:' : 'Latest Version:',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            updateInfo.latestVersion,
                            style: const TextStyle(
                              color: Color(0xFF666B42),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (!updateInfo.isForceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    isHindi ? 'बाद में' : 'Later',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ElevatedButton(
                onPressed: () => _openStore(updateInfo.updateLink),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF666B42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isHindi ? 'अपडेट करें' : 'Update',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Open app store for update
  static Future<void> _openStore(String updateLink) async {
    try {
      final uri = Uri.parse(updateLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ Could not launch store: $updateLink');
      }
    } catch (e) {
      debugPrint('❌ Error opening store: $e');
    }
  }
}

class UpdateInfo {
  final bool isUpdateRequired;
  final bool isForceUpdate;
  final String currentVersion;
  final String latestVersion;
  final String updateLink;
  
  UpdateInfo({
    required this.isUpdateRequired,
    required this.isForceUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.updateLink,
  });
  
  @override
  String toString() {
    return 'UpdateInfo(isUpdateRequired: $isUpdateRequired, isForceUpdate: $isForceUpdate, current: $currentVersion, latest: $latestVersion)';
  }
}