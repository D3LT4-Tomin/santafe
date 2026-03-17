import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/aprender_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/pagos_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/buttons.dart';
import '../widgets/tab_bar.dart';

// ─── App Shell ────────────────────────────────────────────────────────────────
// Owns the bottom tab bar and FAB. Each tab body is kept alive via IndexedStack
// so scroll position and animation state persist when switching tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // One navigator key per tab so each tab has its own navigation stack.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  // The four tab bodies — order matches AppTabBar tabs.
  late final List<Widget> _screens = [
    const DashboardScreen(),
    const InsightsScreen(),
    const PagosScreen(),
    const AprenderScreen(),
  ];

  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();

    // Tapping the active tab pops to its root (like iOS behaviour).
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _showAddExpenseSheet() {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => const AddExpenseSheet(),
    );
  }

  // Handle Android back button — pop within the active tab's stack first.
  Future<bool> _onWillPop() async {
    final nav = _navigatorKeys[_selectedIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: CupertinoPageScaffold(
        backgroundColor: AppColors.systemBackground,
        child: Stack(
          children: [
            // ── Tab bodies (all kept in tree, only active one is visible) ──
            IndexedStack(
              index: _selectedIndex,
              children: _screens.map((screen) => _TabNavigator(screen: screen)).toList(),
            ),

            // ── FAB (above tab bar, below nothing) ────────────────────────
            Positioned(
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 70,
              child: FabButton(onTap: _showAddExpenseSheet),
            ),

            // ── Tab bar ───────────────────────────────────────────────────
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: RepaintBoundary(
                child: AppTabBar(
                  selectedIndex: _selectedIndex,
                  onTabSelected: _onTabSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Per-tab Navigator wrapper ────────────────────────────────────────────────
// Each tab gets its own Navigator so tabs can push routes independently.
class _TabNavigator extends StatelessWidget {
  final Widget screen;
  const _TabNavigator({required this.screen});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => CupertinoPageRoute(builder: (_) => screen),
    );
  }
}
