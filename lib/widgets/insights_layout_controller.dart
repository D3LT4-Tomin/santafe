import 'package:flutter/foundation.dart';
import '../services/widget_layout_service.dart';
import '../services/firebase_service.dart';

// ─── Widget IDs ──────────────────────────────────────────────────────────────

enum InsightWidgetId {
  stats,
  savingsChart,
  categoriesGastos,
  categoriesIngresos,
  origin,
  bank,
  predictions,
}

extension InsightWidgetIdExtension on InsightWidgetId {
  String get displayName {
    switch (this) {
      case InsightWidgetId.stats:
        return 'Resumen general';
      case InsightWidgetId.savingsChart:
        return 'Gráfico de ahorros';
      case InsightWidgetId.categoriesGastos:
        return 'Categorías de gastos';
      case InsightWidgetId.categoriesIngresos:
        return 'Categorías de ingresos';
      case InsightWidgetId.origin:
        return 'Origen de fondos';
      case InsightWidgetId.bank:
        return 'Bancos';
      case InsightWidgetId.predictions:
        return 'Pronostico IA';
    }
  }
}

// ─── Config ──────────────────────────────────────────────────────────────────

class InsightWidgetConfig {
  final InsightWidgetId id;
  final bool visible;

  const InsightWidgetConfig({required this.id, required this.visible});

  InsightWidgetConfig copyWith({bool? visible}) =>
      InsightWidgetConfig(id: id, visible: visible ?? this.visible);
}

// ─── Controller ──────────────────────────────────────────────────────────────

class InsightsLayoutController extends ChangeNotifier {
  static const _defaultOrder = InsightWidgetId.values;

  final List<InsightWidgetConfig> _configs = _defaultOrder
      .map((id) => InsightWidgetConfig(id: id, visible: true))
      .toList();

  bool _isReorderMode = false;
  bool _isLoaded = false;

  // ── Public getters ──────────────────────────────────────────────────────────

  bool get isReorderMode => _isReorderMode;

  List<InsightWidgetConfig> get configs => List.unmodifiable(_configs);

  List<InsightWidgetConfig> get visibleConfigs =>
      _configs.where((c) => c.visible).toList();

  List<InsightWidgetConfig> get hiddenConfigs =>
      _configs.where((c) => !c.visible).toList();

  // ── Persistence (Firebase) ───────────────────────────────────────────────

  void init() {
    if (_isLoaded) return;
    _isLoaded = true;
    load();
  }

  Future<void> load() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return;

    final config = await WidgetLayoutService.getLayoutConfig(userId);
    if (config == null) return;

    final savedOrder = List<String>.from(config['order'] ?? []);
    final savedVisibility = Map<String, bool>.from(config['visibility'] ?? {});

    for (int i = 0; i < _configs.length; i++) {
      final id = _configs[i].id.name;

      final orderIndex = savedOrder.indexOf(id);
      if (orderIndex != -1 && orderIndex != i) {
        final targetConfig = _configs.firstWhere((c) => c.id.name == id);
        _configs.remove(targetConfig);
        _configs.insert(orderIndex.clamp(0, _configs.length), targetConfig);
      }

      if (savedVisibility.containsKey(id)) {
        _configs[i] = _configs[i].copyWith(visible: savedVisibility[id]);
      }
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return;

    final order = _configs.map((c) => c.id.name).toList();
    final visibility = {for (var c in _configs) c.id.name: c.visible};

    await WidgetLayoutService.saveLayoutConfig(
      userId,
      order: order,
      visibility: visibility,
    );
  }

  // ── Reorder mode ───────────────────────────────────────────────────────────

  void toggleReorderMode() {
    _isReorderMode = !_isReorderMode;
    notifyListeners();
  }

  void exitReorderMode() {
    if (!_isReorderMode) return;
    _isReorderMode = false;
    _save();
    notifyListeners();
  }

  // ── Reorder ────────────────────────────────────────────────────────────────

  void reorder(int oldIndex, int newIndex) {
    // ReorderableListView works only on visible items; map back to full list.
    final visible = visibleConfigs;
    if (oldIndex >= visible.length) return;
    if (newIndex > oldIndex) newIndex -= 1;

    final movedId = visible[oldIndex].id;
    final targetId = visible[newIndex].id;

    final fullOld = _configs.indexWhere((c) => c.id == movedId);
    final fullNew = _configs.indexWhere((c) => c.id == targetId);
    if (fullOld == -1 || fullNew == -1) return;

    final item = _configs.removeAt(fullOld);
    _configs.insert(fullNew, item);
    notifyListeners();
  }

  // ── Remove / Add ───────────────────────────────────────────────────────────

  void remove(InsightWidgetId id) {
    final i = _configs.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _configs[i] = _configs[i].copyWith(visible: false);
    notifyListeners();
  }

  void addWidget(InsightWidgetId id) {
    final i = _configs.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _configs[i] = _configs[i].copyWith(visible: true);
    notifyListeners();
  }

  void setVisible(InsightWidgetId id, bool visible) {
    final i = _configs.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _configs[i] = _configs[i].copyWith(visible: visible);
    notifyListeners();
  }

  void reset() {
    _configs.clear();
    _configs.addAll(
      _defaultOrder.map((id) => InsightWidgetConfig(id: id, visible: true)),
    );
    notifyListeners();
  }
}
