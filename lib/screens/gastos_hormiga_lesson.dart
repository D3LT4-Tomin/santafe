import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/learning_provider.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────
// ─── Entry point ──────────────────────────────────────────────────────────────
class GastosHormigaLesson extends StatelessWidget {
  const GastosHormigaLesson({super.key});

  static Route<void> route() => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const GastosHormigaLesson(),
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
  static const int _totalSteps = 6;

  int _correctMultiChoice = 0;
  int _correctSingleChoice = 0;

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
      _completeAndExit();
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

  void _completeAndExit() {
    final totalPoints =
        ((_correctMultiChoice * 5) + (_correctSingleChoice * 5) + 5) * 10;
    context.read<LearningProvider>().completeLesson(
      'gastos_hormiga',
      totalPoints,
      badgeId: 'cazador_gastos',
    );
    Navigator.of(context).pop();
  }

  void _back() {
    Navigator.of(context).pop();
  }

  void _setMultiChoiceResult(int correct) {
    setState(() => _correctMultiChoice = correct);
  }

  void _setSingleChoiceResult(int correct) {
    setState(() => _correctSingleChoice = correct);
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
                      color: Colors.white54,
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
                                AppColors.systemOrange,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.bell,
                    color: Colors.white38,
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
        return _Step0Intro(onNext: _advance);
      case 1:
        return _Step1MultiChoice(
          onAnswer: _setMultiChoiceResult,
          onNext: _advance,
        );
      case 2:
        return _Step2RevealMulti(
          correctCount: _correctMultiChoice,
          onNext: _advance,
        );
      case 3:
        return _Step3SingleChoice(
          onAnswer: _setSingleChoiceResult,
          onNext: _advance,
        );
      case 4:
        return _Step4RevealSingle(
          correct: _correctSingleChoice > 0,
          onNext: _advance,
        );
      case 5:
        return _Step5Completion(
          correctMulti: _correctMultiChoice,
          correctSingle: _correctSingleChoice,
          onNext: _advance,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step 0: Introduction ─────────────────────────────────────────────────────
class _Step0Intro extends StatefulWidget {
  final VoidCallback onNext;
  const _Step0Intro({required this.onNext});

  @override
  State<_Step0Intro> createState() => _Step0IntroState();
}

class _Step0IntroState extends State<_Step0Intro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.systemOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.systemOrange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.ant_fill,
                        color: AppColors.systemOrange,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Gastos\nHormiga',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.systemOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'No son grandes compras...\nson pequeños hábitos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.systemOrange,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.lightbulb_fill,
                                color: Colors.white.withValues(alpha: 0.6),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '¿Sabías que...?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Los pequeños gastos diarios pueden sumar hasta \$1,500 pesos al mes sin que te des cuenta.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Hoy aprenderás a:\n• Identificar gastos hormiga\n• Calcular su impacto mensual\n• Crear un plan para reducirlos',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _BottomButton(label: 'Empezar', onTap: widget.onNext),
      ],
    );
  }
}

// ─── Step 1: Multi-choice (which are ant expenses) ────────────────────────────
class _Step1MultiChoice extends StatefulWidget {
  final void Function(int correct) onAnswer;
  final VoidCallback onNext;
  const _Step1MultiChoice({required this.onAnswer, required this.onNext});

  @override
  State<_Step1MultiChoice> createState() => _Step1MultiChoiceState();
}

class _Step1MultiChoiceState extends State<_Step1MultiChoice> {
  final Set<int> _selected = {};

