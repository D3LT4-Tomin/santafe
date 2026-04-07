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

  static const Set<InsightWidgetId> _pinnedWidgets = {InsightWidgetId.bank};

  final List<InsightWidgetConfig> _configs = _defaultOrder
      .map((id) => InsightWidgetConfig(id: id, visible: true))
      .toList();

  bool _isReorderMode = false;
  bool _isLoaded = false;

  // ── Public getters ──────────────────────────────────────────────────────────

  bool get isReorderMode => _isReorderMode;

  List<InsightWidgetConfig> get configs => List.unmodifiable(_configs);

  List<InsightWidgetConfig> get visibleConfigs {
    final pinned = _configs
        .where((c) => c.visible && _pinnedWidgets.contains(c.id))
        .toList();
    final others = _configs
        .where((c) => c.visible && !_pinnedWidgets.contains(c.id))
        .toList();
    return [...pinned, ...others];
  }

  List<InsightWidgetConfig> get hiddenConfigs => _configs
      .where((c) => !c.visible && !_pinnedWidgets.contains(c.id))
      .toList();

  bool isPinned(InsightWidgetId id) => _pinnedWidgets.contains(id);

  // ── Persistence (Firebase) ───────────────────────────────────────────────

  void init() {
    _loadIfNeeded();
  }

  Future<void> reload() async {
    _isLoaded = false;
    await _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    if (_isLoaded) return;
    final userId = FirebaseService.currentUserId;
    if (userId == null) return;

    _isLoaded = true;
    await load();
  }

  Future<void> load() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return;

    final config = await WidgetLayoutService.getLayoutConfig(userId);
    if (config == null) return;

    final savedOrder = List<String>.from(config['order'] ?? []);
    final savedVisibility = Map<String, bool>.from(config['visibility'] ?? {});

    final newConfigs = <InsightWidgetConfig>[];

    for (final idStr in savedOrder) {
      final existing = _configs.firstWhere(
        (c) => c.id.name == idStr,
        orElse: () => InsightWidgetConfig(
          id: InsightWidgetId.values.firstWhere(
            (e) => e.name == idStr,
            orElse: () => InsightWidgetId.stats,
          ),
          visible: false,
        ),
      );
      var isVisible = savedVisibility[idStr] ?? existing.visible;
      if (_pinnedWidgets.contains(existing.id)) {
        isVisible = true;
      }
      newConfigs.add(InsightWidgetConfig(id: existing.id, visible: isVisible));
    }

    for (final config in _configs) {
      if (!savedOrder.contains(config.id.name)) {
        var isVisible = savedVisibility[config.id.name] ?? config.visible;
        if (_pinnedWidgets.contains(config.id)) {
          isVisible = true;
        }
        newConfigs.add(InsightWidgetConfig(id: config.id, visible: isVisible));
      }
    }

    _configs.clear();
    _configs.addAll(newConfigs);

    _ensurePinnedAtTop();

    notifyListeners();
  }

  void _ensurePinnedAtTop() {
    final pinnedConfigs = _configs
        .where((c) => _pinnedWidgets.contains(c.id))
        .toList();
    final otherConfigs = _configs
        .where((c) => !_pinnedWidgets.contains(c.id))
        .toList();
    _configs.clear();
    _configs.addAll([...pinnedConfigs, ...otherConfigs]);
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
    final visible = visibleConfigs;
    if (oldIndex >= visible.length) return;

    final movedId = visible[oldIndex].id;
    if (_pinnedWidgets.contains(movedId) && oldIndex == 0) return;

    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex <= 0 && _pinnedWidgets.contains(visible.first.id)) return;

    final targetId = visible[newIndex].id;

    final fullOld = _configs.indexWhere((c) => c.id == movedId);
    final fullNew = _configs.indexWhere((c) => c.id == targetId);
    if (fullOld == -1 || fullNew == -1) return;

    final item = _configs.removeAt(fullOld);
    _configs.insert(fullNew, item);

    _ensurePinnedAtTop();
    notifyListeners();
  }

  // ── Remove / Add ───────────────────────────────────────────────────────────

  void remove(InsightWidgetId id) {
    if (_pinnedWidgets.contains(id)) return;

    final i = _configs.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _configs[i] = _configs[i].copyWith(visible: false);
    _save();
    notifyListeners();
  }

  void addWidget(InsightWidgetId id) {
    final i = _configs.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _configs[i] = _configs[i].copyWith(visible: true);
    _save();
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
