import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

// ─── Tab Bar ──────────────────────────────────────────────────────────────────
class AppTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const AppTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.frostedGreen85,
        border: Border(top: BorderSide(color: AppColors.white10, width: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        child: Row(
          children: [
            TabItem(
              icon: CupertinoIcons.house_fill,
              label: 'Inicio',
              index: 0,
              selectedIndex: selectedIndex,
              onTap: onTabSelected,
            ),
            TabItem(
              icon: CupertinoIcons.chart_bar_fill,
              label: 'Insights',
              index: 1,
              selectedIndex: selectedIndex,
              onTap: onTabSelected,
            ),
            TabItem(
              icon: CupertinoIcons.creditcard_fill,
              label: 'Cuenta',
              index: 2,
              selectedIndex: selectedIndex,
              onTap: onTabSelected,
            ),
            TabItem(
              icon: CupertinoIcons.book_fill,
              label: 'Aprender',
              index: 3,
              selectedIndex: selectedIndex,
              onTap: onTabSelected,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Item ─────────────────────────────────────────────────────────────────
class TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const TabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    final color = selected ? AppColors.systemGreen : AppColors.secondaryLabel;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: SizedBox(
          height: 49,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