  static const _choices = [
    _MultiChoiceItem(
      0,
      'Café\ndiario',
      CupertinoIcons.cloud_fill,
      AppColors.systemOrange,
      true,
    ),
    _MultiChoiceItem(
      1,
      'Renta',
      CupertinoIcons.house_fill,
      AppColors.systemGreen,
      false,
    ),
    _MultiChoiceItem(
      2,
      'Spotify',
      CupertinoIcons.music_note,
      AppColors.systemPurple,
      true,
    ),
    _MultiChoiceItem(
      3,
      'Gasolina',
      CupertinoIcons.car_fill,
      AppColors.systemGreen,
      false,
    ),
  ];

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _submit() {
    int correct = 0;
    for (final i in _selected) {
      if (_choices[i].isCorrect) correct++;
    }
    widget.onAnswer(correct);
    Future.delayed(const Duration(milliseconds: 300), widget.onNext);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.systemOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.systemOrange.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.ant_fill,
                      color: AppColors.systemOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Cuál es un\ngasto hormiga?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No son grandes compras... son pequeños hábitos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final count = 4;
                      const gap = 12.0;
                      final side = (constraints.maxWidth - gap) / 2;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: List.generate(count, (i) {
                          final item = _choices[i];
                          final isSelected = _selected.contains(i);
                          return GestureDetector(
                            onTap: () => _toggle(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: side,
                              height: side,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? item.color.withValues(alpha: 0.20)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? item.color.withValues(alpha: 0.60)
                                      : Colors.white.withValues(alpha: 0.10),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? item.color.withValues(alpha: 0.25)
                                          : Colors.white.withValues(
                                              alpha: 0.08,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: isSelected
                                          ? item.color
                                          : Colors.white38,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white60,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
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
        ),
        _BottomButton(
          label: 'Continuar',
          onTap: _selected.isNotEmpty ? _submit : null,
        ),
      ],
    );
  }
}

class _MultiChoiceItem {
  final int index;
  final String label;
  final IconData icon;
  final Color color;
  final bool isCorrect;
  const _MultiChoiceItem(
    this.index,
    this.label,
    this.icon,
    this.color,
    this.isCorrect,
  );
}

// ─── Step 2: Reveal multi-choice results ─────────────────────────────────────
class _Step2RevealMulti extends StatefulWidget {
  final int correctCount;
  final VoidCallback onNext;
  const _Step2RevealMulti({required this.correctCount, required this.onNext});

  @override
  State<_Step2RevealMulti> createState() => _Step2RevealMultiState();
}

class _Step2RevealMultiState extends State<_Step2RevealMulti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  static const _choices = [
    _RevealItem(
      'Café\ndiario',
      CupertinoIcons.cloud_fill,
      AppColors.systemOrange,
      true,
    ),
    _RevealItem(
      'Renta',
      CupertinoIcons.house_fill,
      AppColors.systemGreen,
      false,
    ),
    _RevealItem(
      'Spotify',
      CupertinoIcons.music_note,
      AppColors.systemPurple,
      true,
    ),
    _RevealItem(
      'Gasolina',
      CupertinoIcons.car_fill,
      AppColors.systemGreen,
      false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.correctCount * 5;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.systemGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '+$points pts',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.systemGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.systemOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.systemOrange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.ant_fill,
                        color: AppColors.systemOrange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Así están los\ngastos hormiga:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Café diario y Spotify son gastos hormiga porque:\n• Se repiten frecuentemente\n• Parecen pequeños pero suman mucho',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final count = 4;
                        const gap = 12.0;
                        final side = (constraints.maxWidth - gap) / 2;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: List.generate(count, (i) {
                            final item = _choices[i];
                            final delay = i * 0.1;
                            return AnimatedBuilder(
                              animation: _ctrl,
                              builder: (_, _) {
                                final t = ((_ctrl.value - delay) / (1 - delay))
                                    .clamp(0.0, 1.0);
                                final curve = Curves.easeOutCubic.transform(t);
                                return Opacity(
                                  opacity: curve,
                                  child: Transform.translate(
                                    offset: Offset(0, 10 * (1 - curve)),
                                    child: _RevealCard(
                                      item: item,
                                      wasSelected: item.isCorrect,
                                      width: side,
                                      height: side,
                                    ),
                                  ),
                                );
                              },
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
          ),
        ),
        _BottomButton(label: 'Continuar', onTap: widget.onNext),
      ],
    );
  }
}

// ─── Step 3: Single choice (calculation) ──────────────────────────────────────
class _Step3SingleChoice extends StatefulWidget {
  final void Function(int correct) onAnswer;
  final VoidCallback onNext;
  const _Step3SingleChoice({required this.onAnswer, required this.onNext});

  @override
  State<_Step3SingleChoice> createState() => _Step3SingleChoiceState();
}

class _Step3SingleChoiceState extends State<_Step3SingleChoice> {
  int? _selected;

  static const _options = [
    _SingleOption(0, '\$500', false),
    _SingleOption(1, '\$1,000', false),
    _SingleOption(2, '\$1,500', true),
  ];

  void _select(int index) {
    setState(() => _selected = index);
    HapticFeedback.selectionClick();
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAnswer(_options[index].isCorrect ? 1 : 0);
      widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.systemOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.systemOrange.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.ant_fill,
                      color: AppColors.systemOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Si gastas \$50 diarios...\n¿Cuánto es al mes?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(_options.length, (i) {
                    final option = _options[i];
                    final isSelected = _selected == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: _selected == null ? () => _select(i) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.systemGreen.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.systemGreen.withValues(
                                      alpha: 0.50,
                                    )
                                  : Colors.white.withValues(alpha: 0.10),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.systemGreen
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.systemGreen
                                        : Colors.white30,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        CupertinoIcons.checkmark,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                option.label,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        _BottomButton(
          label: 'Continuar',
          onTap: _selected != null ? () {} : null,
        ),
      ],
    );
  }
}

class _SingleOption {
  final int index;
  final String label;
  final bool isCorrect;
  const _SingleOption(this.index, this.label, this.isCorrect);
}

// ─── Step 4: Reveal single choice ────────────────────────────────────────────
class _Step4RevealSingle extends StatefulWidget {
  final bool correct;
  final VoidCallback onNext;
  const _Step4RevealSingle({required this.correct, required this.onNext});

