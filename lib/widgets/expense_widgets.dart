import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/expense_data.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../screens/expense_detail_screen.dart';

class ExpenseRow extends StatelessWidget {
  final ExpenseData? data;
  final TransactionModel? transaction;

  const ExpenseRow({super.key, this.data, this.transaction});

  IconData get _icon {
    if (data != null) return data!.icon;
    final category = transaction?.category ?? '';
    if (category.contains('Comida')) return CupertinoIcons.cart_fill;
    if (category.contains('Transporte')) return CupertinoIcons.car_fill;
    if (category.contains('Suscripción')) return CupertinoIcons.film;
    if (category.contains('Salud')) return CupertinoIcons.heart_fill;
    if (category.contains('Entretenimiento'))
      return CupertinoIcons.gamecontroller_fill;
    if (category.contains('Servicios')) return CupertinoIcons.bolt_fill;
    if (category.contains('Salario') ||
        category.contains('Freelance') ||
        category.contains('Inversión') ||
        category.contains('Bono') ||
        category.contains('Venta'))
      return CupertinoIcons.money_dollar_circle_fill;
    return CupertinoIcons.bag_fill;
  }

  Color get _iconColor {
    if (data != null) return data!.iconColor;
    final tipo = transaction?.tipo ?? 'egreso';
    if (tipo == 'ingreso') return AppColors.systemGreen;
    final category = transaction?.category ?? '';
    if (category.contains('Comida')) return AppColors.systemOrange;
    if (category.contains('Transporte')) return AppColors.systemRed;
    if (category.contains('Suscripción') ||
        category.contains('Entretenimiento')) {
      return AppColors.systemPurple;
    }
    if (category.contains('Salud')) return AppColors.systemRed;
    if (category.contains('Servicios')) return AppColors.systemOrange;
    return AppColors.systemGreen;
  }

  String get _title {
    if (data != null) return data!.title;
    return transaction?.title ?? '';
  }

  String get _subtitle {
    if (data != null) return data!.subtitle;
    final t = transaction;
    if (t == null) return '';
    final category = t.category;
    final hour = t.createdAt.hour.toString().padLeft(2, '0');
    final minute = t.createdAt.minute.toString().padLeft(2, '0');
    return '$category · $hour:$minute';
  }

  String get _amount {
    if (data != null) return data!.amount;
    final amount = transaction?.amount ?? 0;
    final isIncome = amount > 0;
    final prefix = isIncome ? '+\$' : '-\$';
    return '$prefix${amount.abs().toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const ExpenseDetailScreen()),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _iconColor.withOpacity(0.15),
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                    ),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(_icon, color: _iconColor, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.32,
                            color: AppColors.label,
                            height: 1.31,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(_subtitle, style: AppTextStyles.caption1),
                      ],
                    ),
                  ),
                  Text(
                    _amount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.32,
                      color: AppColors.label,
                      height: 1.31,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 13,
                    color: AppColors.tertiaryLabel,
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 64),
            child: ColoredBox(
              color: AppColors.separator,
              child: SizedBox(height: 0.5, width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowMoreButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const ShowMoreButton({
    super.key,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.separator, width: 0.5),
          ),
        ),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  expanded ? 'Ver menos' : 'Ver más',
                  key: ValueKey(expanded),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.systemBlue,
                    letterSpacing: -0.08,
                    height: 1.38,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: const Icon(
                  CupertinoIcons.chevron_down,
                  size: 12,
                  color: AppColors.systemBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double? width;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: width,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.systemBlue : const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.systemBlue : const Color(0x1FFFFFFF),
            width: 0.5,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x400A84FF),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: -0.1,
              color: selected ? AppColors.label : AppColors.secondaryLabel,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

class PillPager extends StatelessWidget {
  final List<String> categories;
  final String selectedFilter;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onAddCategory;

  static const int _pillsPerPage = 3;
  static const double _pillGap = 8.0;
  static const double _addBtnWidth = 32.0;
  static const double _addBtnGap = 8.0;
  static const double _pillHeight = 32.0;

  const PillPager({
    super.key,
    required this.categories,
    required this.selectedFilter,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.onFilterSelected,
    required this.onAddCategory,
  });

  int _pageCount() => (categories.length / _pillsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pageViewWidth =
              constraints.maxWidth - _addBtnWidth - _addBtnGap;
          const interPageGap = 16.0;
          final pillWidth =
              ((pageViewWidth - interPageGap) -
                  (_pillsPerPage - 1) * _pillGap) /
              _pillsPerPage;
          final pageCount = _pageCount();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: pageViewWidth,
                    height: _pillHeight,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pageCount,
                      onPageChanged: onPageChanged,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, pageIndex) {
                        final start = pageIndex * _pillsPerPage;
                        final end = (start + _pillsPerPage).clamp(
                          0,
                          categories.length,
                        );
                        final pageCats = categories.sublist(start, end);

                        return Padding(
                          padding: const EdgeInsets.only(right: interPageGap),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (int i = 0; i < pageCats.length; i++) ...[
                                if (i > 0) const SizedBox(width: _pillGap),
                                FilterPill(
                                  label: pageCats[i],
                                  selected: selectedFilter == pageCats[i],
                                  width: pillWidth,
                                  onTap: () => onFilterSelected(pageCats[i]),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: _addBtnGap),
                  GestureDetector(
                    onTap: onAddCategory,
                    child: Container(
                      height: _pillHeight,
                      width: _addBtnWidth,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0x1FFFFFFF),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.plus,
                        size: 14,
                        color: AppColors.systemBlue,
                      ),
                    ),
                  ),
                ],
              ),
              if (pageCount > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < pageCount; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: currentPage == i
                              ? AppColors.systemBlue
                              : const Color(0x3DFFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class OriginPager extends StatelessWidget {
  final List<String> origins;
  final String selectedOrigin;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String> onOriginSelected;

  static const int _pillsPerPage = 4;
  static const double _pillGap = 8.0;
  static const double _pillHeight = 28.0;

  const OriginPager({
    super.key,
    required this.origins,
    required this.selectedOrigin,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.onOriginSelected,
  });

  int _pageCount() => (origins.length / _pillsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const interPageGap = 16.0;
          final pillWidth =
              (constraints.maxWidth -
                  interPageGap -
                  (_pillsPerPage - 1) * _pillGap) /
              _pillsPerPage;
          final pageCount = _pageCount();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _pillHeight,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pageCount,
                  onPageChanged: onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, pageIndex) {
                    final start = pageIndex * _pillsPerPage;
                    final end = (start + _pillsPerPage).clamp(
                      0,
                      origins.length,
                    );
                    final pageOrigins = origins.sublist(start, end);

                    return Padding(
                      padding: const EdgeInsets.only(right: interPageGap),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (int i = 0; i < pageOrigins.length; i++) ...[
                            if (i > 0) const SizedBox(width: _pillGap),
                            OriginPill(
                              label: pageOrigins[i],
                              selected: selectedOrigin == pageOrigins[i],
                              width: pillWidth,
                              onTap: () => onOriginSelected(pageOrigins[i]),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (pageCount > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < pageCount; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: currentPage == i
                              ? AppColors.systemBlue
                              : const Color(0x3DFFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class OriginPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  const OriginPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: width,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.systemGreen.withOpacity(0.2)
              : const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.systemGreen.withOpacity(0.5)
                : const Color(0x1FFFFFFF),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: -0.1,
              color: selected
                  ? AppColors.systemGreen
                  : AppColors.secondaryLabel,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
