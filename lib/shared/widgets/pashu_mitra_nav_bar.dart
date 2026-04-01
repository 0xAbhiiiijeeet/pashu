import 'package:flutter/material.dart';

class PashuMitraNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PashuMitraNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Tab
          _NavBarItem(
            isSelected: currentIndex == 0,
              onTap: () => onTap(0),
              child: currentIndex == 0
                ? Image.asset(
                    'assets/images/pashu_mitra_dark.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  )
                : ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF979797),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/pashu_mitra_dark.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),

          // Posts/Feed Tab
          _NavBarItem(
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
            child: Image.asset(
              'assets/icons/ques-ans.png',
              width: 28,
              height: 28,
              color: currentIndex == 1 ? const Color(0xFF666B42) : const Color(0xFF979797),
            ),
          ),

          // पशु बाज़ार Tab
          _NavBarItem(
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
            child: Icon(
              Icons.store,
              size: 28,
              color: currentIndex == 2 ? const Color(0xFF666B42) : const Color(0xFF979797),
            ),
          ),

          // Bookings Tab
          _NavBarItem(
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
            child: Image.asset(
              'assets/icons/my bookings.png',
              width: 28,
              height: 28,
              color: currentIndex == 3 ? const Color(0xFF666B42) : const Color(0xFF979797),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _NavBarItem({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: child,
      ),
    );
  }
}
