import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/marketplace_provider.dart';
import '../screens/upload_cow_screen.dart';
import '../../domain/models/cow_sale_model.dart';

class SellingSection extends StatefulWidget {
  const SellingSection({super.key});

  @override
  State<SellingSection> createState() => _SellingSectionState();
}

class _SellingSectionState extends State<SellingSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchMySales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Add Cow Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UploadCowScreen(),
                      ),
                    ).then((_) {
                      // Refresh list after upload
                      provider.fetchMySales();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.sellYourCow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // My Sales List
            Expanded(
              child: _buildMySalesList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMySalesList(MarketplaceProvider provider) {
    final l10n = AppLocalizations.of(context);
    
    if (provider.isLoading && provider.mySales.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.mySales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchMySales(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (provider.mySales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noCowsListed,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapToGetStarted,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMySales(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.mySales.length,
        itemBuilder: (context, index) {
          final sale = provider.mySales[index];
          return _MySaleCard(sale: sale);
        },
      ),
    );
  }
}

class _MySaleCard extends StatelessWidget {
  final CowSaleModel sale;

  const _MySaleCard({required this.sale});

  Color _getStatusColor() {
    switch (sale.status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'sold':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (sale.status) {
      case 'approved':
        return l10n.approved;
      case 'rejected':
        return l10n.rejected;
      case 'sold':
        return l10n.sold;
      default:
        return l10n.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: sale.cowDetails.images.isNotEmpty
                  ? Image.network(
                      sale.cowDetails.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sale.cowDetails.breed,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(context),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${sale.cowDetails.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.years(sale.cowDetails.age)} • ${l10n.litersPerDay(sale.cowDetails.milkYield)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
