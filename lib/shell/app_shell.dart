import 'dart:ui';

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

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isInLesson = false;
  bool _isTapTransition = false;
  int _tapTargetIndex = -1;

  late final AnimationController _tapSlideController;
  late final Animation<double> _tapSlideAnim;

  final List<ScrollController> _scrollControllers = List.generate(
    5,
    (_) => ScrollController(),
  );

  double _lastScrollOffset = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  late final List<NavigatorObserver> _navigatorObservers;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _tapSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _tapSlideAnim = CurvedAnimation(
      parent: _tapSlideController,
      curve: Curves.easeOutCubic,
    );

    _navigatorObservers = List.generate(
      5,
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
      TomyChatScreen(
        scrollController: _scrollControllers[4],
        onBack: () => _onTabSelected(3),
      ),
    ];

    _pageController.addListener(() {
      final newIndex = _pageController.page!.round();
      if (newIndex != _selectedIndex && !_isTapTransition) {
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
      if (_isInLesson) {
        setState(() => _isInLesson = false);
      }
    }
  }

  @override
  void dispose() {
    _tapSlideController.dispose();
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {}

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

  Future<void> _onTabSelected(int index) async {
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

    // Tap transition: slide up from bottom
    _isTapTransition = true;
    _tapTargetIndex = index;
    _tapSlideController.reset();

    // Run animation
    await _tapSlideController.forward();

    // Behind the scenes, jump PageView to target
    _setSelectedIndex(index);
    _pageController.jumpToPage(index);

    // Reset
    _tapSlideController.reset();
    _tapTargetIndex = -1;
    _isTapTransition = false;
  }

  void _showAddExpenseSheet() {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => const AddExpenseSheet(),
    );
  }

  bool _canPopShell() {
    final nav = _navigatorKeys[_selectedIndex].currentState;
    return nav == null || !nav.canPop();
  }

  void _onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) return;

    final nav = _navigatorKeys[_selectedIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final showChat = _selectedIndex == 4;

    return PopScope(
      canPop: _canPopShell(),
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: CupertinoPageScaffold(
        backgroundColor: AppColors.systemBackground,
        child: Stack(
          children: [
            // PageView for swipe navigation
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              children: List.generate(_screens.length, (index) {
                return _TabNavigator(
                  navigatorKey: _navigatorKeys[index],
                  screen: _screens[index],
                  observers: [_navigatorObservers[index]],
                );
              }),
            ),

            // Tap transition overlay: slide up from bottom
            if (_isTapTransition && _tapTargetIndex >= 0)
              AnimatedBuilder(
                animation: _tapSlideAnim,
                builder: (context, child) {
                  return Positioned.fill(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(_tapSlideAnim),
                      child: _TabNavigator(
                        navigatorKey: _navigatorKeys[_tapTargetIndex],
                        screen: _screens[_tapTargetIndex],
                        observers: [_navigatorObservers[_tapTargetIndex]],
                      ),
                    ),
                  );
                },
              ),

            if (!_isInLesson && !showChat) ...[
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

            if (_selectedIndex == 0 && !_isInLesson)
              Positioned(
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 70,
                child: FabButton(onTap: _showAddExpenseSheet),
              ),

            if (!_isInLesson && !showChat)
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
    final chromeH = topPadding + 66.0;

    return SizedBox(
      height: chromeH,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.frostedBlue,
                    AppColors.frostedBlue,
                    Color(0x00070D1A),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
        ],
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
      child: const HeaderRow(),
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
      onGenerateRoute: (_) => CupertinoPageRoute(builder: (_) => screen),
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
