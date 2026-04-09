import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────
class DondeSeVanLesson extends StatelessWidget {
  const DondeSeVanLesson({super.key});

  static Route<void> route() => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const DondeSeVanLesson(),
  );

  @override
  Widget build(BuildContext context) {
    return const _LessonShell();
  }
}

// ─── Shell: progress bar + step routing ──────────────────────────────────────
class _LessonShell extends StatefulWidget {
  const _LessonShell();

  @override
  State<_LessonShell> createState() => _LessonShellState();
}

class _LessonShellState extends State<_LessonShell>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  static const int _totalSteps = 5;

  String? _chosenCategory;

  final List<_RankItem> _rankItems = [
    _RankItem(
      label: 'Comida a domicilio',
      icon: CupertinoIcons.cart_fill,
      color: AppColors.systemOrange,
    ),
    _RankItem(
      label: 'Renta',
      icon: CupertinoIcons.house_fill,
      color: AppColors.systemGreen,
    ),
    _RankItem(
      label: 'Cine',
      icon: CupertinoIcons.film_fill,
      color: AppColors.systemPurple,
    ),
    _RankItem(
      label: 'Luz',
      icon: CupertinoIcons.bolt_fill,
      color: AppColors.systemYellow,
    ),
  ];

  late final AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _progressAnim = Tween<double>(begin: 0, end: 1 / _totalSteps).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _advance() {
    if (_step >= _totalSteps - 1) {
      Navigator.of(context).pop();
      return;
    }
    final nextStep = _step + 1;
    final begin = _progressAnim.value;
    final end = (nextStep + 1) / _totalSteps;
    _progressAnim = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward(from: 0);
    setState(() => _step = nextStep);
    HapticFeedback.lightImpact();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    final prevStep = _step - 1;
    final begin = _progressAnim.value;
    final end = (prevStep + 1) / _totalSteps;
    _progressAnim = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward(from: 0);
    setState(() => _step = prevStep);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.lessonBackground,
      body: Column(
        children: [
          SizedBox(
            height: top + 56,
            child: Padding(
              padding: EdgeInsets.only(top: top, left: 8, right: 16),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: _back,
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.tertiaryLabel,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          height: 6,
                          child: AnimatedBuilder(
                            animation: _progressAnim,
                            builder: (_, _) => LinearProgressIndicator(
                              value: _progressAnim.value,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.10,
                              ),
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.systemGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.bell,
                    color: AppColors.tertiaryLabel,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _Step0MultiChoice(
          onAnswer: (cat) {
            setState(() => _chosenCategory = cat);
            Future.delayed(const Duration(milliseconds: 300), _advance);
          },
        );
      case 1:
        return _Step1Reveal(onNext: _advance);
      case 2:
        return _Step2Rank(
          items: _rankItems,
          onNext: _advance,
          isSelecting: true,
        );
      case 3:
        return _Step2Rank(
          items: _rankItems,
          onNext: _advance,
          isSelecting: false,
        );
      case 4:
        return _Step4Completion(onNext: _advance);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Shared lesson header ─────────────────────────────────────────────────────
class _LessonHeader extends StatelessWidget {
  const _LessonHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.systemGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.systemGreen.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: const Icon(
            CupertinoIcons.money_dollar_circle_fill,
            color: AppColors.systemGreen,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '¿A dónde se van\ntus ahorros?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu dinero se va más rápido de lo que crees...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.label.withValues(alpha: 0.45),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─── Step 0: Multiple choice grid ────────────────────────────────────────────
class _Step0MultiChoice extends StatefulWidget {
  final ValueChanged<String> onAnswer;
  const _Step0MultiChoice({required this.onAnswer});

  @override
  State<_Step0MultiChoice> createState() => _Step0MultiChoiceState();
}

class _Step0MultiChoiceState extends State<_Step0MultiChoice> {
  String? _selected;

  static const _choices = [
    _Choice('Comida', CupertinoIcons.cart_fill, AppColors.systemOrange),
    _Choice('Ocio', CupertinoIcons.gamecontroller_fill, AppColors.systemPurple),
    _Choice(
      'Servicios',
      CupertinoIcons.bolt_circle_fill,
      AppColors.systemGreen,
    ),
    _Choice('Transporte', CupertinoIcons.car_fill, AppColors.systemGreen),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const _LessonHeader(),
          const SizedBox(height: 36),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '¿En qué crees que gastas más?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: _choices.map((c) {
              final selected = _selected == c.label;
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = c.label);
                  HapticFeedback.selectionClick();
                  widget.onAnswer(c.label);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: selected
                        ? c.color.withValues(alpha: 0.20)
                        : AppColors.label.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? c.color.withValues(alpha: 0.60)
                          : AppColors.label.withValues(alpha: 0.10),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(c.icon, color: c.color, size: 26),
                      const SizedBox(height: 8),
                      Text(
                        c.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Choice {
  final String label;
  final IconData icon;
  final Color color;
  const _Choice(this.label, this.icon, this.color);
}

// ─── Step 1: Reveal / info ────────────────────────────────────────────────────
class _Step1Reveal extends StatefulWidget {
  final VoidCallback onNext;
  const _Step1Reveal({required this.onNext});

  @override
  State<_Step1Reveal> createState() => _Step1RevealState();
}

class _Step1RevealState extends State<_Step1Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _items = [
    _RevealItem(
      'Comida',
      '\$120',
      AppColors.systemOrange,
      CupertinoIcons.cart_fill,
    ),
    _RevealItem(
      'Lista',
      '\$40',
      AppColors.systemGreen,
      CupertinoIcons.list_bullet,
    ),
    _RevealItem(
      'Servicios\nMúsica',
      '\$15',
      AppColors.systemPurple,
      CupertinoIcons.music_note,
    ),
    _RevealItem(
      'Transporte\nUber',
      '\$80',
      AppColors.systemGreen,
      CupertinoIcons.car_fill,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const _LessonHeader(),
                const SizedBox(height: 36),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pequeñas gastos = gran impacto',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ── Fixed 2×2 grid using GridView ──────────────────────────
                // childAspectRatio drives the cell height; 1.3 gives a
                // comfortable card that always fits its content.
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: List.generate(_items.length, (i) {
                    final item = _items[i];
                    final delay = i * 0.12;
                    return AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, _) {
                        final t = ((_ctrl.value - delay) / (1 - delay)).clamp(
                          0.0,
                          1.0,
                        );
                        final curve = Curves.easeOutCubic.transform(t);
                        return Opacity(
                          opacity: curve,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - curve)),
                            // ── The card itself is a Stack that fills the
                            //    entire grid cell. StackFit.expand ensures
                            //    the inner Container stretches to the cell
                            //    bounds, and the badge is Positioned on top.
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Main card
                                Container(
                                  decoration: BoxDecoration(
                                    color: item.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: item.color.withValues(alpha: 0.30),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        item.icon,
                                        color: item.color,
                                        size: 22,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white.withValues(
                                                alpha: 0.60,
                                              ),
                                              height: 1.3,
                                            ),
                                          ),
                                          Text(
                                            item.amount,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // +2pt badge — overlaid in top-right corner
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.systemGreen.withValues(
                                        alpha: 0.20,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.systemGreen.withValues(
                                          alpha: 0.40,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      '+2pt',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.systemGreen,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _BottomButton(label: 'Continuar', onTap: widget.onNext),
      ],
    );
  }
}

class _RevealItem {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;
  const _RevealItem(this.label, this.amount, this.color, this.icon);
}

// ─── Step 2 & 3: Rank list ────────────────────────────────────────────────────
class _RankItem {
  final String label;
  final IconData icon;
  final Color color;
  bool selected;
  int? rank;

  _RankItem({
    required this.label,
    required this.icon,
    required this.color,
    this.selected = false,
    this.rank,
  });
}

class _Step2Rank extends StatefulWidget {
  final List<_RankItem> items;
  final VoidCallback onNext;
  final bool isSelecting;

  const _Step2Rank({
    required this.items,
    required this.onNext,
    required this.isSelecting,
  });

  @override
  State<_Step2Rank> createState() => _Step2RankState();
}

class _Step2RankState extends State<_Step2Rank> {
  int _rankCounter = 1;

  static const _pointBadges = ['+2pt', '+1pt', '+2pt', '+1pt'];
  static const _revealColors = [
    AppColors.systemOrange,
    AppColors.systemGreen,
    AppColors.systemPurple,
    AppColors.systemYellow,
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.isSelecting) {
      for (var i = 0; i < widget.items.length; i++) {
        widget.items[i].selected = true;
        widget.items[i].rank = i + 1;
      }
    }
  }

  void _toggle(int index) {
    setState(() {
      final item = widget.items[index];
      if (item.selected) {
        final removedRank = item.rank!;
        item.selected = false;
        item.rank = null;
        _rankCounter--;
        for (final other in widget.items) {
          if (other.selected && other.rank! > removedRank) {
            other.rank = other.rank! - 1;
          }
        }
      } else {
        item.selected = true;
        item.rank = _rankCounter++;
      }
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final canAdvance = widget.isSelecting
        ? widget.items.any((i) => i.selected)
        : true;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const _LessonHeader(),
                const SizedBox(height: 36),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecciona los gastos frecuentes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // ── Use LayoutBuilder so each square is exactly
                //    (totalWidth - gaps) / itemCount on each side ──────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final count = widget.items.length;
                    const gap = 8.0;
                    final side =
                        (constraints.maxWidth - gap * (count - 1)) / count;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(count, (i) {
                        final item = widget.items[i];
                        final isSelected = item.selected;
                        final color = widget.isSelecting
                            ? item.color
                            : _revealColors[i];
                        final badge = !widget.isSelecting
                            ? _pointBadges[i]
                            : null;

                        return Padding(
                          padding: EdgeInsets.only(
                            right: i < count - 1 ? gap : 0,
                          ),
                          child: GestureDetector(
                            onTap: widget.isSelecting ? () => _toggle(i) : null,
                            child: SizedBox(
                              width: side,
                              height: side,
                              child: Stack(
                                children: [
                                  // Square card — fills the SizedBox
                                  Positioned.fill(
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color.withValues(alpha: 0.18)
                                            : Colors.white.withValues(
                                                alpha: 0.06,
                                              ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? color.withValues(alpha: 0.50)
                                              : Colors.white.withValues(
                                                  alpha: 0.10,
                                                ),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? color.withValues(
                                                      alpha: 0.25,
                                                    )
                                                  : Colors.white.withValues(
                                                      alpha: 0.08,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child:
                                                  isSelected &&
                                                      item.rank != null
                                                  ? Text(
                                                      '${item.rank}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: color,
                                                      ),
                                                    )
                                                  : Icon(
                                                      item.icon,
                                                      color: isSelected
                                                          ? color
                                                          : AppColors.tertiaryLabel,
                                                      size: 18,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Text(
                                              item.label,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.label
                                                    : AppColors.label.withValues(alpha: 0.6),
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Point badge — sits on top of the card
                                  if (badge != null)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.systemGreen
                                              .withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: AppColors.systemGreen
                                                .withValues(alpha: 0.40),
                                          ),
                                        ),
                                        child: Text(
                                          badge,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.systemGreen,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _BottomButton(
          label: 'Continuar',
          onTap: canAdvance ? widget.onNext : null,
        ),
      ],
    );
  }
}

// ─── Step 4: Completion ───────────────────────────────────────────────────────
class _Step4Completion extends StatefulWidget {
  final VoidCallback onNext;
  const _Step4Completion({required this.onNext});

  @override
  State<_Step4Completion> createState() => _Step4CompletionState();
}

class _Step4CompletionState extends State<_Step4Completion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _fade,
                  builder: (_, _) => Opacity(
                    opacity: _fade.value,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.systemGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.systemGreen.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.money_dollar_circle_fill,
                          color: AppColors.systemGreen,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¿A dónde se van\ntus ahorros?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu dinero se va más rápido de lo que crees...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.label.withValues(alpha: 0.45),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                Container(
                  height: 1,
                  color: AppColors.label.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 28),

                FadeTransition(
                  opacity: _fade,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.label.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.label.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recuerda:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label.withValues(alpha: 0.50),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No es cuánto ganas,\nes cómo gastas.\nEsta semana revisa tus gastos.',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                ScaleTransition(
                  scale: _scale,
                  child: Row(
                    children: [
                      Expanded(
                        child: _CompletionBadge(
                          icon: CupertinoIcons.star_fill,
                          color: AppColors.goldAccent,
                          label: '10\npuntos',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CompletionBadge(
                          icon: CupertinoIcons.flame_fill,
                          color: AppColors.systemOrange,
                          label: 'Racha\nactiva',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        _BottomButton(label: 'Terminar lección', onTap: widget.onNext),
      ],
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _CompletionBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared bottom button ─────────────────────────────────────────────────────
class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _BottomButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final enabled = onTap != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 20),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.systemGreen
                : AppColors.label.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : AppColors.label.withValues(alpha: 0.3),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
