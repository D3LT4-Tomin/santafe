import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Widget IDs ───────────────────────────────────────────────────────────────
enum InsightWidgetId {
  stats,
  savingsChart,
  categories,
  origin,
  bank,
  predictions,
}

extension InsightWidgetIdLabel on InsightWidgetId {
  String get displayName {
    switch (this) {
      case InsightWidgetId.stats:
        return 'Resumen mensual';
      case InsightWidgetId.savingsChart:
        return 'Proyección de ahorro';
      case InsightWidgetId.categories:
        return 'Categorías AI';
      case InsightWidgetId.origin:
        return 'Origen de gastos';
      case InsightWidgetId.bank:
        return 'Oferta banco';
      case InsightWidgetId.predictions:
        return 'Predicciones AI';
    }
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────
class InsightWidgetConfig {
  final InsightWidgetId id;
  bool visible;

  InsightWidgetConfig({required this.id, this.visible = true});

  InsightWidgetConfig copyWith({bool? visible}) =>
      InsightWidgetConfig(id: id, visible: visible ?? this.visible);

  Map<String, dynamic> toJson() => {'id': id.name, 'visible': visible};

  static InsightWidgetConfig fromJson(Map<String, dynamic> json) {
    final id = InsightWidgetId.values.firstWhere(
      (e) => e.name == json['id'],
      orElse: () => InsightWidgetId.stats,
    );
    return InsightWidgetConfig(
      id: id,
      visible: json['visible'] as bool? ?? true,
    );
  }
}

// ─── Controller (ChangeNotifier) ──────────────────────────────────────────────
class InsightsLayoutController extends ChangeNotifier {
  static const _prefsKey = 'insights_layout_v1';

  List<InsightWidgetConfig> _configs = InsightWidgetId.values
      .map((id) => InsightWidgetConfig(id: id))
      .toList();

  bool _isReorderMode = false;
  bool get isReorderMode => _isReorderMode;

  List<InsightWidgetConfig> get configs => List.unmodifiable(_configs);

  List<InsightWidgetConfig> get visibleConfigs =>
      _configs.where((c) => c.visible).toList();

  void toggleReorderMode() {
    _isReorderMode = !_isReorderMode;
    notifyListeners();
  }

  void setReorderMode(bool value) {
    if (_isReorderMode != value) {
      _isReorderMode = value;
      notifyListeners();
    }
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => InsightWidgetConfig.fromJson(e as Map<String, dynamic>))
            .toList();
        // Merge: keep saved order/visibility, append any new IDs not yet saved
        final savedIds = list.map((c) => c.id).toSet();
        final newDefaults = InsightWidgetId.values
            .where((id) => !savedIds.contains(id))
            .map((id) => InsightWidgetConfig(id: id));
        _configs = [...list, ...newDefaults];
        notifyListeners();
      }
    } catch (_) {
      // Fall back to defaults silently
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_configs.map((c) => c.toJson()).toList()),
    );
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _configs.removeAt(oldIndex);
    _configs.insert(newIndex, item);
    notifyListeners();
    _save();
  }

  void setVisible(InsightWidgetId id, bool visible) {
    final idx = _configs.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    _configs[idx] = _configs[idx].copyWith(visible: visible);
    notifyListeners();
    _save();
  }

  void reset() {
    _configs = InsightWidgetId.values
        .map((id) => InsightWidgetConfig(id: id))
        .toList();
    notifyListeners();
    _save();
  }
}
