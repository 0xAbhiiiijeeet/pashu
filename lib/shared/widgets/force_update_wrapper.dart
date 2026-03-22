import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/force_update_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/localization/locale_provider.dart';

class ForceUpdateWrapper extends StatefulWidget {
  final Widget child;
  final bool checkOnInit;
  
  const ForceUpdateWrapper({
    super.key,
    required this.child,
    this.checkOnInit = true,
  });

  @override
  State<ForceUpdateWrapper> createState() => _ForceUpdateWrapperState();
}

class _ForceUpdateWrapperState extends State<ForceUpdateWrapper> {
  late ForceUpdateService _updateService;
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _updateService = ForceUpdateService(DioClient.instance);
    
    if (widget.checkOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdates();
      });
    }
  }

  Future<void> _checkForUpdates() async {
    if (_hasChecked) return;
    
    try {
      final updateInfo = await _updateService.checkForUpdate();
      debugPrint('📱 Update check result: $updateInfo');
      
      if (mounted && updateInfo.isUpdateRequired) {
        final localeProvider = context.read<LocaleProvider>();
        final isHindi = localeProvider.locale.languageCode == 'hi';
        
        await ForceUpdateService.showUpdateDialog(
          context,
          updateInfo,
          isHindi: isHindi,
        );
      }
      
      _hasChecked = true;
    } catch (e) {
      debugPrint('❌ Error during update check: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Just return the child - no loading overlay
    // Update check happens silently in background
    return widget.child;
  }
}