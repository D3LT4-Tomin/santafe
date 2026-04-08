import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../providers/learning_provider.dart';
import '../models/learning_model.dart';
import 'a_donde_se_va_tu_dinero_lesson.dart';
import 'gastos_hormiga_lesson.dart';
import 'ahorro_basico_lesson.dart';
import 'lesson_starter_screen.dart';

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
      ],
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
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, _) {
        final progress = learningProvider.progressPercentage;
        final streakDays = learningProvider.totalStreakDays;
        final completedCount = learningProvider.completedLessonsCount;
        final totalCount = learningProvider.totalLessonsCount;
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu actividad\nactual',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.label,
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${learningProvider.totalPoints} pts',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryLabel,
                              ),
                            ),
                            if (streakDays > 0) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.systemOrange.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.flame_fill,
                                      size: 12,
                                      color: AppColors.systemOrange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$streakDays días',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.systemOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$completedCount de $totalCount lecciones',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, _) => SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: _RingPainter(progress: progress * _anim.value),
                        child: Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
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
      },
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, _) {
        final weekdaysCompleted = learningProvider.weekdaysCompleted;
        final now = DateTime.now();
        final todayIndex = now.weekday - 1;

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
                  final isToday = i == todayIndex;
                  final isDone = weekdaysCompleted.contains(i + 1);
                  final isPast = i < todayIndex;

                  Color bg;
                  Color fg;
                  Border? border;
                  BoxShape shape = BoxShape.circle;

                  if (isDone) {
                    if (isToday) {
                      bg = AppColors.systemBlue;
                      fg = Colors.white;
                    } else {
                      bg = Colors.transparent;
                      fg = AppColors.systemBlue;
                      border = Border.all(
                        color: AppColors.systemBlue,
                        width: 2,
                      );
                    }
                  } else if (isToday) {
                    bg = AppColors.systemBlue;
                    fg = Colors.white;
                  } else if (isPast) {
                    bg = AppColors.white05;
                    fg = AppColors.tertiaryLabel;
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
                      shape: shape,
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
      },
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
  final String lessonId;
  final String title;
  final int minutes;
  final IconData icon;
  final Color color;
  final bool recommended;
  final int orderInCategory;
  final Widget? lessonScreen;
  final String? description;
  final List<String>? tips;
  const _ModuleData({
    required this.lessonId,
    required this.title,
    required this.minutes,
    required this.icon,
    required this.color,
    this.recommended = false,
    this.orderInCategory = 0,
    this.lessonScreen,
    this.description,
    this.tips,
  });
}

class _ModulesSection extends StatefulWidget {
  const _ModulesSection();

  @override
  State<_ModulesSection> createState() => _ModulesSectionState();
}

