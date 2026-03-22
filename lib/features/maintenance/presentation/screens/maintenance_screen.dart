import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/settings_provider.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    
    // Use backend message or professional default
    final maintenanceText = (settingsProvider.maintenanceText != null && 
                            settingsProvider.maintenanceText!.isNotEmpty)
        ? settingsProvider.maintenanceText!
        : 'हम अपनी सेवाओं को बेहतर बनाने के लिए काम कर रहे हैं। कृपया कुछ समय बाद पुनः प्रयास करें।\n\nWe are working to improve our services. Please try again after some time.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Maintenance Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title (Bilingual)
                const Text(
                  'रखरखाव मोड\nMaintenance Mode',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Maintenance Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          maintenanceText,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Description (Bilingual)
                Text(
                  'हम अपनी सेवाओं को बेहतर बनाने के लिए काम कर रहे हैं।\nWe are working to improve our services.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Retry Button (Bilingual)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: settingsProvider.isLoading
                        ? null
                        : () async {
                            await settingsProvider.forceRefresh();
                          },
                    icon: settingsProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text(
                      'पुनः जांचें / Check Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Contact Support (Bilingual)
                TextButton.icon(
                  onPressed: null, // Disabled for now
                  icon: const Icon(Icons.support_agent),
                  label: const Text(
                    'सहायता से संपर्क करें / Contact Support',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
