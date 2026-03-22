import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/cattle_listing_model.dart';
import '../widgets/shared_widgets.dart';

class BuyCattleScreen extends StatefulWidget {
  const BuyCattleScreen({super.key});

  @override
  State<BuyCattleScreen> createState() => _BuyCattleScreenState();
}

class _BuyCattleScreenState extends State<BuyCattleScreen> {
  // Filter state
  String _selectedAnimalType = 'सभी';
  String _selectedBreed = 'सभी नस्लें';
  String _selectedLocation = 'सभी स्थान';
  RangeValues _milkRange = const RangeValues(0, 20);
  RangeValues _priceRange = const RangeValues(0, 600000);
  bool _filtersExpanded = false;

  final List<String> _animalTypes = ['सभी', 'गाय', 'भैंस'];

  List<CattleListing> get _filteredListings {
    return dummyListings.where((listing) {
      // Animal type filter
      if (_selectedAnimalType == 'गाय' && listing.type != AnimalType.cow) {
        return false;
      }
      if (_selectedAnimalType == 'भैंस' && listing.type != AnimalType.buffalo) {
        return false;
      }

      // Breed filter
      if (_selectedBreed != 'सभी नस्लें' && listing.breed != _selectedBreed) {
        return false;
      }

      // Location filter
      if (_selectedLocation != 'सभी स्थान' &&
          !listing.location.contains(_selectedLocation)) {
        return false;
      }

      // Milk capacity filter
      if (listing.milkCapacity < _milkRange.start ||
          listing.milkCapacity > _milkRange.end) {
        return false;
      }

      // Price filter
      if (listing.priceMax < _priceRange.start ||
          listing.priceMin > _priceRange.end) {
        return false;
      }

      return true;
    }).toList();
  }

  String _formatPrice(double value) {
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    return '₹${(value / 1000).toStringAsFixed(0)}K';
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredListings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'पशु ख़रीदें',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _hasActiveFilters(),
              child: const Icon(Icons.tune),
            ),
            onPressed: () =>
                setState(() => _filtersExpanded = !_filtersExpanded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Animal type quick tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: FilterChipRow(
              options: _animalTypes,
              selected: _selectedAnimalType,
              onSelected: (value) => setState(() => _selectedAnimalType = value),
            ),
          ),

          // Expanded filter panel
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _filtersExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildFilterPanel(),
            secondChild: const SizedBox.shrink(),
          ),

          // Result count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  '${results.length} पशु मिले',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),

          // Listing list
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'कोई पशु नहीं मिला। फ़िल्टर बदलें।',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: results.length,
                    itemBuilder: (_, i) => CattleListingCard(listing: results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedBreed != 'सभी नस्लें' ||
        _selectedLocation != 'सभी स्थान' ||
        _milkRange.start > 0 ||
        _milkRange.end < 20 ||
        _priceRange.start > 0 ||
        _priceRange.end < 600000;
  }

  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breed + Location row
          Row(
            children: [
              Expanded(
                child: _DropdownFilter(
                  label: 'नस्ल',
                  value: _selectedBreed,
                  items: dummyBreeds,
                  onChanged: (value) => setState(() => _selectedBreed = value!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownFilter(
                  label: 'स्थान',
                  value: _selectedLocation,
                  items: dummyLocations,
                  onChanged: (value) => setState(() => _selectedLocation = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Milk capacity slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'दूध क्षमता (लीटर/दिन)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${_milkRange.start.toInt()} - ${_milkRange.end.toInt()} L',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _milkRange,
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (values) => setState(() => _milkRange = values),
          ),

          // Price range slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'क़ीमत',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${_formatPrice(_priceRange.start)} - ${_formatPrice(_priceRange.end)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 600000,
            divisions: 30,
            activeColor: AppColors.primary,
            onChanged: (values) => setState(() => _priceRange = values),
          ),

          // Reset button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _selectedBreed = 'सभी नस्लें';
                _selectedLocation = 'सभी स्थान';
                _milkRange = const RangeValues(0, 20);
                _priceRange = const RangeValues(0, 600000);
              }),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('रीसेट करें'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}