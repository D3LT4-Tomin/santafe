import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// ─── Filter state ─────────────────────────────────────────────────────────────

class FilterSelection {
  final Set<String> categories;
  final Set<String> origins;
  final Set<String> tipos;
  final Set<String> years;
  final Set<String> months;

  const FilterSelection({
    this.categories = const {},
    this.origins = const {},
    this.tipos = const {},
    this.years = const {},
    this.months = const {},
  });

  FilterSelection copyWith({
    Set<String>? categories,
    Set<String>? origins,
    Set<String>? tipos,
    Set<String>? years,
    Set<String>? months,
  }) => FilterSelection(
    categories: categories ?? this.categories,
    origins: origins ?? this.origins,
    tipos: tipos ?? this.tipos,
    years: years ?? this.years,
    months: months ?? this.months,
  );

  int get activeCount =>
      categories.length +
      origins.length +
      tipos.length +
      years.length +
      months.length;
  bool get isEmpty =>
      categories.isEmpty &&
      origins.isEmpty &&
      tipos.isEmpty &&
      years.isEmpty &&
      months.isEmpty;

  bool matches(String category, String origin, String tipo, DateTime date) {
    final catMatch = categories.isEmpty || categories.contains(category);
    final orgMatch = origins.isEmpty || origins.contains(origin);
    final tipoMatch = tipos.isEmpty || tipos.contains(tipo);
    final yearMatch = years.isEmpty || years.contains(date.year.toString());
    final monthMatch =
        months.isEmpty || months.contains(_monthName(date.month));
    return catMatch && orgMatch && tipoMatch && yearMatch && monthMatch;
  }

  String _monthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month - 1];
  }

  @override
  bool operator ==(Object other) =>
      other is FilterSelection &&
      categories.length == other.categories.length &&
      origins.length == other.origins.length &&
      tipos.length == other.tipos.length &&
      years.length == other.years.length &&
      months.length == other.months.length &&
      categories.containsAll(other.categories) &&
      origins.containsAll(other.origins) &&
      tipos.containsAll(other.tipos) &&
      years.containsAll(other.years) &&
      months.containsAll(other.months);

  @override
  int get hashCode => Object.hash(categories, origins, tipos, years, months);
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
    final hasFilters = selection.activeCount > 0;

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        decoration: BoxDecoration(
          color: hasFilters
              ? AppColors.systemGreen.withValues(alpha: 0.12)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: hasFilters
                ? AppColors.systemGreen.withValues(alpha: 0.35)
                : AppColors.black07,
            width: hasFilters ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: 14,
                    color: hasFilters
                        ? AppColors.systemGreen
                        : AppColors.secondaryLabel,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    hasFilters ? 'Filtrar' : 'Filtrar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasFilters
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: hasFilters
                          ? AppColors.systemGreen
                          : AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.systemGreen.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${selection.activeCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.systemGreen,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
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
        years: widget.initial.years,
        months: widget.initial.months,
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
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.systemGreen,
                        fontWeight: FontWeight.w600,
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
                            activeColor: AppColors.systemGreen,
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
                  if (_cats.isNotEmpty && _orgs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.black07),
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
                  color: AppColors.systemGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_activeCount > 0)
                        Container(
                          padding: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColors.label,
                                width: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            '$_activeCount',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.systemGreen,
                            ),
                          ),
                        ),
                      Text(
                        _activeCount == 0
                            ? 'Ver todos los movimientos'
                            : 'Aplicar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.systemGreen,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
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
              color: AppColors.systemGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.systemGreen.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: Text(
              '$selectedCount',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.systemGreen,
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
          color: isSelected
              ? activeColor.withValues(alpha: 0.14)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.45)
                : AppColors.black07,
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

// ─── Date Filter Button ───────────────────────────────────────────────────────

class DateFilterButton extends StatelessWidget {
  final FilterSelection selection;
  final ValueChanged<FilterSelection> onApply;

  const DateFilterButton({
    super.key,
    required this.selection,
    required this.onApply,
  });

  void _open(BuildContext context) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => DateFilterSheet(initial: selection, onApply: onApply),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDateFilters =
        selection.years.isNotEmpty || selection.months.isNotEmpty;

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        decoration: BoxDecoration(
          color: hasDateFilters
              ? AppColors.systemOrange.withValues(alpha: 0.12)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: hasDateFilters
                ? AppColors.systemOrange.withValues(alpha: 0.35)
                : AppColors.black07,
            width: hasDateFilters ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 14,
                    color: hasDateFilters
                        ? AppColors.systemOrange
                        : AppColors.secondaryLabel,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    hasDateFilters ? 'Fecha' : 'Fecha',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasDateFilters
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: hasDateFilters
                          ? AppColors.systemOrange
                          : AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (hasDateFilters) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.systemOrange.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${selection.years.length + selection.months.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.systemOrange,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Date Filter Sheet ─────────────────────────────────────────────────────────

class DateFilterSheet extends StatefulWidget {
  final FilterSelection initial;
  final ValueChanged<FilterSelection> onApply;

  const DateFilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<DateFilterSheet> {
  late Set<String> _years;
  late Set<String> _months;

  @override
  void initState() {
    super.initState();
    _years = Set.from(widget.initial.years);
    _months = Set.from(widget.initial.months);
  }

  void _toggleYear(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_years.contains(val)) {
        _years.remove(val);
      } else {
        _years.add(val);
      }
    });
  }

  void _toggleMonth(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_months.contains(val)) {
        _months.remove(val);
      } else {
        _months.add(val);
      }
    });
  }

  void _clear() {
    HapticFeedback.selectionClick();
    setState(() {
      _years.clear();
      _months.clear();
    });
  }

  void _apply() {
    widget.onApply(
      FilterSelection(
        categories: widget.initial.categories,
        origins: widget.initial.origins,
        tipos: widget.initial.tipos,
        years: Set.from(_years),
        months: Set.from(_months),
      ),
    );
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  int get _activeCount => _years.length + _months.length;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final now = DateTime.now();
    final years = List.generate(5, (i) => (now.year - i).toString());
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

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

          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filtrar por fecha',
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
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.systemGreen,
                        fontWeight: FontWeight.w600,
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
                  // ── Year section ────────────────────────────────────
                  _SectionLabel(label: 'Año', selectedCount: _years.length),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: years
                        .map(
                          (year) => _SelectChip(
                            label: year,
                            isSelected: _years.contains(year),
                            activeColor: AppColors.systemPurple,
                            onTap: () => _toggleYear(year),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── Month section ────────────────────────────────────
                  _SectionLabel(label: 'Mes', selectedCount: _months.length),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: months
                        .map(
                          (month) => _SelectChip(
                            label: month,
                            isSelected: _months.contains(month),
                            activeColor: AppColors.systemOrange,
                            onTap: () => _toggleMonth(month),
                          ),
                        )
                        .toList(),
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
                  color: AppColors.systemOrange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_activeCount > 0)
                        Container(
                          padding: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColors.label,
                                width: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            '$_activeCount',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.systemOrange,
                            ),
                          ),
                        ),
                      Text(
                        _activeCount == 0
                            ? 'Ver todos los movimientos'
                            : 'Aplicar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.systemOrange,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
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
