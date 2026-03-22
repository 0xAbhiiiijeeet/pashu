import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/settings_provider.dart';
import '../../features/maintenance/presentation/screens/maintenance_screen.dart';

/// Wrapper that checks maintenance mode and blocks app if active
class MaintenanceWrapper extends StatefulWidget {
  final Widget child;

  const MaintenanceWrapper({
    super.key,
    required this.child,
  });

  @override
  State<MaintenanceWrapper> createState() => _MaintenanceWrapperState();
}

class _MaintenanceWrapperState extends State<MaintenanceWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Fetch settings on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchSettings();
    });
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check maintenance status when app resumes
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed, force checking maintenance status...');
      // Force refresh to bypass cache and wait for completion
      context.read<SettingsProvider>().forceRefresh().then((_) {
        debugPrint('✅ Maintenance check completed');
        // Force rebuild to check new status
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    // If maintenance mode is active, show maintenance screen
    if (settingsProvider.isMaintenanceMode) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const MaintenanceScreen(),
      );
    }

    // Otherwise, show the normal app
    return widget.child;
  }
}
