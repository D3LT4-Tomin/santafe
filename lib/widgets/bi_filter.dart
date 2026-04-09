import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// ─── BiFilter ─────────────────────────────────────────────────────────────────
//
// Drop-in replacement for the PillPager + OriginPager pair.
// Renders two labeled horizontal pill rows — category on top, origin below —
// with independent selection state and an optional "+ add" button on the
// category row.
//
// Usage in dashboard_screen.dart:
//
//   BiFilter(
//     categories: _filterCategories,
//     origins: kFilterOrigins,
//     selectedCategory: _selectedFilter,
//     selectedOrigin: _selectedOrigin,
//     onCategorySelected: (cat) { ... },
//     onOriginSelected: (org) { ... },
//     onAddCategory: _showAddCategorySheet,   // optional
//   ),
//
// ─────────────────────────────────────────────────────────────────────────────

class BiFilter extends StatefulWidget {
  final List<String> categories;
  final List<String> origins;
  final String selectedCategory;
  final String selectedOrigin;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onOriginSelected;
  final VoidCallback? onAddCategory;

  const BiFilter({
    super.key,
    required this.categories,
    required this.origins,
    required this.selectedCategory,
    required this.selectedOrigin,
    required this.onCategorySelected,
    required this.onOriginSelected,
    this.onAddCategory,
  });

  @override
  State<BiFilter> createState() => _BiFilterState();
}

class _BiFilterState extends State<BiFilter> {
  late final ScrollController _catScroll;
  late final ScrollController _orgScroll;

  @override
  void initState() {
    super.initState();
    _catScroll = ScrollController();
    _orgScroll = ScrollController();
  }

  @override
  void dispose() {
    _catScroll.dispose();
    _orgScroll.dispose();
    super.dispose();
  }

  // Scroll the selected pill into view whenever selection changes externally.
  @override
  void didUpdateWidget(BiFilter old) {
    super.didUpdateWidget(old);
    if (old.selectedCategory != widget.selectedCategory) {
      _scrollToSelected(_catScroll, widget.categories, widget.selectedCategory);
    }
    if (old.selectedOrigin != widget.selectedOrigin) {
      _scrollToSelected(_orgScroll, widget.origins, widget.selectedOrigin);
    }
  }

  void _scrollToSelected(
    ScrollController ctrl,
    List<String> items,
    String selected,
  ) {
    final idx = items.indexOf(selected);
    if (idx < 0 || !ctrl.hasClients) return;
    // Rough estimate: pill width ≈ label chars * 8 + 32 padding
    const approxPillWidth = 80.0;
    final target = (idx * approxPillWidth - 24).clamp(
      0.0,
      ctrl.position.maxScrollExtent,
    );
    ctrl.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterRow(
          rowLabel: 'Categoría',
          items: widget.categories,
          selected: widget.selectedCategory,
          scrollController: _catScroll,
          activeColor: AppColors.systemGreen,
          onSelected: (val) {
            HapticFeedback.selectionClick();
            widget.onCategorySelected(val);
          },
          trailingWidget: widget.onAddCategory != null
              ? _AddPill(onTap: widget.onAddCategory!)
              : null,
        ),
        const SizedBox(height: 10),
        _FilterRow(
          rowLabel: 'Origen',
          items: widget.origins,
          selected: widget.selectedOrigin,
          scrollController: _orgScroll,
          activeColor: AppColors.systemGreen,
          onSelected: (val) {
            HapticFeedback.selectionClick();
            widget.onOriginSelected(val);
          },
        ),
      ],
    );
  }
}

// ─── Single labeled pill row ──────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String rowLabel;
  final List<String> items;
  final String selected;
  final ScrollController scrollController;
  final Color activeColor;
  final ValueChanged<String> onSelected;
  final Widget? trailingWidget;

  const _FilterRow({
    required this.rowLabel,
    required this.items,
    required this.selected,
    required this.scrollController,
    required this.activeColor,
    required this.onSelected,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row label
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 6),
          child: Text(
            rowLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: AppColors.secondaryLabel,
              height: 1.3,
            ),
          ),
        ),
        // Scrollable pill bar
        SizedBox(
          height: 34,
          child: ListView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Pill(
                    label: item,
                    isActive: selected == item,
                    activeColor: activeColor,
                    onTap: () => onSelected(item),
                  ),
                ),
              ),
              ?trailingWidget,
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Individual pill ──────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.15)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.45)
                : AppColors.black07,
            width: isActive ? 1.0 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? activeColor : AppColors.secondaryLabel,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─── + Add category pill ──────────────────────────────────────────────────────

class _AddPill extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.black07, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              CupertinoIcons.plus,
              size: 12,
              color: AppColors.secondaryLabel,
            ),
            SizedBox(width: 4),
            Text(
              'Añadir',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryLabel,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
