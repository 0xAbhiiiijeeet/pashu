import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'buy_cattle_screen.dart';
import 'sell_cattle_screen.dart';

class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  bool _showVipSheet = false;

  void _toggleVipSheet() => setState(() => _showVipSheet = !_showVipSheet);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Promo Banner
            PromoBanner(
              liveCount: 1459,
              onTap: _toggleVipSheet,
            ),

              // Buy / Sell cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'पशु ख़रीदें',
                        subtitle: '474+ नए पशु',
                        color: AppColors.primary,
                        icon: Icons.shopping_cart_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BuyCattleScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _ActionCard(
                            title: 'पशु बेचें',
                            subtitle: '1459+ ख़रीददार',
                            color: AppColors.sage,
                            icon: Icons.storefront_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SellCattleScreen(),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: -8,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.golden,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'फ्री पशु दर्ज',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Feature grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  children: const [
                    FeatureGridCard(
                      title: 'रेट जानें',
                      subtitle: 'पशु का सही रेट',
                      icon: Icons.calculate_outlined,
                      bgColor: AppColors.mintGreen,
                    ),
                    FeatureGridCard(
                      title: 'दूध बढ़ाये',
                      subtitle: 'योजना बनाएँ',
                      icon: Icons.water_drop_outlined,
                      bgColor: AppColors.mintGreen,
                    ),
                    FeatureGridCard(
                      title: 'पशु उस्ताद',
                      subtitle: 'सलाह लें',
                      icon: Icons.support_agent_outlined,
                      bgColor: AppColors.mintGreen,
                      isLocked: true,
                    ),
                  ],
                ),
              ),

              // My Animals section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'मेरे पशु',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'सब देखें >',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180, // Further reduced to match optimized card content
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: const [
                    MyAnimalCard(buyerCount: 1459, isIncomplete: true),
                    SizedBox(width: 10),
                    MyAnimalCard(buyerCount: 832, isIncomplete: false),
                  ],
                ),
              ),
            ],
          ),

          // VIP Paywall overlay
          if (_showVipSheet)
            GestureDetector(
              onTap: _toggleVipSheet,
              child: Container(color: Colors.black45),
            ),
          if (_showVipSheet)
            Align(
              alignment: Alignment.bottomCenter,
              child: VipPaywallSheet(onClose: _toggleVipSheet),
            ),
        ],
      );
    }
  }

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Icon(icon, color: Colors.white70, size: 36),
          ],
        ),
      ),
    );
  }
}

// ─── VipPaywallSheet ──────────────────────────────────────────────────────────
class VipPaywallSheet extends StatelessWidget {
  final VoidCallback? onClose;

  const VipPaywallSheet({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              const Expanded(
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'ये सिर्फ़ ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'VIP ख़रीदारों',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' के लिए है',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'एक्सपर्ट से पाएं आसान समाधान',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.close, size: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // VIP Plan card
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    const Icon(Icons.radio_button_checked, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'सलाह लें ',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        TextSpan(
                          text: 'एक्सपर्ट से',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'साथ में:',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _BenefitRow('3-5 हज़ार ज़्यादा मुनाफ़े वाले सौदे'),
                          _BenefitRow('कोई ऐड नहीं'),
                          _BenefitRow('फिर ₹199/महिना'),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          '₹1',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '1 दिन का ट्रायल',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 14, color: AppColors.golden),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'हर महीने ऑटोपेमेंट। कभी भी कैंसल करें',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'प्लान लें  ₹1',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.success),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}