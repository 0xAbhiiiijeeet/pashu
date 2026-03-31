import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/buying_section.dart';

class BuyCattleScreen extends StatefulWidget {
  const BuyCattleScreen({super.key});

  @override
  State<BuyCattleScreen> createState() => _BuyCattleScreenState();
}

class _BuyCattleScreenState extends State<BuyCattleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchApprovedSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: _BuyCattleAppBar(),
      body: BuyingSection(),
    );
  }
}

class _BuyCattleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _BuyCattleAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text(
        'पशु खरीदें',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
