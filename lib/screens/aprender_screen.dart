import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';
import 'conceptos_base_lesson.dart';
import 'ahorro_activo_lesson.dart';
import 'comer_fuera_vs_cocinar_lesson.dart';

class AprenderScreen extends StatefulWidget {
  final ScrollController scrollController;
  const AprenderScreen({super.key, required this.scrollController});

  @override
  State<AprenderScreen> createState() => _AprenderScreenState();
}

class _AprenderScreenState extends State<AprenderScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  final _searchBarOpacity = ValueNotifier<double>(1.0);

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
    _searchBarOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        RepaintBoundary(
          child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 76, bottom: 100),
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Progreso ──────────────────────────────────────────
                    _ActivityCard(),
                    SizedBox(height: 12),
                    _WeekStrip(),
                    SizedBox(height: 32),

                    // ── Módulos ───────────────────────────────────────────
                    _ModulesSection(),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
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
          child: Padding(
            padding: EdgeInsets.only(
              top: topPadding + 10,
              bottom: 20,
              left: 16,
              right: 8,
            ),
            child: HeaderRow(
              searchBarOpacity: _searchBarOpacity,
              onSearchPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderChrome(double topPadding) {
    return SizedBox(
      height: topPadding + 66.0,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
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
}

// ─── Section title — large, matches reference ─────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.label,
          letterSpacing: -0.5,
          height: 1.2,
        ),
      ),
    );
  }
}

// ─── Activity card ────────────────────────────────────────────────────────────

class _ActivityCard extends StatefulWidget {
  const _ActivityCard();

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  static const double _progress = 0.10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Row(
            children: [
              // Left text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu actividad\nactual',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular progress ring
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                    painter: _RingPainter(progress: _progress * _anim.value),
                    child: Center(
                      child: Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label,
                          letterSpacing: -0.5,
                        ),
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

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 10) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = AppColors.white07,
    );

