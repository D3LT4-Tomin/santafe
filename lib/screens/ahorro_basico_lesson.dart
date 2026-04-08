import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────
class AhorroBasicoLesson extends StatelessWidget {
  const AhorroBasicoLesson({super.key});

  static Route<void> route() => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const AhorroBasicoLesson(),
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

  int _correctFirst = 0;
  int _correctSecond = 0;

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

  void _setFirstResult(int correct) {
    setState(() => _correctFirst = correct);
  }

  void _setSecondResult(int correct) {
    setState(() => _correctSecond = correct);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF070D1A),
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
        return _Step1BinaryChoice(onAnswer: _setFirstResult, onNext: _advance);
      case 2:
        return _Step2RevealBinary(correct: _correctFirst > 0, onNext: _advance);
      case 3:
        return _Step3SingleChoice(onAnswer: _setSecondResult, onNext: _advance);
      case 4:
        return _Step4RevealWithPopUp(
          correct: _correctSecond > 0,
          onNext: _advance,
        );
      case 5:
        return _Step5Completion(
          correctFirst: _correctFirst,
          correctSecond: _correctSecond,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.systemGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.systemGreen.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.star_circle_fill,
                      color: AppColors.systemGreen,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ahorro\nBásico',
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
                      color: AppColors.systemGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Ahorrar no es lo que te sobra',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.systemGreen,
                        fontWeight: FontWeight.w500,
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
                          'La mayoría de las personas que ahorran exitosamente lo hacen ANTES de gastar, no después.',
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
                    'Hoy aprenderás a:\n• Cuándo y cuánto ahorrar\n• La regla del 10-20%\n• Crear tu primer plan de ahorro',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        _BottomButton(label: 'Empezar', onTap: widget.onNext),
      ],
    );
  }
}

// ─── Step 1: Binary choice (when to save) ────────────────────────────────────
class _Step1BinaryChoice extends StatefulWidget {
  final void Function(int correct) onAnswer;
  final VoidCallback onNext;
  const _Step1BinaryChoice({required this.onAnswer, required this.onNext});

  @override
  State<_Step1BinaryChoice> createState() => _Step1BinaryChoiceState();
}

class _Step1BinaryChoiceState extends State<_Step1BinaryChoice> {
  int? _selected;