  @override
  State<_Step4RevealSingle> createState() => _Step4RevealSingleState();
}

class _Step4RevealSingleState extends State<_Step4RevealSingle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.correct ? 5 : 0;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: widget.correct
                            ? AppColors.systemGreen.withValues(alpha: 0.15)
                            : AppColors.systemRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.correct
                              ? AppColors.systemGreen.withValues(alpha: 0.40)
                              : AppColors.systemRed.withValues(alpha: 0.40),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            widget.correct
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.xmark_circle_fill,
                            color: widget.correct
                                ? AppColors.systemGreen
                                : AppColors.systemRed,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.correct ? '¡Correcto!' : 'Incorrecto',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: widget.correct
                                  ? AppColors.systemGreen
                                  : AppColors.systemRed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.correct
                                ? '\$50 × 30 días = \$1,500 al mes'
                                : '\$50 × 30 días = \$1,500',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (points > 0)
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.systemGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+$points pts',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.systemGreen,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.lightbulb_fill,
                              color: AppColors.systemYellow,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Dato',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Un gasto de \$50 diarios suma \$18,250 al año. ¡Equivalente a un viaje!',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _BottomButton(label: 'Continuar', onTap: widget.onNext),
      ],
    );
  }
}

// ─── Step 5: Text input + completion ──────────────────────────────────────────
class _Step5Completion extends StatefulWidget {
  final int correctMulti;
  final int correctSingle;
  final VoidCallback onNext;
  const _Step5Completion({
    required this.correctMulti,
    required this.correctSingle,
    required this.onNext,
  });

  @override
  State<_Step5Completion> createState() => _Step5CompletionState();
}

class _Step5CompletionState extends State<_Step5Completion>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  bool _textSubmitted = false;
  int _pointsShown = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitText() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _textSubmitted = true;
      _pointsShown = (widget.correctMulti * 5) + (widget.correctSingle * 5) + 5;
    });
    HapticFeedback.mediumImpact();
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!_textSubmitted) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.systemOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.systemOrange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.ant_fill,
                        color: AppColors.systemOrange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Este mes, el gasto hormiga\nque reduciré será:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: CupertinoTextField(
                        controller: _controller,
                        placeholder: 'Ej: Café de \$50',
                        placeholderStyle: const TextStyle(
                          color: Colors.white30,
                          fontSize: 16,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: null,
                        padding: const EdgeInsets.all(16),
                        onSubmitted: (_) => _submitText(),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          _BottomButton(
            label: 'Guardar',
            onTap: _controller.text.trim().isNotEmpty ? _submitText : null,
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.systemOrange.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.systemOrange.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.ant_fill,
                            color: AppColors.systemOrange,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Gastos\nHormiga',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.systemGreen.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$_pointsShown pts',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.systemGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
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
                              color: Colors.white.withValues(alpha: 0.50),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Lo pequeño repetido\nes lo que más dinero consume',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                color: AppColors.systemOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Gasto que reducirás:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _controller.text.trim(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.systemOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PointsBadge(points: _pointsShown),
                        const SizedBox(width: 24),
                        _BadgeUnlocked(
                          badgeName: 'Cazador de\ngastos',
                          icon: CupertinoIcons.money_dollar_circle_fill,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        _BottomButton(label: 'Terminar lección', onTap: widget.onNext),
      ],
    );
  }
}

// ─── Hexagon widgets ───────────────────────────────────────────────────────────

class _HexPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  const _HexPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 1.5;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_HexPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}

class _PointsBadge extends StatelessWidget {
  final int points;
  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.goldAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.40),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.star_fill,
            color: AppColors.goldAccent,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            '$points',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Text(
            'pts',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeUnlocked extends StatelessWidget {
  final String badgeName;
  final IconData icon;
  const _BadgeUnlocked({required this.badgeName, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 120,
      child: CustomPaint(
        painter: _HexPainter(
          fillColor: AppColors.systemGreen.withValues(alpha: 0.15),
          borderColor: AppColors.systemGreen.withValues(alpha: 0.40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.systemGreen, size: 32),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                badgeName,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared components ─────────────────────────────────────────────────────────

class _RevealItem {
  final String label;
  final IconData icon;
  final Color color;
  final bool isCorrect;
  const _RevealItem(this.label, this.icon, this.color, this.isCorrect);
}

class _RevealCard extends StatelessWidget {
  final _RevealItem item;
  final bool wasSelected;
  final double width;
  final double height;

  const _RevealCard({
    required this.item,
    required this.wasSelected,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (item.isCorrect && wasSelected) {
      bgColor = AppColors.systemGreen.withValues(alpha: 0.15);
      borderColor = AppColors.systemGreen;
      textColor = AppColors.systemGreen;
    } else if (item.isCorrect && !wasSelected) {
      bgColor = AppColors.systemOrange.withValues(alpha: 0.15);
      borderColor = AppColors.systemOrange;
      textColor = AppColors.systemOrange;
    } else {
      bgColor = AppColors.systemRed.withValues(alpha: 0.10);
      borderColor = AppColors.systemRed.withValues(alpha: 0.40);
      textColor = AppColors.systemRed;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: textColor, size: 26),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(999),
              ),
              child: item.isCorrect
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      color: AppColors.systemGreen,
                      size: 10,
                    )
                  : const Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.systemRed,
                      size: 10,
                    ),
            ),
          ),
          if (item.isCorrect)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.systemGreen.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '+5',
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
    );
  }
}

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
                ? AppColors.systemOrange
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.white30,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
