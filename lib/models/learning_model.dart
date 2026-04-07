class LessonModel {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final int points;
  final String? badgeId;
  final List<String> prerequisites;

  const LessonModel({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.points,
    this.badgeId,
    this.prerequisites = const [],
  });
}

class LessonCatalog {
  static const List<LessonModel> allLessons = [
    // Gestión
    LessonModel(
      id: 'conceptos_base',
      title: 'Conceptos básicos',
      category: 'Gestión',
      durationMinutes: 4,
      points: 50,
    ),
    LessonModel(
      id: 'presupuesto_semanal',
      title: 'Presupuesto semanal',
      category: 'Gestión',
      durationMinutes: 7,
      points: 75,
    ),
    LessonModel(
      id: 'a_donde_se_va_tu_dinero',
      title: '¿A dónde se va tu dinero?',
      category: 'Gestión',
      durationMinutes: 5,
      points: 100,
      badgeId: 'first_lesson',
    ),
    LessonModel(
      id: 'control_gastos',
      title: 'Control de gastos',
      category: 'Gestión',
      durationMinutes: 6,
      points: 80,
    ),
    LessonModel(
      id: 'analisis_categorias',
      title: 'Análisis de categorías',
      category: 'Gestión',
      durationMinutes: 8,
      points: 100,
    ),
    LessonModel(
      id: 'tendencias_mensuales',
      title: 'Tendencias mensuales',
      category: 'Gestión',
      durationMinutes: 10,
      points: 120,
    ),
    // Planeación
    LessonModel(
      id: 'intro_planeacion',
      title: 'Intro a planeación',
      category: 'Planeación',
      durationMinutes: 5,
      points: 60,
    ),
    LessonModel(
      id: 'planificacion_anual',
      title: 'Planificación anual',
      category: 'Planeación',
      durationMinutes: 12,
      points: 150,
    ),
    LessonModel(
      id: 'gastos_hormiga',
      title: 'Gastos hormiga',
      category: 'Planeación',
      durationMinutes: 8,
      points: 100,
    ),
    LessonModel(
      id: 'emergencias_ahorros',
      title: 'Emergencias y ahorros',
      category: 'Planeación',
      durationMinutes: 7,
      points: 90,
    ),
    LessonModel(
      id: 'finanzas_familiares',
      title: 'Finanzas familiares',
      category: 'Planeación',
      durationMinutes: 10,
      points: 120,
    ),
    LessonModel(
      id: 'metas_corto_plazo',
      title: 'Metas a corto plazo',
      category: 'Planeación',
      durationMinutes: 6,
      points: 80,
    ),
    // Ahorro
    LessonModel(
      id: 'por_que_ahorrar',
      title: 'Por qué ahorrar',
      category: 'Ahorro',
      durationMinutes: 4,
      points: 50,
    ),
    LessonModel(
      id: 'reducir_gastos',
      title: 'Reducir gastos',
      category: 'Ahorro',
      durationMinutes: 8,
      points: 100,
    ),
    LessonModel(
      id: 'ahorro_basico',
      title: 'Ahorro básico',
      category: 'Ahorro',
      durationMinutes: 6,
      points: 80,
      badgeId: 'first_savings',
    ),
    LessonModel(
      id: 'ahorrar_comida',
      title: 'Ahorrar en comida',
      category: 'Ahorro',
      durationMinutes: 7,
      points: 90,
    ),
    LessonModel(
      id: 'inversion_ninos',
      title: 'Inversión para niños',
      category: 'Ahorro',
      durationMinutes: 15,
      points: 180,
    ),
    LessonModel(
      id: 'metodo_50_30_20',
      title: 'El método 50/30/20',
      category: 'Ahorro',
      durationMinutes: 9,
      points: 110,
    ),
  ];

  static List<LessonModel> getByCategory(String category) {
    return allLessons.where((l) => l.category == category).toList();
  }

  static LessonModel? getById(String id) {
    try {
      return allLessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  static int get totalLessons => allLessons.length;
}

class BadgeModel {
  final String id;
  final String label;
  final String iconName;
  final String? description;
  final int requirement;

  const BadgeModel({
    required this.id,
    required this.label,
    required this.iconName,
    this.description,
    required this.requirement,
  });
}

class BadgeCatalog {
  static const List<BadgeModel> allBadges = [
    BadgeModel(
      id: 'first_lesson',
      label: 'Primer lección',
      iconName: 'pencil',
      description: 'Completa tu primera lección',
      requirement: 1,
    ),
    BadgeModel(
      id: 'first_savings',
      label: 'Primer ahorro',
      iconName: 'money_dollar',
      description: 'Completa la lección de ahorro básico',
      requirement: 1,
    ),
    BadgeModel(
      id: 'five_lessons',
      label: '5 lecciones seguidas',
      iconName: 'pencil_slash',
      description: 'Completa 5 lecciones',
      requirement: 5,
    ),
    BadgeModel(
      id: 'week_streak',
      label: 'Una semana de racha',
      iconName: 'rocket_fill',
      description: '7 días de racha',
      requirement: 7,
    ),
    BadgeModel(
      id: 'month_streak',
      label: 'Un mes de racha',
      iconName: 'calendar',
      description: '30 días de racha',
      requirement: 30,
    ),
    BadgeModel(
      id: 'year_streak',
      label: '365 días de racha',
      iconName: 'gift_fill',
      description: '365 días de racha',
      requirement: 365,
    ),
    BadgeModel(
      id: 'night_study',
      label: 'Noche studiosa',
      iconName: 'moon_fill',
      description: 'Estudia de noche',
      requirement: 1,
    ),
    BadgeModel(
      id: 'explorer',
      label: 'Explorador',
      iconName: 'cube_box_fill',
      description: 'Explora todas las categorías',
      requirement: 3,
    ),
    BadgeModel(
      id: 'constant',
      label: 'Constante',
      iconName: 'link',
      description: 'Mantén una racha de 14 días',
      requirement: 14,
    ),
  ];

  static BadgeModel? getById(String id) {
    try {
      return allBadges.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
