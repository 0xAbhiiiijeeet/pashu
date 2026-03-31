import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/selling_section.dart';

class SellCattleScreen extends StatelessWidget {
  const SellCattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: _SellCattleAppBar(),
      body: SellingSection(),
    );
  }
}

class _SellCattleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SellCattleAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text(
        'पशु बेचें',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
