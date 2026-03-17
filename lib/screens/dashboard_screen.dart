import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/expense_data.dart';
import '../theme/app_theme.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards.dart';
import '../widgets/expense_widgets.dart';
import '../widgets/header_row.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  bool _showMoreExpenses = false;
  String _selectedFilter = 'Todos';

  final List<String> _filterCategories = List.from(kFilterCategories);
  late PageController _pillPageController;
  int _pillPage = 0;

  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  final ScrollController _scrollController = ScrollController();
  final _searchBarOpacity = ValueNotifier<double>(1.0);
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _blob1Controller = AnimationController(
      vsync: this, duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _blob2Controller = AnimationController(
      vsync: this, duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    _blob1Anim = CurvedAnimation(parent: _blob1Controller, curve: Curves.easeInOut);
    _blob2Anim = CurvedAnimation(parent: _blob2Controller, curve: Curves.easeInOut);

    _appearController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _appearController.forward();

    _scrollController.addListener(_onScroll);
    _pillPageController = PageController();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final delta  = offset - _lastScrollOffset;
    _lastScrollOffset = offset;

    if (offset < 20) {
      if (_searchBarOpacity.value != 1.0) _searchBarOpacity.value = 1.0;
    } else if (delta > 2 && _searchBarOpacity.value == 1.0) {
      _searchBarOpacity.value = 0.0;
    }
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchBarOpacity.dispose();
    _pillPageController.dispose();
    super.dispose();
  }

  List<ExpenseData> get _filteredExpenses {
    if (_selectedFilter == 'Todos') return kAllExpenses;
    return kAllExpenses.where((e) => e.category == _selectedFilter).toList();
  }

  void _showAddCategorySheet() {
    HapticFeedback.mediumImpact();
    final controller = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, _) => Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x4D8E8E93),
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: SizedBox(width: 36, height: 5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar',
                          style: TextStyle(color: AppColors.systemBlue)),
                    ),
                    const Text('Nueva Categoria', style: AppTextStyles.headline),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        Navigator.pop(ctx);
                        setState(() {
                          if (!_filterCategories.contains(name)) {
                            _filterCategories.add(name);
                          }
                          _selectedFilter = name;
                          _showMoreExpenses = false;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _pillPageController.animateToPage(
                              999,
                              duration: const Duration(milliseconds: 380),
                              curve: Curves.easeOutCubic,
                            );
                          });
                        });
                      },
                      child: const Text('Listo',
                          style: TextStyle(
                            color: AppColors.systemBlue,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ),
              ),
              const ColoredBox(
                color: AppColors.separator,
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CupertinoTextField(
                  controller: controller,
                  autofocus: true,
                  placeholder: 'Nombre de categoria',
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.tertiaryBackground,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  style: AppTextStyles.body,
                  placeholderStyle: const TextStyle(
                    fontSize: 17,
                    color: AppColors.secondaryLabel,
                    letterSpacing: -0.41,
                    height: 1.29,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      child: Stack(
        children: [
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: topPadding + 80, bottom: 120),
              child: FadeTransition(
                opacity: _appearAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04), end: Offset.zero,
                  ).animate(_appearAnim),
                  child: Column(
                    children: [
                      const BalanceCard(),
                      const SizedBox(height: 16),
                      const BankPromoCard(),
                      const SizedBox(height: 28),
                      const TipCard(),
                      const SizedBox(height: 28),
                      _buildRecentExpenses(),
                      const SizedBox(height: 28),
                      const WeeklySummaryCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: IgnorePointer(child: _buildHeaderChrome(topPadding)),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildFixedHeader(topPadding),
          ),
        ],
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
                  stops: [0.0, 1.0, 1.0],
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
        top: topPadding + 10, bottom: 20, left: 16, right: 8,
      ),
      child: HeaderRow(searchBarOpacity: _searchBarOpacity),
    );
  }

  Widget _buildRecentExpenses() {
    final filtered = _filteredExpenses;
    const initialCount = 5;
    final showingAll = _showMoreExpenses || filtered.length <= initialCount;
    final visibleExpenses = showingAll ? filtered : filtered.take(initialCount).toList();
    final hasMore = filtered.length > initialCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'GASTOS RECIENTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.secondaryLabel,
              height: 1.33,
            ),
          ),
        ),
        PillPager(
          categories: _filterCategories,
          selectedFilter: _selectedFilter,
          pageController: _pillPageController,
          currentPage: _pillPage,
          onPageChanged: (p) => setState(() => _pillPage = p),
          onFilterSelected: (cat) {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedFilter = cat;
              _showMoreExpenses = false;
            });
          },
          onAddCategory: _showAddCategorySheet,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white05,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.white07),
              ),
              child: visibleExpenses.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        for (final data in visibleExpenses)
                          ExpenseRow(data: data),
                        if (hasMore)
                          ShowMoreButton(
                            expanded: _showMoreExpenses,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _showMoreExpenses = !_showMoreExpenses);
                            },
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(CupertinoIcons.tray, color: AppColors.tertiaryLabel, size: 32),
          const SizedBox(height: 10),
          Text(
            'Sin gastos en "$_selectedFilter"',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryLabel,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