class _ModulesSectionState extends State<_ModulesSection> {
  final List<PageController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _ModulesSectionData.categories.length; i++) {
      _controllers.add(PageController(viewportFraction: 1.0));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  int _getInitialPage(List<_ModuleData> sorted, LearningProvider provider) {
    final currentIndex = _getCurrentIndex(sorted, provider);
    return currentIndex ~/ 2;
  }

  static int _getCurrentIndex(
    List<_ModuleData> sorted,
    LearningProvider provider,
  ) {
    for (int i = 0; i < sorted.length; i++) {
      final lesson = sorted[i];
      final isUnlocked = _isLessonUnlocked(lesson, sorted, provider);
      if (isUnlocked && !provider.isLessonCompleted(lesson.lessonId)) {
        return i;
      }
    }
    return 0;
  }

  static bool _isLessonUnlocked(
    _ModuleData lesson,
    List<_ModuleData> allModules,
    LearningProvider provider,
  ) {
    if (lesson.orderInCategory == 0) return true;
    final previousLesson = allModules
        .where((m) => m.orderInCategory == lesson.orderInCategory - 1)
        .firstOrNull;
    if (previousLesson == null) return true;
    return provider.isLessonCompleted(previousLesson.lessonId);
  }

  static List<_ModuleData> _sortModules(
    List<_ModuleData> modules,
    LearningProvider provider,
  ) {
    final copy = [...modules];
    copy.sort((a, b) {
      final aCompleted = provider.isLessonCompleted(a.lessonId);
      final bCompleted = provider.isLessonCompleted(b.lessonId);
      if (aCompleted && !bCompleted) return -1;
      if (!aCompleted && bCompleted) return 1;
      return a.orderInCategory.compareTo(b.orderInCategory);
    });
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (
              var catIndex = 0;
              catIndex < _ModulesSectionData.categories.length;
              catIndex++
            )
              Builder(
                builder: (context) {
                  final modules =
                      _ModulesSectionData.categories[catIndex].modules;
                  final sorted = _sortModules(modules, learningProvider);
                  final initialPage = _getInitialPage(sorted, learningProvider);

                  if (!_controllers[catIndex].hasClients) {
                    _controllers[catIndex] = PageController(
                      viewportFraction: 1.0,
                      initialPage: initialPage,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 32, bottom: 12),
                        child: Text(
                          _ModulesSectionData.categories[catIndex].label,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _ModuleCard(
                                      data: sorted[leftIndex],
                                      allModules: sorted,
                                      learningProvider: learningProvider,
                                      isCurrent:
                                          leftIndex ==
                                          _getCurrentIndex(
                                            sorted,
                                            learningProvider,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (rightIndex < sorted.length)
                                    Expanded(
                                      child: _ModuleCard(
                                        data: sorted[rightIndex],
                                        allModules: sorted,
                                        learningProvider: learningProvider,
                                        isCurrent:
                                            rightIndex ==
                                            _getCurrentIndex(
                                              sorted,
                                              learningProvider,
                                            ),
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
      },
    );
  }
}

class _ModulesSectionData {
  static const categories = [
    _ModuleCategory(
      label: 'Gestión',
      modules: [
        _ModuleData(
          lessonId: 'a_donde_se_va_tu_dinero',
          title: '¿A dónde se va\ntu dinero?',
          minutes: 5,
          icon: CupertinoIcons.money_dollar_circle_fill,
          color: AppColors.systemBlue,
          recommended: true,
          orderInCategory: 0,
          lessonScreen: const DondeSeVanLesson(),
          description:
              'Descubre cómo se van tus gastos y aprende a rastrearlos.',
          tips: [
            'Registra todos tus gastos durante una semana',
            'Categoriza tus gastos en necesidades y deseos',
            'Identifica los gastos que puedes reducir',
          ],
        ),
        _ModuleData(
          lessonId: 'control_gastos',
          title: 'Control de\ngastos',
          minutes: 6,
          icon: CupertinoIcons.list_bullet,
          color: AppColors.systemPurple,
          orderInCategory: 1,
          description: 'Aprende a llevar un registro detallado de tus gastos.',
          tips: [
            'Usa una app para registrar gastos diarios',
            'Revisa tus gastos semanalmente',
            'Establece límites por categoría',
          ],
        ),
        _ModuleData(
          lessonId: 'analisis_categorias',
          title: 'Análisis de\ncategorías',
          minutes: 8,
          icon: CupertinoIcons.chart_pie,
          color: AppColors.systemOrange,
          orderInCategory: 2,
          description: 'Analiza en qué categoría gastas más dinero.',
          tips: [
            'Grafica tus gastos por categoría',
            'Compara con meses anteriores',
            'Ajusta tu presupuesto según patrones',
          ],
        ),
        _ModuleData(
          lessonId: 'tendencias_mensuales',
          title: 'Tendencias\nmensuales',
          minutes: 10,
          icon: CupertinoIcons.graph_circle_fill,
          color: AppColors.systemGreen,
          orderInCategory: 3,
          description: 'Identifica patrones y tendencias en tus finanzas.',
          tips: [
            'Compara gastos mes a mes',
            'Identifica gastos estacionales',
            'Planifica para gastos futuros',
          ],
        ),
        _ModuleData(
          lessonId: 'conceptos_base',
          title: 'Conceptos\nbásicos',
          minutes: 4,
          icon: CupertinoIcons.book_fill,
          color: AppColors.systemIndigo,
          orderInCategory: 4,
          description: 'Fundamentos de educación financiera personal.',
          tips: [
            'Activo vs Pasivo',
            'Diferencia entre ingreso y ganancia',
            'Principio de pagarce a uno mismo',
          ],
        ),
        _ModuleData(
          lessonId: 'presupuesto_semanal',
          title: 'Presupuesto\nsemanal',
          minutes: 7,
          icon: CupertinoIcons.chart_bar_fill,
          color: AppColors.systemIndigo,
          orderInCategory: 5,
          description: 'Crea y gestiona un presupuesto semanal efectivo.',
          tips: [
            'Divide tus ingresos en semanas',
            'Asigna categorías a cada gasto',
            'Guarda lo que sobre para ahorro',
          ],
        ),
      ],
    ),
    _ModuleCategory(
      label: 'Planeación',
      modules: [
        _ModuleData(
          lessonId: 'gastos_hormiga',
          title: 'Gastos\nhormiga',
          minutes: 8,
          icon: CupertinoIcons.ant_fill,
          color: AppColors.systemOrange,
          recommended: true,
          orderInCategory: 0,
          lessonScreen: const GastosHormigaLesson(),
          description:
              'Identifica y elimina los pequeños gastos que erosionan tu presupuesto.',
          tips: [
            'Cafés y snacks diarios',
            'Suscripciones no utilizadas',
            'Compras impulsivas pequeñas',
          ],
        ),
        _ModuleData(
          lessonId: 'emergencias_ahorros',
          title: 'Emergencias\ny ahorros',
          minutes: 7,
          icon: CupertinoIcons.shield_fill,
          color: AppColors.systemGreen,
          orderInCategory: 1,
          description: 'Construye un fondo de emergencia sólido.',
          tips: [
            'Ahorra 3-6 meses de gastos',
            'Mantén el fondo accesible',
            'No lo toques salvo emergencias reales',
          ],
        ),
        _ModuleData(
          lessonId: 'finanzas_familiares',
          title: 'Finanzas\nfamiliares',
          minutes: 10,
          icon: CupertinoIcons.person_2_fill,
          color: AppColors.systemPurple,
          orderInCategory: 2,
          description:
              'Gestiona las finanzas de tu familia de manera efectiva.',
          tips: [
            'Comunicación abierta sobre dinero',
            'Metas financieras compartidas',
            'Presupuesto familiar mensual',
          ],
        ),
        _ModuleData(
          lessonId: 'metas_corto_plazo',
          title: 'Metas a\ncorto plazo',
          minutes: 6,
          icon: CupertinoIcons.flag_fill,
          color: AppColors.systemRed,
          orderInCategory: 3,
          description: 'Define y alcanza metas financieras en menos de un año.',
          tips: [
            'Usa la metodología SMART',
            'Visualiza tu progreso',
            'Celebra cada pequeño logro',
          ],
        ),
        _ModuleData(
          lessonId: 'intro_planeacion',
          title: 'Intro a\nplaneación',
          minutes: 5,
          icon: CupertinoIcons.lightbulb_fill,
          color: AppColors.systemBlue,
          orderInCategory: 4,
          description: 'Introducción a la planificación financiera personal.',
          tips: [
            'Visión a corto, mediano y largo plazo',
            'Prioriza tus objetivos',
            'Revisa y ajusta regularmente',
          ],
        ),
        _ModuleData(
          lessonId: 'planificacion_anual',
          title: 'Planificación\nanual',
          minutes: 12,
          icon: CupertinoIcons.calendar,
          color: AppColors.systemBlue,
          orderInCategory: 5,
          description: 'Planifica tus finanzas para todo el año.',
          tips: [
            'Calendario de gastos fijos',
            'Reservas para vacaciones',
            'Ajustes trimestrales',
          ],
        ),
      ],
    ),
    _ModuleCategory(
      label: 'Ahorro',
      modules: [
        _ModuleData(
          lessonId: 'ahorro_basico',
          title: 'Ahorro\nbásico',
          minutes: 6,
          icon: CupertinoIcons.star_circle_fill,
          color: AppColors.systemGreen,
          recommended: true,
          orderInCategory: 0,
          lessonScreen: const AhorroBasicoLesson(),
          description: 'Aprende la regla 50/30/20 y cómo empezar a ahorrar.',
          tips: [
            '50% para necesidades',
            '30% para deseos',
            '20% para ahorro e inversión',
          ],
        ),
        _ModuleData(
          lessonId: 'ahorrar_comida',
          title: 'Ahorrar en\ncomida',
          minutes: 7,
          icon: CupertinoIcons.cart_fill,
          color: AppColors.systemRed,
          orderInCategory: 1,
          description:
              'Reduce tu gasto en alimentación sin sacrificar nutrición.',
          tips: [
            'Cocina en casa más seguido',
            'Compra en temporada',
            'Planea tus comidas semanalmente',
          ],
        ),
        _ModuleData(
          lessonId: 'inversion_ninos',
          title: 'Inversión\npara niños',
          minutes: 15,
          icon: CupertinoIcons.book_fill,
          color: AppColors.systemIndigo,
          orderInCategory: 2,
          description: 'Introduce a tus hijos al mundo de las finanzas.',
          tips: [
            'Cuenta de ahorro para niños',
            'Mesada y su gestión',
            'Primeros conceptos de inversión',
          ],
        ),
        _ModuleData(
          lessonId: 'metodo_50_30_20',
          title: 'El método\n50/30/20',
          minutes: 9,
          icon: CupertinoIcons.chart_pie_fill,
          color: AppColors.systemTeal,
          orderInCategory: 3,
          description:
              'Domina la técnica más popular de distribución de ingresos.',
          tips: [
            'Calcula tu ingreso neto',
            'Asigna cada categoría',
            'Ajusta según tu realidad',
          ],
        ),
        _ModuleData(
          lessonId: 'por_que_ahorrar',
          title: 'Por qué\nahorrar',
          minutes: 4,
          icon: CupertinoIcons.question_circle_fill,
          color: AppColors.systemGreen,
          orderInCategory: 4,
          description:
              'Descubre las razones para construir un hábito de ahorro.',
          tips: [
            'Seguridad financiera',
            'Oportunidades futuras',
            'Libertad de elección',
          ],
        ),
        _ModuleData(
          lessonId: 'reducir_gastos',
          title: 'Reducir\ngastos',
          minutes: 8,
          icon: CupertinoIcons.arrow_down_circle_fill,
          color: AppColors.systemOrange,
          orderInCategory: 5,
          description: 'Estrategias prácticas para gastar menos.',
          tips: [
            'Auditoría de gastos mensuales',
            'Negociación de servicios',
            'Comparativas antes de comprar',
          ],
        ),
      ],
    ),
  ];
}

// ─── Module card ──────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final _ModuleData data;
  final List<_ModuleData> allModules;
  final bool isCurrent;
  final LearningProvider learningProvider;

  const _ModuleCard({
    required this.data,
    required this.allModules,
    required this.isCurrent,
    required this.learningProvider,
  });

  bool _isUnlocked() {
    if (data.orderInCategory == 0) return true;
    final prev = allModules
        .where((m) => m.orderInCategory == data.orderInCategory - 1)
        .firstOrNull;
    if (prev == null) return true;
    return learningProvider.isLessonCompleted(prev.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    final completed = learningProvider.isLessonCompleted(data.lessonId);
    final isUnlocked = _isUnlocked();
    final locked = !isUnlocked;

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
      borderColor = AppColors.systemBlue.withValues(alpha: 0.55);
      bgColor = AppColors.systemBlue.withValues(alpha: 0.08);
      iconBgColor = AppColors.systemBlue.withValues(alpha: 0.15);
    } else if (completed) {
      iconColor = data.color.withValues(alpha: 0.5);
      textColor = AppColors.secondaryLabel;
      borderColor = AppColors.white07;
      bgColor = AppColors.white05;
      iconBgColor = data.color.withValues(alpha: 0.08);
    } else {
      iconColor = data.color;
      textColor = AppColors.label;
      borderColor = data.color.withValues(alpha: 0.22);
      bgColor = data.color.withValues(alpha: 0.08);
      iconBgColor = data.color.withValues(alpha: 0.15);
    }

    return Builder(
      builder: (context) => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: locked
            ? null
            : () {
                Widget screenToShow;
                if (data.lessonScreen != null) {
                  screenToShow = data.lessonScreen!;
                } else {
                  screenToShow = _GenericLessonContent(
                    lessonId: data.lessonId,
                    title: data.title.replaceAll('\n', ' '),
                    description: data.description ?? '',
                    tips: data.tips ?? [],
                    color: data.color,
                    icon: data.icon,
                    minutes: data.minutes,
                  );
                }
                Navigator.of(context).push(
                  LessonStarterScreen.route(
                    lessonId: data.lessonId,
                    lessonScreen: screenToShow,
                  ),
                );
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

            if (data.recommended && !completed)
              Positioned(
                top: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.systemPurple.withValues(alpha: 0.18),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: AppColors.systemPurple.withValues(alpha: 0.35),
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
                        Text(
                          data.orderInCategory == 0 ? 'Inicial' : 'Siguiente',
                          style: TextStyle(
                            fontSize: 9,
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
                    color: AppColors.systemGreen.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.systemGreen.withValues(alpha: 0.40),
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

// ─── Generic lesson content ────────────────────────────────────────────────────

class _GenericLessonContent extends StatefulWidget {
  final String lessonId;
  final String title;
  final String description;
  final List<String> tips;
  final Color color;
  final IconData icon;
  final int minutes;

  const _GenericLessonContent({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.tips,
    required this.color,
    required this.icon,
    required this.minutes,
  });

  @override
  State<_GenericLessonContent> createState() => _GenericLessonContentState();
}

class _GenericLessonContentState extends State<_GenericLessonContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _completeLesson() {
    final lesson = LessonCatalog.getById(widget.lessonId);
    if (lesson != null) {
      context.read<LearningProvider>().completeLesson(
        widget.lessonId,
        lesson.points,
        badgeId: lesson.badgeId,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF070D1A),
      body: Stack(
        children: [
          Positioned(
            top: topPadding + 8,
            left: 8,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 36),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.minutes} min',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Aprende a:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: widget.color.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              CupertinoIcons.checkmark,
                              size: 14,
                              color: widget.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 20,
            child: GestureDetector(
              onTap: _completeLesson,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Completar lección',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
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

// ─── Achievements grid ────────────────────────────────────────────────────────

class _BadgeInfo {
  final String badgeId;
  final String label;
  final IconData icon;
  const _BadgeInfo({
    required this.badgeId,
    required this.label,
    required this.icon,
  });
}

const _badgeInfoList = [
  _BadgeInfo(
    badgeId: 'first_lesson',
    label: 'Primer\nlección',
    icon: CupertinoIcons.pencil,
  ),
  _BadgeInfo(
    badgeId: 'first_savings',
    label: 'Primer\nahorro',
    icon: CupertinoIcons.money_dollar,
  ),
  _BadgeInfo(
    badgeId: 'week_streak',
    label: 'Una semana\nde racha',
    icon: CupertinoIcons.rocket_fill,
  ),
  _BadgeInfo(
    badgeId: 'five_lessons',
    label: '5 lecciones\nseguidas',
    icon: CupertinoIcons.pencil_slash,
  ),
  _BadgeInfo(
    badgeId: 'month_streak',
    label: 'Un mes\nde racha',
    icon: CupertinoIcons.calendar,
  ),
  _BadgeInfo(
    badgeId: 'year_streak',
    label: '365 días\nde racha',
    icon: CupertinoIcons.gift_fill,
  ),
  _BadgeInfo(
    badgeId: 'night_study',
    label: 'Noche\nestudiosa',
    icon: CupertinoIcons.moon_fill,
  ),
  _BadgeInfo(
    badgeId: 'explorer',
    label: 'Explorador',
    icon: CupertinoIcons.cube_box_fill,
  ),
  _BadgeInfo(
    badgeId: 'constant',
    label: 'Constante',
    icon: CupertinoIcons.link,
  ),
];

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.85,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _badgeInfoList.map((badge) {
              final earned = learningProvider.hasBadge(badge.badgeId);
              return _HexBadge(badgeInfo: badge, earned: earned);
            }).toList(),
          ),
        );
      },
    );
  }
}

class _HexBadge extends StatelessWidget {
  final _BadgeInfo badgeInfo;
  final bool earned;
  const _HexBadge({required this.badgeInfo, required this.earned});

  @override
  Widget build(BuildContext context) {
    final iconColor = earned ? AppColors.systemBlue : AppColors.tertiaryLabel;
    final bgColor = earned
        ? AppColors.systemBlue.withValues(alpha: 0.12)
        : AppColors.white05;
    final borderColor = earned
        ? AppColors.systemBlue.withValues(alpha: 0.28)
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
              child: Icon(badgeInfo.icon, color: iconColor, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          badgeInfo.label,
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
