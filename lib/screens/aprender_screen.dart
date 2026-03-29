import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';
import 'conceptos_base_lesson.dart';
import 'ahorro_activo_lesson.dart';
import 'a_donde_se_va_tu_dinero_lesson.dart';
import 'gastos_hormiga_lesson.dart';
import 'ahorro_basico_lesson.dart';
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

  static const _days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _todayIndex = 3;
  static const _doneUpTo = 3;

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
  final bool completed;
  final Widget? lessonScreen;
  const _ModuleData({
    required this.title,
    required this.minutes,
    required this.icon,
    required this.color,
    this.recommended = false,
    this.locked = false,
    this.completed = false,
    this.lessonScreen,
  });
}

class _ModulesSection extends StatefulWidget {
  const _ModulesSection();

  @override
  State<_ModulesSection> createState() => _ModulesSectionState();
}

class _ModulesSectionState extends State<_ModulesSection> {
  final List<PageController> _controllers = [];

  // ── Curriculum order (source of truth — edit freely) ─────────────────────
  // completed / current / locked are properties on each item.
  // Sorting into completed → current → locked happens at render time.
  // Lesson order in each list doesn't matter for display —
  // _sorted() arranges them: completed → current → locked.
  // The carousel starts on page 1 so page 0 (the two completed lessons)
  // is always one swipe back.
  static const _categories = [
    _ModuleCategory(
      label: 'Gestión',
      modules: [
        // ── 2 completed ──────────────────────────────────────────────────────
        _ModuleData(
          title: 'Conceptos\nbásicos',
          minutes: 4,
          icon: CupertinoIcons.book_fill,
          color: AppColors.systemIndigo,
          completed: true,
        ),
        _ModuleData(
          title: 'Presupuesto\nsemanal',
          minutes: 7,
          icon: CupertinoIcons.chart_bar_fill,
          color: AppColors.systemIndigo,
          completed: true,
        ),
        // ── Current ──────────────────────────────────────────────────────────
        _ModuleData(
          title: '¿A dónde se va\ntu dinero?',
          minutes: 5,
          icon: CupertinoIcons.money_dollar_circle_fill,
          color: AppColors.systemBlue,
          recommended: true,
          lessonScreen: const ADondeSeVaTuDineroLesson(),
        ),
        // ── Locked ───────────────────────────────────────────────────────────
        _ModuleData(
          title: 'Control de\ngastos',
          minutes: 6,
          icon: CupertinoIcons.list_bullet,
          color: AppColors.systemPurple,
          locked: true,
        ),
        _ModuleData(
          title: 'Análisis de\ncategorías',
          minutes: 8,
          icon: CupertinoIcons.chart_pie,
          color: AppColors.systemOrange,
          locked: true,
        ),
        _ModuleData(
          title: 'Tendencias\nmensuales',
          minutes: 10,
          icon: CupertinoIcons.graph_circle_fill,
          color: AppColors.systemGreen,
          locked: true,
        ),
      ],
    ),
    _ModuleCategory(
      label: 'Planeación',
      modules: [
        // ── 2 completed ──────────────────────────────────────────────────────
        _ModuleData(
          title: 'Intro a\nplaneación',
          minutes: 5,
          icon: CupertinoIcons.lightbulb_fill,
          color: AppColors.systemBlue,
          completed: true,
        ),
        _ModuleData(
          title: 'Planificación\nanual',
          minutes: 12,
          icon: CupertinoIcons.calendar,
          color: AppColors.systemBlue,
          completed: true,
        ),
        // ── Current ──────────────────────────────────────────────────────────
        _ModuleData(
          title: 'Gastos\nhormiga',
          minutes: 8,
          icon: CupertinoIcons.ant_fill,
          color: AppColors.systemOrange,
          recommended: true,
          lessonScreen: const GastosHormigaLesson(),
        ),
        // ── Locked ───────────────────────────────────────────────────────────
        _ModuleData(
          title: 'Emergencias\ny ahorros',
          minutes: 7,
          icon: CupertinoIcons.shield_fill,
          color: AppColors.systemGreen,
          locked: true,
        ),
        _ModuleData(
          title: 'Finanzas\nfamiliares',
          minutes: 10,
          icon: CupertinoIcons.person_2_fill,
          color: AppColors.systemPurple,
          locked: true,
        ),
        _ModuleData(
          title: 'Metas a\ncorto plazo',
          minutes: 6,
          icon: CupertinoIcons.flag_fill,
          color: AppColors.systemRed,
          locked: true,
        ),
      ],
    ),
    _ModuleCategory(
      label: 'Ahorro',
      modules: [
        // ── 2 completed ──────────────────────────────────────────────────────
        _ModuleData(
          title: 'Por qué\nahorrar',
          minutes: 4,
          icon: CupertinoIcons.question_circle_fill,
          color: AppColors.systemGreen,
          completed: true,
        ),
        _ModuleData(
          title: 'Reducir\ngastos',
          minutes: 8,
          icon: CupertinoIcons.arrow_down_circle_fill,
          color: AppColors.systemOrange,
          completed: true,
        ),
        // ── Current ──────────────────────────────────────────────────────────
        _ModuleData(
          title: 'Ahorro\nbásico',
          minutes: 6,
          icon: CupertinoIcons.star_circle_fill,
          color: AppColors.systemGreen,
          recommended: true,
          lessonScreen: const AhorroBasicoLesson(),
        ),
        // ── Locked ───────────────────────────────────────────────────────────
        _ModuleData(
          title: 'Ahorrar en\ncomida',
          minutes: 7,
          icon: CupertinoIcons.cart_fill,
          color: AppColors.systemRed,
          locked: true,
        ),
        _ModuleData(
          title: 'Inversión\npara niños',
          minutes: 15,
          icon: CupertinoIcons.book_fill,
          color: AppColors.systemIndigo,
          locked: true,
        ),
        _ModuleData(
          title: 'El método\n50/30/20',
          minutes: 9,
          icon: CupertinoIcons.chart_pie_fill,
          color: AppColors.systemTeal,
          locked: true,
        ),
      ],
    ),
  ];

