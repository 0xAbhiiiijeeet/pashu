import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/cattle_listing_model.dart';

// ─── AppHeader ────────────────────────────────────────────────────────────────
class MarketplaceAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int postCount;
  final int maxPosts;

  const MarketplaceAppHeader({
    super.key,
    this.postCount = 1,
    this.maxPosts = 10,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleSpacing: 12,
      title: Row(
        children: [
          const Icon(Icons.pets, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'पशु बाज़ार',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'गाय भैंस वाला ऐप',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '$postCount/$maxPosts',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.golden,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

// ─── PromoBanner ─────────────────────────────────────────────────────────────
class PromoBanner extends StatelessWidget {
  final int liveCount;
  final VoidCallback? onTap;

  const PromoBanner({super.key, this.liveCount = 1459, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // VIP badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.golden),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.star, size: 14, color: AppColors.golden),
                      SizedBox(width: 4),
                      Text(
                        'VIP ख़रीदार',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.golden,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'नहीं बने',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE  $liveCount पशु बिकाऊ है',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '₹199 वाली सुविधा, ₹1 में',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'प्लान लें',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CattleListingCard ────────────────────────────────────────────────────────
class CattleListingCard extends StatelessWidget {
  final CattleListing listing;

  const CattleListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  listing.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              if (listing.isVerified)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '✓ Verified',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    listing.typeLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${_formatPrice(listing.priceMin)} - ₹${_formatPrice(listing.priceMax)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.water_drop, size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.milkCapacity} लीटर/दिन',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const Spacer(),
                    const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      listing.location,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    listing.breed,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toString();
  }
}

// ─── FeatureGridCard ──────────────────────────────────────────────────────────
class FeatureGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final bool isLocked;
  final VoidCallback? onTap;

  const FeatureGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Icon(icon, color: AppColors.primary, size: 32),
              ],
            ),
            if (isLocked)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.lock, size: 18, color: AppColors.golden),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── MyAnimalCard ─────────────────────────────────────────────────────────────
class MyAnimalCard extends StatelessWidget {
  final int buyerCount;
  final bool isIncomplete;

  const MyAnimalCard({
    super.key,
    this.buyerCount = 1459,
    this.isIncomplete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: SizedBox(
        width: 220,
        child: Padding(
          padding: const EdgeInsets.all(8), // Further reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isIncomplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Minimal padding
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4), // Smaller radius
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.remove_circle_outline, size: 10, color: Colors.red), // Smaller icon
                      SizedBox(width: 2), // Minimal spacing
                      Text(
                        'अधूरी जानकारी', // Even shorter text
                        style: TextStyle(fontSize: 9, color: Colors.red), // Smaller font
                      ),
                    ],
                  ),
                ),
              if (isIncomplete) const SizedBox(height: 4), // Minimal spacing
              Expanded( // Use Expanded instead of Flexible to take available space
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(Icons.pets, color: AppColors.primary, size: 24), // Smaller icon
                  ),
                ),
              ),
              const SizedBox(height: 4), // Minimal spacing
              Row(
                children: [
                  const Icon(Icons.circle, size: 5, color: AppColors.success), // Tiny icon
                  const SizedBox(width: 2), // Minimal spacing
                  Expanded(
                    child: Text(
                      '$buyerCount ख़रीदार', // Shortened text
                      style: const TextStyle(fontSize: 9, color: Colors.black54), // Smaller font
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Minimal spacing
              SizedBox(
                width: double.infinity,
                height: 28, // Fixed small height for button
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Smaller radius
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4), // Minimal padding
                  ),
                  child: const Text(
                    'जानकारी दें',
                    style: TextStyle(fontSize: 10), // Smaller font
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FilterChipRow ────────────────────────────────────────────────────────────
class FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = options[i];
          final isSelected = opt == selected;
          return ChoiceChip(
            label: Text(opt),
            selected: isSelected,
            onSelected: (_) => onSelected(opt),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}