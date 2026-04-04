import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// ─── Filter state ─────────────────────────────────────────────────────────────

class FilterSelection {
  final Set<String> categories;
  final Set<String> origins;
  final Set<String> tipos;

  const FilterSelection({
    this.categories = const {},
    this.origins = const {},
    this.tipos = const {},
  });

  FilterSelection copyWith({
    Set<String>? categories,
    Set<String>? origins,
    Set<String>? tipos,
  }) => FilterSelection(
    categories: categories ?? this.categories,
    origins: origins ?? this.origins,
    tipos: tipos ?? this.tipos,
  );

  int get activeCount => categories.length + origins.length + tipos.length;
  bool get isEmpty => categories.isEmpty && origins.isEmpty && tipos.isEmpty;

  bool matches(String category, String origin, String tipo) {
    final catMatch = categories.isEmpty || categories.contains(category);
    final orgMatch = origins.isEmpty || origins.contains(origin);
    final tipoMatch = tipos.isEmpty || tipos.contains(tipo);
    return catMatch && orgMatch && tipoMatch;
  }

  @override
  bool operator ==(Object other) =>
      other is FilterSelection &&
      categories.length == other.categories.length &&
      origins.length == other.origins.length &&
      tipos.length == other.tipos.length &&
      categories.containsAll(other.categories) &&
      origins.containsAll(other.origins) &&
      tipos.containsAll(other.tipos);

  @override
  int get hashCode => Object.hash(categories, origins, tipos);
}

// ─── Filter button — place this in your header row ───────────────────────────
//
// Usage:
//   FilterButton(
//     selection: _filterSelection,
//     categories: _filterCategories,
//     origins: kFilterOrigins,
//     onApply: (sel) => setState(() => _filterSelection = sel),
//   )

class FilterButton extends StatelessWidget {
  final FilterSelection selection;
  final List<String> categories;
  final List<String> origins;
  final List<String> tipos;
  final ValueChanged<FilterSelection> onApply;

  const FilterButton({
    super.key,
    required this.selection,
    required this.categories,
    required this.origins,
    required this.tipos,
    required this.onApply,
  });

  void _open(BuildContext context) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _FilterSheet(
        initial: selection,
        categories: categories,
        origins: origins,
        tipos: tipos,
        onApply: onApply,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = selection.activeCount;
    final hasFilters = count > 0;

    return GestureDetector(
      onTap: () => _open(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: hasFilters
              ? AppColors.systemBlue.withValues(alpha: 0.14)
              : AppColors.white05,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: hasFilters
                ? AppColors.systemBlue.withValues(alpha: 0.40)
                : AppColors.white07,
            width: hasFilters ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.slider_horizontal_3,
              size: 13,
              color: hasFilters
                  ? AppColors.systemBlue
                  : AppColors.secondaryLabel,
            ),
            const SizedBox(width: 6),
            Text(
              hasFilters ? 'Filtrar · $count' : 'Filtrar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasFilters ? FontWeight.w600 : FontWeight.w400,
                color: hasFilters
                    ? AppColors.systemBlue
                    : AppColors.secondaryLabel,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter sheet ─────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final FilterSelection initial;
  final List<String> categories;
  final List<String> origins;
  final List<String> tipos;
  final ValueChanged<FilterSelection> onApply;

  const _FilterSheet({
    required this.initial,
    required this.categories,
    required this.origins,
    required this.tipos,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _cats;
  late Set<String> _orgs;
  late Set<String> _tipos;

  @override
  void initState() {
    super.initState();
    _cats = Set.from(widget.initial.categories);
    _orgs = Set.from(widget.initial.origins);
    _tipos = Set.from(widget.initial.tipos);
  }

  void _toggleCat(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_cats.contains(val)) {
        _cats.remove(val);
      } else {
        _cats.add(val);
      }
    });
  }

  void _toggleOrg(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_orgs.contains(val)) {
        _orgs.remove(val);
      } else {
        _orgs.add(val);
      }
    });
  }

  void _toggleTipo(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_tipos.contains(val)) {
        _tipos.remove(val);
      } else {
        _tipos.add(val);
      }
    });
  }

  void _clear() {
    HapticFeedback.selectionClick();
    setState(() {
      _cats.clear();
      _orgs.clear();
      _tipos.clear();
    });
  }

  void _apply() {
    widget.onApply(
      FilterSelection(
        categories: Set.from(_cats),
        origins: Set.from(_orgs),
        tipos: Set.from(_tipos),
      ),
    );
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  int get _activeCount => _cats.length + _orgs.length + _tipos.length;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.tertiaryLabel.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filtrar movimientos',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (_activeCount > 0)
                  GestureDetector(
                    onTap: _clear,
                    child: const Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.systemBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(height: 0.5, color: AppColors.separator),

          // ── Scrollable content ────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category section ──────────────────────────────────
                  _SectionLabel(
                    label: 'Categoría',
                    selectedCount: _cats.length,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.categories
                        .map(
                          (cat) => _SelectChip(
                            label: cat,
                            isSelected: _cats.contains(cat),
                            activeColor: AppColors.systemBlue,
                            onTap: () => _toggleCat(cat),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── Origin section ────────────────────────────────────
                  _SectionLabel(label: 'Origen', selectedCount: _orgs.length),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.origins
                        .map(
                          (org) => _SelectChip(
                            label: org,
                            isSelected: _orgs.contains(org),
                            activeColor: AppColors.systemGreen,
                            onTap: () => _toggleOrg(org),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── Tipo section ────────────────────────────────────
                  _SectionLabel(label: 'Tipo', selectedCount: _tipos.length),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.tipos
                        .map(
                          (tipo) => _SelectChip(
                            label: tipo == 'ingreso'
                                ? 'Ingreso'
                                : (tipo == 'egreso' ? 'Egreso' : tipo),
                            isSelected: _tipos.contains(tipo),
                            activeColor: tipo == 'ingreso'
                                ? AppColors.systemGreen
                                : AppColors.systemRed,
                            onTap: () => _toggleTipo(tipo),
                          ),
                        )
                        .toList(),
                  ),

                  // ── AND logic hint (only visible when both active) ─────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: _cats.isNotEmpty && _orgs.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white05,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.white07),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.info_circle,
                                    size: 14,
                                    color: AppColors.secondaryLabel,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Se muestran movimientos que coincidan con todas las selecciones.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryLabel,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Apply button ──────────────────────────────────────────────
          Container(height: 0.5, color: AppColors.separator),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 20),
            child: GestureDetector(
              onTap: _apply,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.systemBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _activeCount == 0
                        ? 'Ver todos los movimientos'
                        : 'Aplicar · $_activeCount filtro${_activeCount == 1 ? '' : 's'}',
                    style: const TextStyle(
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

// ─── Section label with active count badge ────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int selectedCount;

  const _SectionLabel({required this.label, required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppColors.secondaryLabel,
          ),
        ),
        if (selectedCount > 0) ...[
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.systemBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.systemBlue.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: Text(
              '$selectedCount',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.systemBlue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Selectable chip ──────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.14) : AppColors.white05,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.45)
                : AppColors.white07,
            width: isSelected ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(CupertinoIcons.checkmark, size: 11, color: activeColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : AppColors.secondaryLabel,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
