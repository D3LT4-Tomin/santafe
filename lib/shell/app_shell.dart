import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/cuenta_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/aprender_screen.dart';
import '../screens/tomy_chat_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/buttons.dart';
import '../widgets/header_row.dart';
import '../widgets/tab_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isInLesson = false;
  bool _isChatMode = false; // New variable to track chat overlay mode

  final List<ScrollController> _scrollControllers = List.generate(
    4,
    (_) => ScrollController(),
  );

  final _searchBarOpacity = ValueNotifier<double>(1.0);
  double _lastScrollOffset = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  late final List<NavigatorObserver> _navigatorObservers;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _navigatorObservers = List.generate(
      4,
      (index) => _ShellNavigatorObserver(() {
        if (index == _selectedIndex) {
          _updateLessonState();
        }
      }),
    );

    _screens = [
      DashboardScreen(scrollController: _scrollControllers[0]),
      InsightsScreen(scrollController: _scrollControllers[1]),
      CuentaScreen(scrollController: _scrollControllers[2]),
      AprenderScreen(scrollController: _scrollControllers[3]),
    ];

    _pageController.addListener(() {
      final newIndex = _pageController.page!.round();
      if (newIndex != _selectedIndex) {
        _setSelectedIndex(newIndex);
      }
    });

    _scrollControllers[_selectedIndex].addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLessonState();
    });
  }

  void _updateLessonState() {
    final key = _navigatorKeys[_selectedIndex];
    final nav = key.currentState;
    if (nav != null) {
      final inLesson = nav.canPop();
      if (inLesson != _isInLesson) {
        setState(() => _isInLesson = inLesson);
      }
    } else {
      // If navigator is not yet built, assume not in lesson
      if (_isInLesson) {
        setState(() => _isInLesson = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _searchBarOpacity.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = _scrollControllers[_selectedIndex];
    final offset = controller.offset;
    _lastScrollOffset = offset;
  }

  void _setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _scrollControllers[_selectedIndex].removeListener(_onScroll);

      setState(() {
        _selectedIndex = index;
        _lastScrollOffset = 0;
      });

      _scrollControllers[_selectedIndex].addListener(_onScroll);
      _updateLessonState();
    }
  }

  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();

    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);

      if (_scrollControllers[index].hasClients) {
        _scrollControllers[index].animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    _setSelectedIndex(index);
    _pageController.jumpToPage(index);
  }

  void _showAddExpenseSheet() {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => const AddExpenseSheet(),
    );
  }

  void _showSearchChat() {
    HapticFeedback.mediumImpact();
    // Open chat overlay directly without going through a tab
    setState(() {
      _isChatMode = true;
    });
  }

  bool _canPopShell() {
    final nav = _navigatorKeys[_selectedIndex].currentState;
    return nav == null || !nav.canPop();
  }

  void _onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) return;

    if (_isChatMode) {
      setState(() => _isChatMode = false);
      return;
    }

    final nav = _navigatorKeys[_selectedIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: _canPopShell(),
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: CupertinoPageScaffold(
        backgroundColor: AppColors.systemBackground,
        child: Stack(
          children: [
            // Scale down and dim the main content when chat mode is active
            AnimatedScale(
              scale: _isChatMode ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _isChatMode ? 0.3 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: PageView(
                  controller: _pageController,
                  children: List.generate(_screens.length, (index) {
                    return _TabNavigator(
                      navigatorKey: _navigatorKeys[index],
                      screen: _screens[index],
                      observers: [_navigatorObservers[index]],
                    );
                  }),
                ),
              ),
            ),

            // Dark backdrop overlay for chat
            if (_isChatMode)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: 0.4,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  child: GestureDetector(
                    onTap: () => setState(() => _isChatMode = false),
                    child: Container(color: Colors.black),
                  ),
                ),
              ),

            // Chat overlay when search bar is pressed (transparent background)
            if (_isChatMode)
              Positioned.fill(
                child: TomyChatScreen(
                  scrollController: _scrollControllers[3],
                  onBack: () => setState(() => _isChatMode = false),
                  isOverlay: true, // This will make it transparent
                ),
              ),

            if (!_isInLesson && !_isChatMode) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(child: _buildHeaderChrome(topPadding)),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildFixedHeader(topPadding),
              ),
            ],

            // Only show FAB on home tab (index 0)
            if (_selectedIndex == 0 && !_isInLesson && !_isChatMode)
              Positioned(
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 70,
                child: FabButton(onTap: _showAddExpenseSheet),
              ),

            if (!_isInLesson && !_isChatMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
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

  Widget _buildHeaderChrome(double topPadding) {
    return SizedBox(
      height: topPadding + 66.0,
      child: Container(
        decoration: const BoxDecoration(color: AppColors.frostedGreen),
      ),
    );
  }

  Widget _buildFixedHeader(double topPadding) {
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 10,
        bottom: 20,
        left: 16,
        right: 8,
      ),
      child: HeaderRow(
        searchBarOpacity: _searchBarOpacity,
        onSearchPressed: _showSearchChat,
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget screen;
  final List<NavigatorObserver> observers;

  const _TabNavigator({
    required this.navigatorKey,
    required this.screen,
    this.observers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: observers,
      onGenerateRoute: (settings) {
        if (screen is TomyChatScreen) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => screen,
            transitionsBuilder: (_, animation, __, child) => child,
          );
        }
        return CupertinoPageRoute(builder: (_) => screen, settings: settings);
      },
    );
  }
}

class _ShellNavigatorObserver extends NavigatorObserver {
  final VoidCallback onNavigation;

  _ShellNavigatorObserver(this.onNavigation);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onNavigation();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onNavigation();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onNavigation();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onNavigation();
  }
}
