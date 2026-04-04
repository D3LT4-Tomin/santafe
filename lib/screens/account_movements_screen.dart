import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/expense_data.dart';
import '../models/transaction_model.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/expense_widgets.dart';

class AccountMovementsScreen extends StatefulWidget {
  final String originName;
  const AccountMovementsScreen({super.key, required this.originName});

  @override
  State<AccountMovementsScreen> createState() => _AccountMovementsScreenState();
}

class _AccountMovementsScreenState extends State<AccountMovementsScreen>
    with TickerProviderStateMixin {
  bool _showMoreExpenses = false;
  String _selectedCategory = 'Todos';

  late PageController _pillPageController;
  int _pillPage = 0;

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

    _pillPageController = PageController();
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    _pillPageController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filteredTransactions(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((t) {
      bool originMatch = false;
      if (widget.originName.contains('BBVA') ||
          widget.originName.contains('Scotiabank')) {
        originMatch =
            t.origin.contains('Tarjeta') || t.origin.contains('Transferencia');
      } else if (widget.originName.contains('Cartera') ||
          widget.originName.contains('colchón')) {
        originMatch = t.origin == 'Efectivo';
      } else {
        originMatch = true; // For others
      }

      if (_selectedCategory == 'Todos') return originMatch;
      return originMatch && t.category == _selectedCategory;
    }).toList();
  }

  void _showAddCategorySheet() {
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.originName,
          style: const TextStyle(color: AppColors.label),
        ),
        backgroundColor: AppColors.frostedBlue.withValues(alpha: 0.5),
        border: null,
      ),
      child: Stack(
        children: [
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
          ),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                child: FadeTransition(
                  opacity: _appearAnim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(_appearAnim),
                    child: _buildMovementsPanel(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsPanel() {
    final transactions = context.watch<DataProvider>().transactions;
    final filtered = _filteredTransactions(transactions);
    const initialCount = 10;
    final showingAll = _showMoreExpenses || filtered.length <= initialCount;
    final visibleExpenses = showingAll
        ? filtered
        : filtered.take(initialCount).toList();
    final hasMore = filtered.length > initialCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'MOVIMIENTOS',
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
          categories: kFilterCategories,
          selectedFilter: _selectedCategory,
          pageController: _pillPageController,
          currentPage: _pillPage,
          onPageChanged: (p) => setState(() => _pillPage = p),
          onFilterSelected: (cat) {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedCategory = cat;
              _showMoreExpenses = false;
            });
          },
          onAddCategory: _showAddCategorySheet,
        ),
        const SizedBox(height: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.tray,
            color: AppColors.tertiaryLabel,
            size: 32,
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _selectedCategory == 'Todos'
                  ? 'Sin movimientos'
                  : 'Sin movimientos en "$_selectedCategory"',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryLabel,
                letterSpacing: -0.1,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
