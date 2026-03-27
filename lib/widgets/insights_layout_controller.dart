import 'package:flutter/foundation.dart';

// ─── Widget IDs ──────────────────────────────────────────────────────────────

enum InsightWidgetId {
  stats,
  savingsChart,
  categories,
  origin,
  bank,
  predictions,
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

  List<InsightWidgetConfig> _configs = _defaultOrder
      .map((id) => InsightWidgetConfig(id: id, visible: true))
      .toList();

  bool _isReorderMode = false;

  // ── Public getters ──────────────────────────────────────────────────────────

  bool get isReorderMode => _isReorderMode;

  List<InsightWidgetConfig> get visibleConfigs =>
      _configs.where((c) => c.visible).toList();

  List<InsightWidgetConfig> get hiddenConfigs =>
      _configs.where((c) => !c.visible).toList();

  // ── Persistence (stub — swap with SharedPreferences as needed) ─────────────

  Future<void> load() async {
    // No-op until persistence is wired up.
  }

  Future<void> _save() async {
    // Persist order + visibility here when ready.
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

  @override
  void dispose() {
    super.dispose();
  }
}