  void _select(int index) {
    setState(() => _selected = index);
    HapticFeedback.selectionClick();
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAnswer(index == 1 ? 1 : 0);
      widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const _LessonHeader(
                  icon: CupertinoIcons.star_circle_fill,
                  color: AppColors.systemGreen,
                  title: 'Ahorro\nBásico',
                  subtitle: '¿Cuándo deberías ahorrar?',
                ),
                const SizedBox(height: 40),
                _BinaryOption(
                  label: 'Después de\ngastar',
                  icon: CupertinoIcons.arrow_down_circle,
                  color: AppColors.systemRed,
                  isSelected: _selected == 0,
                  onTap: _selected == null ? () => _select(0) : null,
                ),
                const SizedBox(height: 16),
                _BinaryOption(
                  label: 'Antes de\ngastar',
                  icon: CupertinoIcons.arrow_up_circle_fill,
                  color: AppColors.systemGreen,
                  isSelected: _selected == 1,
                  onTap: _selected == null ? () => _select(1) : null,
                ),
                const SizedBox(height: 40),
              ],
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

class _BinaryOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _BinaryOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.10),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.white38,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white60,
                  height: 1.3,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(
                  CupertinoIcons.checkmark,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: Reveal binary result ─────────────────────────────────────────────
class _Step2RevealBinary extends StatefulWidget {
  final bool correct;
  final VoidCallback onNext;
  const _Step2RevealBinary({required this.correct, required this.onNext});

  @override
  State<_Step2RevealBinary> createState() => _Step2RevealBinaryState();
}

class _Step2RevealBinaryState extends State<_Step2RevealBinary>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: widget.correct
                              ? AppColors.systemGreen.withValues(alpha: 0.15)
                              : AppColors.systemRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.correct
                                ? AppColors.systemGreen.withValues(alpha: 0.40)
                                : AppColors.systemRed.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Icon(
                          widget.correct
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.xmark_circle_fill,
                          color: widget.correct
                              ? AppColors.systemGreen
                              : AppColors.systemRed,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.correct ? '¡Correcto!' : 'Incorrecto',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: widget.correct
                              ? AppColors.systemGreen
                              : AppColors.systemRed,
                        ),
                      ),
                      if (widget.correct) ...[
                        const SizedBox(height: 8),
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
                          child: const Text(
                            '+4 pts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.systemGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.systemGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.systemGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.lightbulb_fill,
                            color: AppColors.systemYellow,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'La clave',
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
                        'Págate primero a ti mismo.\nAhorra antes de pagar cuentas,\ncomprar o gastar.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
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

// ─── Step 3: Single choice (how much to save) ────────────────────────────────
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
    _SingleOption(0, '\$50', false),
    _SingleOption(1, '\$100', true),
    _SingleOption(2, '\$0', false),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const _LessonHeader(
                  icon: CupertinoIcons.star_circle_fill,
                  color: AppColors.systemGreen,
                  title: 'Ahorro\nBásico',
                  subtitle: 'Si ganas \$1,000 mensuales...',
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    '¿Cuánto deberías ahorrar?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.systemGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '10% - 20% de tus ingresos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.systemGreen,
                      ),
                    ),
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
                                ? AppColors.systemGreen.withValues(alpha: 0.50)
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

// ─── Step 4: Reveal + Pop-up data ────────────────────────────────────────────
class _Step4RevealWithPopUp extends StatefulWidget {
  final bool correct;
  final VoidCallback onNext;
  const _Step4RevealWithPopUp({required this.correct, required this.onNext});

  @override
  State<_Step4RevealWithPopUp> createState() => _Step4RevealWithPopUpState();
}

class _Step4RevealWithPopUpState extends State<_Step4RevealWithPopUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  bool _showPopUp = false;

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
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showPopUp = true);
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
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                              ? '\$1,000 × 10% = \$100 al mes'
                              : 'La respuesta correcta es \$100',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.correct) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.systemGreen.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '+4 pts',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.systemGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_showPopUp)
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.systemBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.systemBlue.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.systemBlue.withValues(
                                    alpha: 0.20,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.chart_bar_fill,
                                  color: AppColors.systemBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Dato curioso',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.systemBlue,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _showPopUp = false),
                                child: const Icon(
                                  CupertinoIcons.xmark_circle_fill,
                                  color: Colors.white30,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Según datos de diferentes instituciones, se debe ahorrar entre el 10% y el 17% de nuestros ingresos mensuales.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ─── Step 5: Text input + completion ──────────────────────────────────────────
class _Step5Completion extends StatefulWidget {
  final int correctFirst;
  final int correctSecond;
  final VoidCallback onNext;
  const _Step5Completion({
    required this.correctFirst,
    required this.correctSecond,
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
      _pointsShown = (widget.correctFirst * 4) + (widget.correctSecond * 4) + 4;
    });
    HapticFeedback.mediumImpact();
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_textSubmitted) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const _LessonHeader(
                    icon: CupertinoIcons.star_circle_fill,
                    color: AppColors.systemGreen,
                    title: 'Ahorro\nBásico',
                    subtitle: 'Último paso...',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Empieza hoy con una cantidad pequeña...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Cuánto quieres ahorrar esta semana?',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Ej: \$100',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onSubmitted: (_) => _submitText(),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.systemGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.systemGreen.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.star_circle_fill,
                          color: AppColors.systemGreen,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ahorro\nBásico',
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
                          color: AppColors.systemGreen.withValues(alpha: 0.15),
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
                          'Poco a poco\ntu ahorro crecerá',
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
                              color: AppColors.systemGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Ahorrarás esta semana:',
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
                            color: AppColors.systemGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.systemPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.systemPurple.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.systemPurple.withValues(
                              alpha: 0.20,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.star_fill,
                            color: AppColors.systemPurple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Primer ahorro',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Nueva insignia desbloqueada',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// ─── Shared components ─────────────────────────────────────────────────────────

class _LessonHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _LessonHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.50),
            height: 1.4,
          ),
        ),
      ],
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
                ? AppColors.systemGreen
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