  // ── Sort: completed(0) → current(1) → locked(2) ────────────────────────────
  // Page 0 = [completed A | completed B]  ← one swipe back
  // Page 1 = [current | first locked]     ← default view (initialPage: 1)
  // Relative order within each group is preserved (stable sort).
  static int _sortKey(_ModuleData m) {
    if (m.completed) return 0; // page 0 — one swipe back
    if (m.locked) return 2; // after current
    return 1; // current — always starts page 1
  }

  static List<_ModuleData> _sorted(List<_ModuleData> modules) {
    final copy = [...modules];
    copy.sort((a, b) => _sortKey(a).compareTo(_sortKey(b)));
    return copy;
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _categories.length; i++) {
      // Page 0 = two completed lessons (swipe back to revisit).
      // Page 1 = current + first locked — the default landing view.
      _controllers.add(PageController(viewportFraction: 1.0, initialPage: 1));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var catIndex = 0; catIndex < _categories.length; catIndex++)
          Builder(
            builder: (context) {
              final sorted = _sorted(_categories[catIndex].modules);
              // After sorting: [completed, completed, current, locked...].
              // Current is always at index 2 (after the 2 completed lessons).
              const currentIndex = 2;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 12),
                    child: Text(
                      _categories[catIndex].label,
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
                    child: PageView.builder(
                      controller: _controllers[catIndex],
                      itemCount: (sorted.length / 2).ceil(),
                      padEnds: false,
                      itemBuilder: (_, pageIndex) {
                        final leftIndex = pageIndex * 2;
                        final rightIndex = leftIndex + 1;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ModuleCard(
                                  data: sorted[leftIndex],
                                  isCurrent: leftIndex == currentIndex,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (rightIndex < sorted.length)
                                Expanded(
                                  child: _ModuleCard(
                                    data: sorted[rightIndex],
                                    isCurrent: rightIndex == currentIndex,
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
      ],
    );
  }
}

// ─── Module card ──────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final _ModuleData data;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _ModuleCard({required this.data, this.isCurrent = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = data.locked;
    final completed = data.completed;

    // ── Colors per state ────────────────────────────────────────────────────
    // locked  → fully gray, no color anywhere
    // completed → color icon/border but dimmed, green checkmark overlay
    // current → blue accent border + bg
    // default → color tinted
    final Color iconColor;
    final Color textColor;
    final Color borderColor;
    final Color bgColor;
    final Color iconBgColor;

    if (locked) {
      iconColor = AppColors.tertiaryLabel;
      textColor = AppColors.tertiaryLabel;
      borderColor = AppColors.white07;
      bgColor = AppColors.white05;
      iconBgColor = AppColors.white07;
    } else if (isCurrent) {
      iconColor = AppColors.systemBlue;
      textColor = AppColors.label;
      borderColor = AppColors.systemBlue.withOpacity(0.55);
      bgColor = AppColors.systemBlue.withOpacity(0.08);
      iconBgColor = AppColors.systemBlue.withOpacity(0.15);
    } else if (completed) {
      iconColor = data.color.withOpacity(0.5);
      textColor = AppColors.secondaryLabel;
      borderColor = AppColors.white07;
      bgColor = AppColors.white05;
      iconBgColor = data.color.withOpacity(0.08);
    } else {
      iconColor = data.color;
      textColor = AppColors.label;
      borderColor = data.color.withOpacity(0.22);
      bgColor = data.color.withOpacity(0.08);
      iconBgColor = data.color.withOpacity(0.15);
    }

    return Builder(
      builder: (context) => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: locked || data.lessonScreen == null
            ? null
            : () {
                Navigator.of(
                  context,
                ).push(CupertinoPageRoute(builder: (_) => data.lessonScreen!));
              },
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                  width: isCurrent ? 1.5 : 1.0,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(data.icon, color: iconColor, size: 17),
                      ),
                      const Spacer(),
                      // Title
                      Text(
                        data.title,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Duration row
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 10,
                            color: locked
                                ? AppColors.tertiaryLabel
                                : AppColors.secondaryLabel,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${data.minutes} min',
                            style: TextStyle(
                              fontSize: 10,
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
            ),

            // ── AI badge — corner pill: wand + "IA" ────────────────────────
            if (data.recommended && !completed)
              Positioned(
                top: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.systemPurple.withOpacity(0.18),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: AppColors.systemPurple.withOpacity(0.35),
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.wand_stars,
                          size: 11,
                          color: AppColors.systemPurple,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'IA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.systemPurple,
                            letterSpacing: 0.2,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Lock icon ───────────────────────────────────────────────────
            if (locked)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  CupertinoIcons.lock_fill,
                  size: 12,
                  color: AppColors.tertiaryLabel,
                ),
              ),

            // ── Completed checkmark (top-right, replaces lock) ──────────────
            if (completed)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.systemGreen.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.systemGreen.withOpacity(0.40),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark,
                    size: 10,
                    color: AppColors.systemGreen,
                  ),
                ),
              ),

            // ── Blue pulse dot for current lesson (bottom-right) ────────────
            if (isCurrent)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.systemBlue,
                    shape: BoxShape.circle,
                  ),
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
      final angle = math.pi / 180 * (60 * i - 30);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
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
