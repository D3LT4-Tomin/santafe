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
        AnimatedBuilder,
        Localizations,
        DefaultWidgetsLocalizations,
        DefaultMaterialLocalizations;
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/cards.dart';
import '../widgets/savings_projection_card.dart';
import '../widgets/insights_layout_controller.dart';

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

  // ── Add-widget bottom sheet ─────────────────────────────────────────────────

  void _showAddWidgetSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: _layoutController,
        child: const _AddWidgetSheet(),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ChangeNotifierProvider.value(
      value: _layoutController,
      child: Stack(
        children: [
          // ── Background blobs ──────────────────────────────────────────────
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          // GestureDetector wraps the scroll view: taps on empty background
          // exit reorder mode; card/badge taps are absorbed by their own
          // GestureDetectors first and never reach this handler.
          Positioned.fill(
            child: Consumer<InsightsLayoutController>(
              builder: (_, controller, _) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: controller.isReorderMode
                      ? controller.exitReorderMode
                      : null,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: topPadding + 76, bottom: 120),
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
                            // ── Dynamic widget list ─────────────────────────────
                            Consumer<InsightsLayoutController>(
                              builder: (context, controller, _) {
                                final configs = controller.visibleConfigs;

                                if (controller.isReorderMode) {
                                  return Localizations(
                                    locale: const Locale('en'),
                                    delegates: const [
                                      DefaultWidgetsLocalizations.delegate,
                                      DefaultMaterialLocalizations.delegate,
                                    ],
                                    child: Material(
                                      color: Colors.transparent,
                                      child: _buildReorderableList(
                                        controller,
                                        configs,
                                      ),
                                    ),
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

                            // ── Add widgets button — same horizontal margins as cards ─
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: _ScalingButton(
                                listenTo: _layoutController,
                                onPressed: _showAddWidgetSheet,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── "Done" pill (floats above content in reorder mode) ────────────
          Consumer<InsightsLayoutController>(
            builder: (_, controller, _) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: controller.isReorderMode ? 100 : -60,
                left: 0,
                right: 0,
                child: Center(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: controller.exitReorderMode,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.systemBlue,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.systemBlue.withValues(alpha: 0.35),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        child: Text(
                          'Listo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.33,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Widget builder ──────────────────────────────────────────────────────────

  Widget _buildWidgetById(
    InsightWidgetId id, {
    required bool isReorderMode,
    InsightsLayoutController? controller,
  }) {
    Widget child;
    switch (id) {
      case InsightWidgetId.stats:
        child = _buildStatsGrid();
      case InsightWidgetId.savingsChart:
        child = const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SavingsProjectionCard(),
        );
      case InsightWidgetId.categoriesGastos:
        child = _buildGastosCard();
      case InsightWidgetId.categoriesIngresos:
        child = _buildIngresosCard();
      case InsightWidgetId.origin:
        child = _buildOriginCard();
      case InsightWidgetId.bank:
        child = const BankPromoCard();
      case InsightWidgetId.predictions:
        child = const _PredictionsCard();
    }

    if (isReorderMode) {
      return _WigglingWidget(child: child);
    }

    // Normal mode — long-press enters reorder mode. No color tint.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => controller?.toggleReorderMode(),
      child: child,
    );
  }

  // ── Reorderable list ────────────────────────────────────────────────────────

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
            final elevation = Tween<double>(
              begin: 0,
              end: 8,
            ).animate(animation).value;
            return Material(
              elevation: elevation,
              color: Colors.transparent,
              shadowColor: AppColors.systemBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              child: child,
            );
          },
          child: child,
        );
      },
      onReorder: controller.reorder,
      itemCount: configs.length,
      itemBuilder: (context, index) {
        final config = configs[index];
        return _ReorderableItem(
          key: ValueKey(config.id),
          index: index,
          onDelete: () => controller.remove(config.id),
          child: _buildWidgetById(config.id, isReorderMode: true),
        );
      },
    );
  }

  // ─── Stat grid & cards (unchanged logic) ────────────────────────────────────

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

  Widget _buildGastosCard() {
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
                children: [
                  const Expanded(child: _SectionLabel('CATEGORÍAS GASTOS')),
                  const SizedBox(width: 8),
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
                      builder: (_, _) => CustomPaint(
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

  Widget _buildIngresosCard() {
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
                children: [
                  const Expanded(child: _SectionLabel('CATEGORÍAS INGRESOS')),
                  const SizedBox(width: 8),
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
                      builder: (_, _) => CustomPaint(
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
                          color: AppColors.systemGreen,
                          label: 'Salario',
                          percent: '70%',
                        ),
                        SizedBox(height: 12),
                        _LegendRow(
                          color: AppColors.systemBlue,
                          label: 'Inversiones',
                          percent: '20%',
                        ),
                        SizedBox(height: 12),
                        _LegendRow(
                          color: AppColors.systemPurple,
                          label: 'Otros',
                          percent: '10%',
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

// ─── Reorderable item wrapper ─────────────────────────────────────────────────
// Owns the drag handle (invisible — full widget is draggable) + delete badge.

class _ReorderableItem extends StatelessWidget {
  final int index;
  final VoidCallback onDelete;
  final Widget child;

  const _ReorderableItem({
    super.key,
    required this.index,
    required this.onDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // No horizontal padding here — every card carries its own Padding(horizontal:16).
    // We only add bottom spacing between items.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ReorderableDragStartListener(index: index, child: child),

          // ── Delete badge — small, flush to top-right corner of card ─────
          Positioned(
            top: -8,
            right:
                10, // aligns with the card's inner right edge (16px card pad − 6px)
            child: GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.systemRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: Icon(
                    CupertinoIcons.minus,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add-widget sheet ─────────────────────────────────────────────────────────

class _AddWidgetSheet extends StatelessWidget {
  const _AddWidgetSheet();

  static String _labelFor(InsightWidgetId id) => switch (id) {
    InsightWidgetId.stats => 'Resumen del mes',
    InsightWidgetId.savingsChart => 'Gráfica de ahorro',
    InsightWidgetId.categoriesGastos => 'Categorías Gastos',
    InsightWidgetId.categoriesIngresos => 'Categorías Ingresos',
    InsightWidgetId.origin => 'Origen de gastos',
    InsightWidgetId.bank => 'Promo banco',
    InsightWidgetId.predictions => 'Predicciones AI',
  };

  static IconData _iconFor(InsightWidgetId id) => switch (id) {
    InsightWidgetId.stats => CupertinoIcons.chart_bar_square,
    InsightWidgetId.savingsChart => CupertinoIcons.graph_square,
    InsightWidgetId.categoriesGastos => CupertinoIcons.tag_fill,
    InsightWidgetId.categoriesIngresos =>
      CupertinoIcons.money_dollar_circle_fill,
    InsightWidgetId.origin => CupertinoIcons.building_2_fill,
    InsightWidgetId.bank => CupertinoIcons.creditcard_fill,
    InsightWidgetId.predictions => CupertinoIcons.sparkles,
  };

  static Color _colorFor(InsightWidgetId id) => switch (id) {
    InsightWidgetId.stats => AppColors.systemBlue,
    InsightWidgetId.savingsChart => AppColors.systemGreen,
    InsightWidgetId.categoriesGastos => AppColors.systemOrange,
    InsightWidgetId.categoriesIngresos => AppColors.systemGreen,
    InsightWidgetId.origin => AppColors.systemIndigo,
    InsightWidgetId.bank => AppColors.systemRed,
    InsightWidgetId.predictions => AppColors.systemBlue,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightsLayoutController>(
      builder: (_, controller, _) {
        final hidden = controller.hiddenConfigs;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white07,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(width: 36, height: 4),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  children: [
                    const Text(
                      'Agregar widgets',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label,
                        letterSpacing: -0.41,
                        height: 1.29,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      minimumSize: Size(0, 0),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.systemBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (hidden.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Todos los widgets están visibles.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                )
              else
                ...hidden.map((config) {
                  final id = config.id;
                  final color = _colorFor(id);
                  return _AddWidgetRow(
                    icon: _iconFor(id),
                    iconColor: color,
                    label: _labelFor(id),
                    onAdd: () {
                      controller.addWidget(id);
                      if (controller.hiddenConfigs.isEmpty) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                }),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _AddWidgetRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onAdd;

  const _AddWidgetRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.label,
                    letterSpacing: -0.24,
                    height: 1.33,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onAdd,
                minimumSize: Size(0, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.systemBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    child: Text(
                      'Agregar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.38,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Wiggle widget ────────────────────────────────────────────────────────────
// Smooth sine-wave rotation with a separately animated scale.
// • Rotation: pure sine, 560 ms period, ±1.5°. Silky, never erratic.
// • Scale: eases from 1.0 → 0.96 over 350 ms on entry, reverses on exit.
//   Done with a second controller so it doesn't interfere with the rotation.
// • Phase offset: each card starts at a random point in the sine cycle
//   so they feel independent without any delayed-start tricks.

class _WigglingWidget extends StatefulWidget {
  final Widget child;
  const _WigglingWidget({required this.child});

  @override
  State<_WigglingWidget> createState() => _WigglingWidgetState();
}

class _WigglingWidgetState extends State<_WigglingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;
  late final double _phaseOffset;

  @override
  void initState() {
    super.initState();

    _phaseOffset = math.Random().nextDouble() * math.pi * 2;

    // Rotation — runs forever, never stopped.
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..repeat();

    // Scale — eases in once on widget creation.
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCubic),
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotateController, _scaleAnim]),
      builder: (_, child) {
        final angle =
            math.sin(_rotateController.value * math.pi * 2 + _phaseOffset) *
            0.026; // ±1.5° — gentle, readable
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scaleByDouble(_scaleAnim.value)
            ..rotateZ(angle),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─── Scaling button (add widget — no rotation, just smooth scale) ─────────────
// Listens directly to the InsightsLayoutController so it never rebuilds
// from scratch, meaning didUpdateWidget fires reliably.

class _ScalingButton extends StatefulWidget {
  final InsightsLayoutController listenTo;
  final VoidCallback onPressed;
  const _ScalingButton({required this.listenTo, required this.onPressed});

  @override
  State<_ScalingButton> createState() => _ScalingButtonState();
}

class _ScalingButtonState extends State<_ScalingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    widget.listenTo.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    widget.listenTo.isReorderMode
        ? _controller.forward()
        : _controller.reverse();
  }

  @override
  void dispose() {
    widget.listenTo.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: widget.onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white05,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.systemBlue.withValues(alpha: 0.25)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.add_circled,
                  size: 16,
                  color: AppColors.systemBlue,
                ),
                SizedBox(width: 8),
                Text(
                  'Agregar widget',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.systemBlue,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── All existing private widgets (unchanged) ─────────────────────────────────

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
                children: [
                  const Expanded(child: _SectionLabel('PREDICCIONES AI')),
                  const SizedBox(width: 8),
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
                                : AppColors.secondaryLabel.withValues(alpha: 0.3),
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
        color: AppColors.systemBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.systemBlue.withValues(alpha: 0.18),
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
              ? AppColors.systemBlue.withValues(alpha: 0.12)
              : AppColors.tertiaryFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.systemBlue.withValues(alpha: 0.35)
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
            color: glowColor.withValues(alpha: 0.08),
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
                color: iconColor.withValues(alpha: 0.12),
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