    // Progress arc — starts at top (−π/2)
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = AppColors.systemBlue,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Week strip ───────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  // Thursday (index 3) is "today" per the reference
  static const _days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _todayIndex = 3;
  // L M done, X done, J = today, rest = future
  static const _doneUpTo = 3; // 0..2 completed, 3 = today

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_days.length, (i) {
              final isToday = i == _todayIndex;
              final isDone = i < _doneUpTo;
              final isFuture = i > _todayIndex;

              Color bg;
              Color fg;
              Border? border;

              if (isToday) {
                bg = AppColors.systemBlue;
                fg = Colors.white;
              } else if (isDone) {
                bg = Colors.transparent;
                fg = AppColors.label;
                border = Border.all(color: AppColors.white07);
              } else {
                bg = AppColors.white05;
                fg = AppColors.tertiaryLabel;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: border,
                ),
                child: Center(
                  child: Text(
                    _days[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday || isDone
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: fg,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Modules section ──────────────────────────────────────────────────────────

class _ModuleCategory {
  final String label;
  final List<_ModuleData> modules;
  const _ModuleCategory({required this.label, required this.modules});
}

class _ModuleData {
  final String title;
  final int minutes;
  final IconData icon;
  final Color color;
  final bool recommended;
  final bool locked;
  const _ModuleData({
    required this.title,
    required this.minutes,
    required this.icon,
    required this.color,
    this.recommended = false,
    this.locked = false,
  });
}

class _ModulesSection extends StatelessWidget {
  const _ModulesSection();

  static const _categories = [
    _ModuleCategory(
      label: 'Gestión',
      modules: [
        _ModuleData(
          title: '¿A dónde se va\ntu dinero?',
          minutes: 5,
          icon: CupertinoIcons.money_dollar_circle_fill,
          color: AppColors.systemBlue,
          recommended: true,
        ),
        _ModuleData(
          title: 'Presupuesto\nsemanal',
          minutes: 7,
          icon: CupertinoIcons.chart_bar_fill,
          color: AppColors.systemIndigo,
        ),
        _ModuleData(
          title: 'Control de\ngastos',
          minutes: 6,
          icon: CupertinoIcons.list_bullet,
          color: AppColors.systemPurple,
        ),
        _ModuleData(
          title: 'Análisis de\ncategorías',
          minutes: 8,
          icon: CupertinoIcons.chart_pie,
          color: AppColors.systemOrange,
        ),
        _ModuleData(
          title: 'Tendencias\nmensuales',
          minutes: 10,
          icon: CupertinoIcons.graph_circle_fill,
          color: AppColors.systemGreen,
        ),
      ],
    ),
    _ModuleCategory(
      label: 'Planeación',
      modules: [
        _ModuleData(
          title: 'Gastos\nhormiga',
          minutes: 8,
          icon: CupertinoIcons.ant_fill,
          color: AppColors.systemOrange,
        ),
        _ModuleData(
          title: 'Metas a\ncorto plazo',
          minutes: 6,
          icon: CupertinoIcons.flag_fill,
          color: AppColors.systemRed,
          locked: true,
        ),
        _ModuleData(
          title: 'Planificación\nanual',
          minutes: 12,
          icon: CupertinoIcons.calendar,
          color: AppColors.systemBlue,
        ),
        _ModuleData(
          title: 'Emergencias\ny ahorros',
          minutes: 7,
          icon: CupertinoIcons.shield_fill,
          color: AppColors.systemGreen,
        ),
        _ModuleData(
          title: 'Finanzas\nfamiliares',
          minutes: 10,
          icon: CupertinoIcons.person_2_fill,
          color: AppColors.systemPurple,
        ),
      ],
    ),
    _ModuleCategory(
      label: 'Ahorro',
      modules: [
        _ModuleData(
          title: 'Ahorro\nbásico',
          minutes: 6,
          icon: CupertinoIcons.star_circle_fill,
          color: AppColors.systemGreen,
        ),
        _ModuleData(
          title: 'El método\n50/30/20',
          minutes: 9,
          icon: CupertinoIcons.chart_pie_fill,
          color: AppColors.systemTeal,
          locked: true,
        ),
        _ModuleData(
          title: 'Reducir\ngastos',
          minutes: 8,
          icon: CupertinoIcons.arrow_down_circle_fill,
          color: AppColors.systemOrange,
        ),
        _ModuleData(
          title: 'Ahorrar en\ncomida',
          minutes: 7,
          icon: CupertinoIcons.cart_fill,
          color: AppColors.systemRed,
        ),
        _ModuleData(
          title: 'Inversión\npara niños',
          minutes: 15,
          icon: CupertinoIcons.book_fill,
          color: AppColors.systemIndigo,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _categories.map((cat) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 12),
              child: Text(
                cat.label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.label,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24, right: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: cat.modules.length,
                itemBuilder: (_, i) => _ModuleCard(data: cat.modules[i]),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final _ModuleData data;
  const _ModuleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final locked = data.locked;
    final iconColor = locked ? AppColors.tertiaryLabel : data.color;
    final textColor = locked ? AppColors.secondaryLabel : AppColors.label;

    return SizedBox(
      width: 160,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: locked ? null : () {},
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: locked
                    ? AppColors.white05
                    : data.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: locked
                      ? AppColors.white07
                      : data.color.withOpacity(0.22),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: locked
                            ? AppColors.white07
                            : data.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(data.icon, color: iconColor, size: 18),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      data.title,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Duration row
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 11,
                          color: locked
                              ? AppColors.tertiaryLabel
                              : AppColors.secondaryLabel,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.minutes} minutos',
                          style: TextStyle(
                            fontSize: 11,
                            color: locked
                                ? AppColors.tertiaryLabel
                                : AppColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // "Recomendado por IA" floating label
            if (data.recommended)
              Positioned(
                top: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.systemPurple.withOpacity(0.15),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: AppColors.systemPurple.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Recomendado por IA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.systemPurple,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

            // Lock overlay
            if (locked)
              Positioned(
                top: 12,
                right: 12,
                child: Icon(
                  CupertinoIcons.lock_fill,
                  size: 13,
                  color: AppColors.tertiaryLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Achievements grid ────────────────────────────────────────────────────────

class _Achievement {
  final String label;
  final IconData icon;
  final bool earned;
  const _Achievement({
    required this.label,
    required this.icon,
    required this.earned,
  });
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid();

  static const _achievements = [
    _Achievement(
      label: 'Primer\nlección',
      icon: CupertinoIcons.pencil,
      earned: true,
    ),
    _Achievement(
      label: 'Primer\nahorro',
      icon: CupertinoIcons.money_dollar,
      earned: true,
    ),
    _Achievement(
      label: 'Una semana\nde racha',
      icon: CupertinoIcons.rocket_fill,
      earned: true,
    ),
    _Achievement(
      label: '5 lecciones\nseguidas',
      icon: CupertinoIcons.pencil_slash,
      earned: true,
    ),
    _Achievement(
      label: 'Un mes\nde racha',
      icon: CupertinoIcons.calendar,
      earned: false,
    ),
    _Achievement(
      label: '365 días\nde racha',
      icon: CupertinoIcons.gift_fill,
      earned: false,
    ),
    _Achievement(
      label: 'Noche\nestudiosa',
      icon: CupertinoIcons.moon_fill,
      earned: false,
    ),
    _Achievement(
      label: 'Explorador',
      icon: CupertinoIcons.cube_box_fill,
      earned: false,
    ),
    _Achievement(label: 'Constante', icon: CupertinoIcons.link, earned: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _achievements.map((a) => _HexBadge(achievement: a)).toList(),
      ),
    );
  }
}

class _HexBadge extends StatelessWidget {
  final _Achievement achievement;
  const _HexBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earned;
    final iconColor = earned ? AppColors.systemBlue : AppColors.tertiaryLabel;
    final bgColor = earned
        ? AppColors.systemBlue.withOpacity(0.12)
        : AppColors.white05;
    final borderColor = earned
        ? AppColors.systemBlue.withOpacity(0.28)
        : AppColors.white07;
    final labelColor = earned ? AppColors.label : AppColors.tertiaryLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: CustomPaint(
            painter: _HexPainter(fillColor: bgColor, borderColor: borderColor),
            child: Center(
              child: Icon(achievement.icon, color: iconColor, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          achievement.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: labelColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _HexPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  const _HexPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 1.5;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      // flat-top hexagon: start at 30°
      final angle = math.pi / 180 * (60 * i - 30);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_HexPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}
