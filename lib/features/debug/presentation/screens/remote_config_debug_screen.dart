import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/remote_config_provider.dart';

class RemoteConfigDebugScreen extends StatefulWidget {
  const RemoteConfigDebugScreen({super.key});

  @override
  State<RemoteConfigDebugScreen> createState() => _RemoteConfigDebugScreenState();
}

class _RemoteConfigDebugScreenState extends State<RemoteConfigDebugScreen> {
  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _forceRefresh(RemoteConfigProvider provider) async {
    try {
      final updated = await provider.forceRefresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updated 
              ? '✅ Remote Config updated successfully' 
              : 'ℹ️ No updates available'),
            backgroundColor: updated ? Colors.green : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to refresh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RemoteConfigProvider>(
      builder: (context, remoteConfigProvider, child) {
        final configValues = remoteConfigProvider.getAllValues();
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Remote Config Debug'),
            backgroundColor: const Color(0xFF666B42),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: remoteConfigProvider.isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
                onPressed: remoteConfigProvider.isLoading 
                  ? null 
                  : () => _forceRefresh(remoteConfigProvider),
                tooltip: 'Force Refresh',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _forceRefresh(remoteConfigProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Error Display
                if (remoteConfigProvider.error != null)
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error: ${remoteConfigProvider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: remoteConfigProvider.clearError,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                if (remoteConfigProvider.error != null)
                  const SizedBox(height: 16),
                
                // Current Values Section
                _buildSection(
                  title: 'Current Values',
                  children: [
                    _buildValueTile(
                      'Base URL',
                      remoteConfigProvider.baseUrl,
                      'Used for all API calls',
                    ),
                    _buildValueTile(
                      'App URL',
                      remoteConfigProvider.appUrl,
                      'Used for "Tell a Friend" feature',
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Remote Config Status
                _buildSection(
                  title: 'Remote Config Status',
                  children: [
                    _buildInfoTile(
                      'Initialized', 
                      remoteConfigProvider.isInitialized ? 'Yes' : 'No',
                    ),
                    _buildInfoTile(
                      'Loading', 
                      remoteConfigProvider.isLoading ? 'Yes' : 'No',
                    ),
                    if (remoteConfigProvider.lastFetchTime != null)
                      _buildInfoTile(
                        'Last Fetch', 
                        remoteConfigProvider.lastFetchTime!.toIso8601String(),
                      ),
                    _buildInfoTile('Status', configValues['status'] ?? 'Unknown'),
                    if (configValues['last_fetch_status'] != null)
                      _buildInfoTile('Last Fetch Status', configValues['last_fetch_status']),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                _buildSection(
                  title: 'Instructions',
                  children: [
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to update values:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('1. Go to Firebase Console'),
                            Text('2. Navigate to Remote Config'),
                            Text('3. Update these parameters:'),
                            SizedBox(height: 8),
                            Text('   • base_url - Backend API URL'),
                            Text('   • app_url - App download/share URL'),
                            SizedBox(height: 8),
                            Text('4. Publish changes'),
                            Text('5. Use "Force Refresh" button above'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF666B42),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildValueTile(String title, String value, String description) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(value),
          tooltip: 'Copy',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(value),
          tooltip: 'Copy',
        ),
      ),
    );
  }
}