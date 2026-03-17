import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double>   _blob1Anim;
  late Animation<double>   _blob2Anim;
  late AnimationController _appearController;
  late Animation<double>   _appearAnim;
  late AnimationController _donutController;
  late Animation<double>   _donutAnim;

  final _searchBarOpacity = ValueNotifier<double>(1.0);

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

    _donutController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _donutAnim = CurvedAnimation(parent: _donutController, curve: Curves.easeOutCubic);
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
    _searchBarOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      child: Stack(
        children: [
          // ── Animated background ──────────────────────────────────
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
          ),

          // ── Scrollable content ────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
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
                      _buildStatsGrid(),
                      const SizedBox(height: 16),
                      _buildOriginCard(),
                      const SizedBox(height: 16),
                      _buildCategoriesCard(),
                      const SizedBox(height: 16),
                      _buildSavingsGoalCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Frosted header chrome ─────────────────────────────────
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

  // ─── Header chrome (blur + gradient) ──────────────────────────────────────
  Widget _buildHeaderChrome(double topPadding) {
    final chromeH = topPadding + 66.0;
    return SizedBox(
      height: chromeH,
      child: Stack(
        children: [
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [AppColors.frostedBlue, Color(0x00070D1A)],
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

  // ─── 2-column stats grid ───────────────────────────────────────────────────
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

  // ─── Origen de Gastos (cash vs bank) ──────────────────────────────────────
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

  // ─── AI Categories donut chart ─────────────────────────────────────────────
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
                      border: Border.all(color: AppColors.blueTipBorder, width: 0.5),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  // ── Animated donut ─────────────────────────────
                  SizedBox(
                    width: 120, height: 120,
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
                  // ── Legend ─────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _LegendRow(color: AppColors.systemBlue,   label: 'Comida',       percent: '40%'),
                        SizedBox(height: 12),
                        _LegendRow(color: AppColors.systemIndigo, label: 'Ocio',          percent: '30%'),
                        SizedBox(height: 12),
                        _LegendRow(color: AppColors.systemPurple, label: 'Transporte',    percent: '18%'),
                        SizedBox(height: 12),
                        _LegendRow(color: AppColors.systemOrange, label: 'Otros',         percent: '12%'),
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

  // ─── Savings Goal card ─────────────────────────────────────────────────────
  Widget _buildSavingsGoalCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
          // Accent left border like the HTML version
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 4, color: AppColors.systemBlue),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Meta: Viaje 2024',
                              style: AppTextStyles.headline,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Has ahorrado \$450 de \$2,000',
                              style: AppTextStyles.caption1,
                            ),
                          ],
                        ),
                        const Text(
                          '22.5%',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.systemBlue,
                            letterSpacing: -0.41,
                            height: 1.29,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.225,
                        minHeight: 8,
                        backgroundColor: AppColors.tertiaryFill,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.systemBlue),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Meta total', style: AppTextStyles.caption1),
                        Text(
                          '\$2,000.00',
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.secondaryLabel,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String   label;
  final String   amount;
  final String   decimals;
  final IconData trendIcon;
  final Color    trendColor;
  final String   trendText;
  final Color    glowColor;

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

// ─── Section label (all-caps) ─────────────────────────────────────────────────
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

// ─── Origin Row (icon + label + progress bar) ─────────────────────────────────
class _OriginRow extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   amount;
  final double   progress;
  final Color    progressColor;

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
                width: 32, height: 32,
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

// ─── Legend Row ───────────────────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  final Color  color;
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
          width: 8, height: 8,
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

// ─── Donut Chart Painter ──────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final double progress;

  // segments: [fraction, color]
  static const _segments = [
    (0.40, AppColors.systemBlue),
    (0.30, AppColors.systemIndigo),
    (0.18, AppColors.systemPurple),
    (0.12, AppColors.systemOrange),
  ];

  static const _strokeWidth = 10.0;
  static const _gap         = 0.025; // radians gap between segments

  _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - _strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..color       = AppColors.tertiaryFill,
    );

    double startAngle = -math.pi / 2;
    final totalSweep  = math.pi * 2 * progress;

    for (final (fraction, color) in _segments) {
      final sweep = (fraction * math.pi * 2 - _gap).clamp(0.0, math.pi * 2);
      final animatedSweep = sweep * progress;

      canvas.drawArc(
        rect,
        startAngle,
        animatedSweep,
        false,
        Paint()
          ..style         = PaintingStyle.stroke
          ..strokeWidth   = _strokeWidth
          ..strokeCap     = StrokeCap.round
          ..color         = color,
      );

      startAngle += sweep + _gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}
