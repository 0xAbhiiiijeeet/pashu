import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/marketplace_provider.dart';
import '../screens/cow_detail_screen.dart';
import '../../domain/models/cow_sale_model.dart';

class BuyingSection extends StatefulWidget {
  const BuyingSection({super.key});

  @override
  State<BuyingSection> createState() => _BuyingSectionState();
}

class _BuyingSectionState extends State<BuyingSection> {
  final TextEditingController _searchController = TextEditingController();
  double? _maxPrice;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<MarketplaceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.approvedSales.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.approvedSales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchApprovedSales(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (provider.approvedSales.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCowsAvailable,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.checkBackLater,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Apply local filtering
        var filteredSales = provider.approvedSales.where((sale) {
          final breedMatch = _searchController.text.isEmpty ||
              sale.cowDetails.breed
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
          final priceMatch =
              _maxPrice == null || sale.cowDetails.price <= _maxPrice!;
          return breedMatch && priceMatch;
        }).toList();

        return Column(
          children: [
            // Filter Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchBreed,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        l10n.maxPrice,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Slider(
                          value: _maxPrice ?? 200000,
                          min: 5000,
                          max: 200000,
                          divisions: 39,
                          label: _maxPrice != null
                              ? '₹${_maxPrice!.toStringAsFixed(0)}'
                              : l10n.any,
                          onChanged: (val) {
                            setState(() {
                              _maxPrice = val;
                            });
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _maxPrice = null;
                            _searchController.clear();
                          });
                        },
                        child: Text(l10n.clear),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grid View
            Expanded(
              child: filteredSales.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noCowsMatchFilters,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchApprovedSales(),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredSales.length,
                        itemBuilder: (context, index) {
                          final sale = filteredSales[index];
                          return _CowCard(sale: sale);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CowCard extends StatelessWidget {
  final CowSaleModel sale;

  const _CowCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CowDetailScreen(sale: sale),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: sale.cowDetails.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        sale.cowDetails.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                      child:
                          const Icon(Icons.pets, size: 50, color: Colors.grey),
                    ),
            ),

            // Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      sale.cowDetails.breed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${sale.cowDetails.price.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_today,
                          label: '${sale.cowDetails.age}y',
                        ),
                        _InfoChip(
                          icon: Icons.water_drop,
                          label: '${sale.cowDetails.milkYield}L',
                        ),
                      ],
                    ),
                    if (sale.seller != null)
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sale.seller!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
