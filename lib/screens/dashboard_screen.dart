import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../models/expense_data.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards.dart';
import '../widgets/expense_widgets.dart';
import '../widgets/filter_sheet.dart';

class DashboardScreen extends StatefulWidget {
  final ScrollController scrollController;
  const DashboardScreen({super.key, required this.scrollController});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  bool _showMoreExpenses = false;
  FilterSelection _filterSelection = const FilterSelection();

  final List<String> _filterCategories = List.from(kFilterCategories);

  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  @override
  void initState() {
    super.initState();

    _blob1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _blob2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    _blob1Anim = CurvedAnimation(
      parent: _blob1Controller,
      curve: Curves.easeInOut,
    );
    _blob2Anim = CurvedAnimation(
      parent: _blob2Controller,
      curve: Curves.easeInOut,
    );

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _appearController.forward();
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        if (dataProvider.isLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return Stack(
          children: [
            RepaintBoundary(
              child: AnimatedBlobs(
                blob1Anim: _blob1Anim,
                blob2Anim: _blob2Anim,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: topPadding + 76, bottom: 80),
                child: FadeTransition(
                  opacity: _appearAnim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(_appearAnim),
                    child: Column(
                      children: [
                        const BalanceCard(),
                        const SizedBox(height: 16),
                        const TipCard(),
                        const SizedBox(height: 28),
                        _buildRecentExpenses(dataProvider.transactions),
                        const SizedBox(height: 28),
                        const WeeklySummaryCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentExpenses(List<TransactionModel> transactions) {
    final filtered = transactions
        .where((t) => _filterSelection.matches(t.category, t.origin, t.tipo))
        .toList();
    const initialCount = 5;
    final showingAll = _showMoreExpenses || filtered.length <= initialCount;
    final visibleExpenses = showingAll
        ? filtered
        : filtered.take(initialCount).toList();
    final hasMore = filtered.length > initialCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'MOVIMIENTOS RECIENTES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.secondaryLabel,
                    height: 1.33,
                  ),
                ),
              ),
              FilterButton(
                selection: _filterSelection,
                categories: _filterCategories,
                origins: kFilterOrigins,
                tipos: kFilterTipos,
                onApply: (sel) => setState(() {
                  _filterSelection = sel;
                  _showMoreExpenses = false;
                }),
              ),
            ],
          ),
        ),
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
                        for (final transaction in visibleExpenses)
                          ExpenseRow(transaction: transaction),
                        if (hasMore)
                          ShowMoreButton(
                            expanded: _showMoreExpenses,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(
                                () => _showMoreExpenses = !_showMoreExpenses,
                              );
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
    final hasFilters = !_filterSelection.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.tray,
            color: AppColors.tertiaryLabel,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            hasFilters
                ? 'Sin movimientos con los filtros seleccionados'
                : 'Sin movimientos',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryLabel,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() {
                _filterSelection = const FilterSelection();
                _showMoreExpenses = false;
              }),
              child: const Text(
                'Limpiar filtros',
                style: TextStyle(fontSize: 13, color: AppColors.systemBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
