import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Switch,
        Switcher,
        LinearProgressIndicator,
        Divider,
        Colors,
        Material,
        ReorderableListView,
        ReorderableDragStartListener,
        AnimatedBuilder;
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/cards.dart';
import '../widgets/savings_projection_card.dart';
import '../widgets/insights_layout_controller.dart';
import '../widgets/customize_sheet.dart';

class InsightsScreen extends StatefulWidget {
  final ScrollController scrollController;
  const InsightsScreen({super.key, required this.scrollController});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;
  late AnimationController _donutController;
  late Animation<double> _donutAnim;

  late final InsightsLayoutController _layoutController;

  @override
  void initState() {
    super.initState();

    _layoutController = InsightsLayoutController();
    _layoutController.load();

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

    _donutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _donutAnim = CurvedAnimation(
      parent: _donutController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _donutController.forward();
    });
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    _donutController.dispose();
    _layoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ChangeNotifierProvider.value(
      value: _layoutController,
      child: Stack(
        children: [
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Dynamic widget list ───────────────────────────
                      Consumer<InsightsLayoutController>(
                        builder: (context, controller, _) {
                          final configs = controller.visibleConfigs;

                          if (controller.isReorderMode) {
                            return Material(
                              color: Colors.transparent,
                              child: _buildReorderableList(controller, configs),
                            );
                          }

                          return Column(
                            children: [
                              for (final config in configs) ...[
                                _buildWidgetById(
                                  config.id,
                                  isReorderMode: false,
                                  controller: controller,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetById(
    InsightWidgetId id, {
    required bool isReorderMode,
    InsightsLayoutController? controller,
  }) {
    Widget widget;
    switch (id) {
      case InsightWidgetId.stats:
        widget = _buildStatsGrid();
      case InsightWidgetId.savingsChart:
        widget = const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SavingsProjectionCard(),
        );
      case InsightWidgetId.categories:
        widget = _buildCategoriesCard();
      case InsightWidgetId.origin:
        widget = _buildOriginCard();
      case InsightWidgetId.bank:
        widget = const BankPromoCard();
      case InsightWidgetId.predictions:
        widget = const _PredictionsCard();
    }

    if (isReorderMode) {
      return _WigglingWidget(child: widget);
    }

    return GestureDetector(
      onLongPress: () {
        controller?.toggleReorderMode();
      },
      child: widget,
    );
  }

  Widget _buildReorderableList(
    InsightsLayoutController controller,
    List<InsightWidgetConfig> configs,
  ) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double elevation = Tween<double>(
              begin: 0,
              end: 8,
            ).animate(animation).value;
            return Material(
              elevation: elevation,
              color: Colors.transparent,
              shadowColor: AppColors.systemBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              child: child,
            );
          },
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        controller.reorder(oldIndex, newIndex);
      },
      itemCount: configs.length,
      itemBuilder: (context, index) {
        final config = configs[index];
        return ReorderableDragStartListener(
          key: ValueKey(config.id),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: _WigglingWidget(
              showDragHandle: true,
              child: _buildWidgetById(config.id, isReorderMode: true),
            ),
          ),
        );
      },
    );
  }

  // ─── Existing widgets (unchanged logic) ─────────────────────────────────────

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'TOTAL GASTADO',
              amount: '\$1,250',
              decimals: '.00',
              trendIcon: CupertinoIcons.arrow_up_right,
              trendColor: AppColors.systemRed,
              trendText: '-5% vs mes ant.',
              glowColor: AppColors.systemBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'TOTAL AHORRADO',
              amount: '\$450',
              decimals: '.00',
              trendIcon: CupertinoIcons.arrow_up_right,
              trendColor: AppColors.systemGreen,
              trendText: '+12% meta',
              glowColor: AppColors.systemGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('ORIGEN DE GASTOS'),
              const SizedBox(height: 16),
              _OriginRow(
                icon: CupertinoIcons.money_dollar_circle_fill,
                iconColor: AppColors.systemBlue,
                label: 'Efectivo',
                amount: '\$320.00',
                progress: 0.35,
                progressColor: AppColors.systemBlue,
              ),
              const SizedBox(height: 16),
              _OriginRow(
                icon: CupertinoIcons.building_2_fill,
                iconColor: AppColors.systemIndigo,
                label: 'Banco',
                amount: '\$930.00',
                progress: 0.65,
                progressColor: AppColors.systemIndigo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionLabel('CATEGORÍAS AI'),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.blueTipBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.blueTipBorder,
                        width: 0.5,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        'SMART INSIGHTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.systemBlue,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: AnimatedBuilder(
                      animation: _donutAnim,
                      builder: (_, __) => CustomPaint(
                        painter: _DonutPainter(progress: _donutAnim.value),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Total',
                                style: AppTextStyles.caption1.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              const Text(
                                '100%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.label,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendRow(
                          color: AppColors.systemOrange,
                          label: 'Comida',
                          percent: '40%',
                        ),
                        SizedBox(height: 12),
                        _LegendRow(
                          color: AppColors.systemIndigo,
                          label: 'Ocio',
                          percent: '30%',
                        ),
                        SizedBox(height: 12),
                        _LegendRow(
                          color: AppColors.systemRed,
                          label: 'Transporte',
                          percent: '18%',
                        ),
                        SizedBox(height: 12),
                        _LegendRow(
                          color: AppColors.systemGreen,
                          label: 'Otros',
                          percent: '12%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── All existing private widgets below are identical to the original ─────────
// (PredictionsCard, BlueSegmentedToggle, MonthChip, SavingsDetails,
//  ExpensesDetails, StatCard, SectionLabel, OriginRow, LegendRow, DonutPainter)
// They are preserved exactly as-is from the original insights_screen.dart.
// Copy them here verbatim or keep them in a shared file and import them.

// ─── Predictions Card (unchanged) ────────────────────────────────────────────
enum _PredictionMode { savings, expenses }

class _PredictionsCard extends StatefulWidget {
  const _PredictionsCard();

  @override
  State<_PredictionsCard> createState() => _PredictionsCardState();
}

class _PredictionsCardState extends State<_PredictionsCard>
    with SingleTickerProviderStateMixin {
  _PredictionMode _mode = _PredictionMode.savings;

  late final AnimationController _crossfadeController;
  late final Animation<double> _crossfadeAnim;

  final PageController _pageController = PageController(
    viewportFraction: 0.38,
    initialPage: 1,
  );
  int _currentMonth = 1;

  static const _savingsMonths = [
    _MonthData(
      label: 'Mar',
      amount: '\$390',
      pct: 'Pasado',
      positive: true,
      isNeutral: true,
    ),
    _MonthData(
      label: 'Abr',
      amount: '\$520',
      pct: '+15%',
      positive: true,
      isNeutral: false,
    ),
    _MonthData(
      label: 'May',
      amount: '\$610',
      pct: '+17%',
      positive: true,
      isNeutral: false,
    ),
    _MonthData(
      label: 'Jun',
      amount: '\$680',
      pct: '+11%',
      positive: true,
      isNeutral: false,
    ),
    _MonthData(
      label: 'Jul',
      amount: '\$720',
      pct: '+6%',
      positive: true,
      isNeutral: false,
    ),
  ];

  static const _expensesMonths = [
    _MonthData(
      label: 'Mar',
      amount: '\$1,250',
      pct: 'Pasado',
      positive: true,
      isNeutral: true,
    ),
    _MonthData(
      label: 'Abr',
      amount: '\$1,305',
      pct: '+4%',
      positive: false,
      isNeutral: false,
    ),
    _MonthData(
      label: 'May',
      amount: '\$1,280',
      pct: '-2%',
      positive: true,
      isNeutral: false,
    ),
    _MonthData(
      label: 'Jun',
      amount: '\$1,340',
      pct: '+5%',
      positive: false,
      isNeutral: false,
    ),
    _MonthData(
      label: 'Jul',
      amount: '\$1,295',
      pct: '-3%',
      positive: true,
      isNeutral: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _crossfadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _crossfadeAnim = CurvedAnimation(
      parent: _crossfadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _crossfadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _switchMode(_PredictionMode mode) async {
    if (mode == _mode) return;
    await _crossfadeController.animateTo(
      0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeIn,
    );
    setState(() => _mode = mode);
    await _crossfadeController.animateTo(
      1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  List<_MonthData> get _months =>
      _mode == _PredictionMode.savings ? _savingsMonths : _expensesMonths;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionLabel('PREDICCIONES AI'),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.blueTipBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.blueTipBorder,
                        width: 0.5,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        'SMART INSIGHTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.systemBlue,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _BlueSegmentedToggle(selected: _mode, onChanged: _switchMode),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _crossfadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 90,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentMonth = i),
                        itemCount: _months.length,
                        itemBuilder: (context, i) {
                          final isSelected = i == _currentMonth;
                          return AnimatedScale(
                            scale: isSelected ? 1.0 : 0.88,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            child: AnimatedOpacity(
                              opacity: isSelected ? 1.0 : 0.45,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              child: _MonthChip(
                                data: _months[i],
                                isSelected: isSelected,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_months.length, (i) {
                        final active = i == _currentMonth;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 16 : 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.systemBlue
                                : AppColors.secondaryLabel.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _mode == _PredictionMode.savings
                          ? _SavingsDetails(
                              key: ValueKey('savings_$_currentMonth'),
                              selectedMonth: _currentMonth,
                            )
                          : _ExpensesDetails(
                              key: ValueKey('expenses_$_currentMonth'),
                              selectedMonth: _currentMonth,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlueSegmentedToggle extends StatelessWidget {
  final _PredictionMode selected;
  final ValueChanged<_PredictionMode> onChanged;

  const _BlueSegmentedToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.systemBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.systemBlue.withOpacity(0.18),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _BlueChip(
              label: 'Ahorro',
              active: selected == _PredictionMode.savings,
              onTap: () => onChanged(_PredictionMode.savings),
            ),
            _BlueChip(
              label: 'Gastos',
              active: selected == _PredictionMode.expenses,
              onTap: () => onChanged(_PredictionMode.expenses),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _BlueChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.systemBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? Colors.white : AppColors.systemBlue,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthData {
  final String label;
  final String amount;
  final String pct;
  final bool positive;
  final bool isNeutral;

  const _MonthData({
    required this.label,
    required this.amount,
    required this.pct,
    required this.positive,
    required this.isNeutral,
  });
}

class _MonthChip extends StatelessWidget {
  final _MonthData data;
  final bool isSelected;

  const _MonthChip({required this.data, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final pctColor = data.isNeutral
        ? AppColors.secondaryLabel
        : (data.positive ? AppColors.systemGreen : AppColors.systemRed);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.systemBlue.withOpacity(0.12)
              : AppColors.tertiaryFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.systemBlue.withOpacity(0.35)
                : AppColors.white07,
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? AppColors.systemBlue
                      : AppColors.secondaryLabel,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.systemBlue : AppColors.label,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.pct,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: pctColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavingsDetails extends StatelessWidget {
  final int selectedMonth;
  const _SavingsDetails({super.key, required this.selectedMonth});

  static const _insights = [
    'Mes anterior. Ahorraste \$390, un buen punto de partida.',
    'A este ritmo alcanzarás tu meta en 8 meses. Ahorrando \$50 más/mes podrías lograrlo en 6.',
    'Proyección positiva. Mayo podría ser tu mejor mes del trimestre.',
    'Ahorro consistente. Considera incrementar \$30 más este mes.',
    'Tendencia sólida. Julio marca el ritmo más alto del semestre.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Meta: Viaje 2024', style: AppTextStyles.caption1),
            Text(
              '\$2,000.00',
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.secondaryLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            value: 0.225,
            minHeight: 6,
            backgroundColor: AppColors.tertiaryFill,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.systemBlue),
          ),
        ),
        const SizedBox(height: 14),
        _InsightBox(
          text: _insights[selectedMonth.clamp(0, _insights.length - 1)],
        ),
      ],
    );
  }
}

class _ExpensesDetails extends StatelessWidget {
  final int selectedMonth;
  const _ExpensesDetails({super.key, required this.selectedMonth});

  static const _categories = [
    _CategoryData(
      color: AppColors.systemOrange,
      label: 'Comida',
      amount: '\$520',
      progress: 0.70,
      delta: '+8%',
      positive: false,
    ),
    _CategoryData(
      color: AppColors.systemIndigo,
      label: 'Ocio',
      amount: '\$390',
      progress: 0.50,
      delta: '-5%',
      positive: true,
    ),
    _CategoryData(
      color: AppColors.systemRed,
      label: 'Transporte',
      amount: '\$240',
      progress: 0.30,
      delta: '+3%',
      positive: false,
    ),
    _CategoryData(
      color: AppColors.systemGreen,
      label: 'Otros',
      amount: '\$155',
      progress: 0.18,
      delta: '-2%',
      positive: true,
    ),
  ];

  static const _insights = [
    'Mes anterior. Total gastado: \$1,250. Base de comparación.',
    'Se proyecta +4% en gastos totales. La categoría Comida es la de mayor riesgo.',
    'Leve mejora respecto a Abril. Ocio y Otros muestran tendencia positiva.',
    'Atención: Junio proyecta +5%. Revisar gastos de Comida y Transporte.',
    'Rebote a la baja en Julio. Buen control en categorías variables.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._categories.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CategoryRow(data: c),
          ),
        ),
        const Divider(color: AppColors.white07, thickness: 0.5, height: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total proyectado', style: AppTextStyles.caption1),
            const Text(
              '\$1,305',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.label,
                letterSpacing: -0.41,
                height: 1.29,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _InsightBox(
          text: _insights[selectedMonth.clamp(0, _insights.length - 1)],
        ),
      ],
    );
  }
}

class _CategoryData {
  final Color color;
  final String label;
  final String amount;
  final double progress;
  final String delta;
  final bool positive;

  const _CategoryData({
    required this.color,
    required this.label,
    required this.amount,
    required this.progress,
    required this.delta,
    required this.positive,
  });
}

class _CategoryRow extends StatelessWidget {
  final _CategoryData data;
  const _CategoryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final deltaColor = data.positive
        ? AppColors.systemGreen
        : AppColors.systemRed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: data.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.label,
                  letterSpacing: -0.08,
                  height: 1.38,
                ),
              ),
            ),
            Text(
              data.amount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.label,
                letterSpacing: -0.08,
                height: 1.38,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: Text(
                data.delta,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: deltaColor,
                  height: 1.38,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: data.progress,
            minHeight: 5,
            backgroundColor: AppColors.tertiaryFill,
            valueColor: AlwaysStoppedAnimation<Color>(data.color),
          ),
        ),
      ],
    );
  }
}

class _InsightBox extends StatelessWidget {
  final String text;
  const _InsightBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.blueTipBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blueTipBorder, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryLabel,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String amount;
  final String decimals;
  final IconData trendIcon;
  final Color trendColor;
  final String trendText;
  final Color glowColor;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.decimals,
    required this.trendIcon,
    required this.trendColor,
    required this.trendText,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white07),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.secondaryLabel,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: AppColors.label,
                    height: 1.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    decimals,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryLabel,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(trendIcon, size: 12, color: trendColor),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    trendText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trendColor,
                      letterSpacing: -0.1,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.secondaryLabel,
        height: 1.33,
      ),
    );
  }
}

class _OriginRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final double progress;
  final Color progressColor;

  const _OriginRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(icon, color: iconColor, size: 17),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.24,
                  color: AppColors.label,
                  height: 1.33,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.24,
                color: AppColors.label,
                height: 1.33,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.tertiaryFill,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String percent;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryLabel,
              letterSpacing: -0.08,
              height: 1.38,
            ),
          ),
        ),
        Text(
          percent,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.label,
            letterSpacing: -0.08,
            height: 1.38,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;

  static const _segments = [
    (0.40, AppColors.systemOrange),
    (0.30, AppColors.systemIndigo),
    (0.18, AppColors.systemRed),
    (0.12, AppColors.systemGreen),
  ];

  static const _strokeWidth = 10.0;
  static const _gap = 0.025;

  const _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..color = AppColors.tertiaryFill,
    );

    double startAngle = -math.pi / 2;
    for (final (fraction, color) in _segments) {
      final sweep = (fraction * math.pi * 2 - _gap).clamp(0.0, math.pi * 2);
      canvas.drawArc(
        rect,
        startAngle,
        sweep * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..color = color,
      );
      startAngle += sweep + _gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}

class _WigglingWidget extends StatefulWidget {
  final Widget child;
  final bool showDragHandle;

  const _WigglingWidget({required this.child, this.showDragHandle = false});

  @override
  State<_WigglingWidget> createState() => _WigglingWidgetState();
}

class _WigglingWidgetState extends State<_WigglingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wiggleAnimation,
      builder: (context, child) {
        return Transform.rotate(angle: _wiggleAnimation.value, child: child);
      },
      child: widget.child,
    );
  }
}
