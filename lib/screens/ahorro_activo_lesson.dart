import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, Colors;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';

class AhorroActivoLesson extends StatefulWidget {
  const AhorroActivoLesson({super.key});

  @override
  State<AhorroActivoLesson> createState() => _AhorroActivoLessonState();
}

class _AhorroActivoLessonState extends State<AhorroActivoLesson>
    with TickerProviderStateMixin {
  int _score = 0;
  int _timeRemaining = 60;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _gameComplete = false;
  Timer? _timer;

  // Card animation – same easing family as dashboard _appearAnim
  late AnimationController _cardController;
  late Animation<Offset> _cardSlideAnim;
  late Animation<double> _cardFadeAnim;
  int _currentCardIndex = 0;

  // ── Blob animations (mirrors DashboardScreen exactly) ──────────────────────
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;

  // ── Appear animation (mirrors DashboardScreen exactly) ─────────────────────
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  final List<_ExpenseItem> _expenses = [
    _ExpenseItem(
      name: 'Electricidad',
      amount: 120,
      isNeed: true,
      category: 'bill',
    ),
    _ExpenseItem(
      name: 'Netflix',
      amount: 15,
      isNeed: false,
      category: 'subscription',
    ),
    _ExpenseItem(name: 'Renta', amount: 800, isNeed: true, category: 'housing'),
    _ExpenseItem(
      name: 'Cine',
      amount: 25,
      isNeed: false,
      category: 'entertainment',
    ),
    _ExpenseItem(
      name: 'Comida',
      amount: 150,
      isNeed: true,
      category: 'groceries',
    ),
    _ExpenseItem(
      name: 'Videojuegos',
      amount: 60,
      isNeed: false,
      category: 'gaming',
    ),
    _ExpenseItem(name: 'Agua', amount: 45, isNeed: true, category: 'bill'),
    _ExpenseItem(
      name: 'Restaurant',
      amount: 85,
      isNeed: false,
      category: 'dining',
    ),
    _ExpenseItem(
      name: 'Transporte',
      amount: 50,
      isNeed: true,
      category: 'transport',
    ),
    _ExpenseItem(
      name: 'Ropa nueva',
      amount: 120,
      isNeed: false,
      category: 'shopping',
    ),
    _ExpenseItem(name: 'Internet', amount: 70, isNeed: true, category: 'bill'),
    _ExpenseItem(
      name: 'Spotify',
      amount: 10,
      isNeed: false,
      category: 'subscription',
    ),
    _ExpenseItem(
      name: 'Medicamentos',
      amount: 35,
      isNeed: true,
      category: 'health',
    ),
    _ExpenseItem(
      name: 'Cerveza',
      amount: 30,
      isNeed: false,
      category: 'social',
    ),
    _ExpenseItem(
      name: 'Gasolina',
      amount: 60,
      isNeed: true,
      category: 'transport',
    ),
  ];

  List<_ExpenseItem> _shuffledExpenses = [];
  static const _progressKey = 'ahorro_activo_progress';

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_progressKey) ?? 0;
      if (savedIndex > 0 && savedIndex < _expenses.length) {
        setState(() {
          _currentCardIndex = savedIndex;
          _totalAnswered = savedIndex;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_progressKey, _currentCardIndex);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _shuffledExpenses = List.from(_expenses)..shuffle(Random());
    _loadProgress();

    // ── Blobs (25 s / 18 s, same as DashboardScreen) ──────────────────────
    _blob1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _blob2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _blob1Anim = CurvedAnimation(
      parent: _blob1Controller,
      curve: Curves.easeInOut,
    );
    _blob2Anim = CurvedAnimation(
      parent: _blob2Controller,
      curve: Curves.easeInOut,
    );

    // ── Appear (600 ms spring, same cubic as DashboardScreen) ─────────────
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _appearController.forward();

    _startTimer();
    _setupCardAnimation();
  }

  void _setupCardAnimation() {
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
        );
    _cardFadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0 || _totalAnswered >= _shuffledExpenses.length) {
          _gameComplete = true;
          timer.cancel();
        }
      });
    });
  }

  void _answer(bool isNeed) {
    if (_gameComplete) return;
    HapticFeedback.mediumImpact();
    final currentItem = _shuffledExpenses[_currentCardIndex];
    final isCorrect = currentItem.isNeed == isNeed;

    setState(() {
      _totalAnswered++;
      if (isCorrect) {
        _score += isNeed ? 150 : 100;
        _correctAnswers++;
      } else {
        _score = (_score - 50).clamp(0, 9999);
      }
      if (_totalAnswered >= _shuffledExpenses.length || _timeRemaining <= 0) {
        _gameComplete = true;
        _timer?.cancel();
        _saveProgress();
      } else {
        _currentCardIndex = _totalAnswered;
        _cardController.reset();
        _cardController.forward();
        _saveProgress();
      }
    });
  }

  Future<void> _restartGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey, 0);
    setState(() {
      _score = 0;
      _timeRemaining = 60;
      _correctAnswers = 0;
      _totalAnswered = 0;
      _gameComplete = false;
      _currentCardIndex = 0;
      _shuffledExpenses = List.from(_expenses)..shuffle(Random());
    });
    _appearController.reset();
    _appearController.forward();
    _cardController.reset();
    _cardController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cardController.dispose();
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      child: Stack(
        children: [
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.systemBackground.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: AppColors.label,
                  size: 18,
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: _gameComplete
                    ? _buildCompletionScreen()
                    : _buildGameScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Game screen ────────────────────────────────────────────────────────────

  Widget _buildGameScreen() {
    final currentItem = _shuffledExpenses[_currentCardIndex];
    final progress = _totalAnswered / _shuffledExpenses.length;

    return Column(
      children: [
        _buildHeader(progress),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVaults(),
              const SizedBox(height: 32),
              SlideTransition(
                position: _cardSlideAnim,
                child: FadeTransition(
                  opacity: _cardFadeAnim,
                  child: _buildExpenseCard(currentItem),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  // Uses the same section-label typography as "GASTOS RECIENTES" in dashboard.

  Widget _buildHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                icon: CupertinoIcons.timer,
                value: _formatTime(_timeRemaining),
                color: _timeRemaining <= 10
                    ? AppColors.systemRed
                    : AppColors.systemGreen,
              ),
              // Progress counter – same style as dashboard section labels
              Text(
                '$_totalAnswered / ${_shuffledExpenses.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.secondaryLabel,
                ),
              ),
              _buildStatChip(
                icon: CupertinoIcons.star_fill,
                value: '$_score XP',
                color: AppColors.systemPurple,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar – same ClipRRect + LinearProgressIndicator as original,
          // but height raised to 6 px for better visibility.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.black07,
              valueColor: const AlwaysStoppedAnimation(AppColors.systemGreen),
            ),
          ),
        ],
      ),
    );
  }

  // Stat chip – same surface treatment as dashboard cards (white05 fill,
  // white07 border) with a colored tint overlay for the active color.
  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black07),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Vault cards ────────────────────────────────────────────────────────────
  // Reuses the same glassmorphism surface as dashboard expense list:
  // white05 fill + white07 border + rounded-16 corners.

  Widget _buildVaults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildVault(
              icon: CupertinoIcons.house_fill,
              title: 'NECESIDADES',
              subtitle: 'Esenciales',
              color: AppColors.systemGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildVault(
              icon: CupertinoIcons.bag_fill,
              title: 'DESEOS',
              subtitle: 'Opcionales',
              color: AppColors.systemPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVault({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Dashboard surface: white05 fill + white07 border
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black07),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Expense card ───────────────────────────────────────────────────────────
  // Now uses tertiaryBackground (same as dashboard cards) instead of a
  // blue-tinted shadow, and a subtle white07 border to match the system.

  Widget _buildExpenseCard(_ExpenseItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black07),
        // Softer shadow – consistent with other elevated surfaces in the app
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category icon – same pill style as stat chips
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.black07),
                ),
                child: Icon(
                  _getCategoryIcon(item.category),
                  color: AppColors.secondaryLabel,
                  size: 18,
                ),
              ),
              // Amount – prominent, same weight as balance card
              Text(
                '\$${item.amount}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: AppColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.label,
            ),
          ),
          const SizedBox(height: 4),
          // Category label – same style as dashboard's secondary body text
          Text(
            _getCategoryText(item.category),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryLabel,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  // Full-width pair that mirrors the dashboard's primary CupertinoButton style.

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: AppColors.systemGreen,
              borderRadius: BorderRadius.circular(14),
              onPressed: () => _answer(true),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.house_fill, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'NECESIDAD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: AppColors.systemPurple,
              borderRadius: BorderRadius.circular(14),
              onPressed: () => _answer(false),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.bag_fill, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'DESEO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Completion screen ──────────────────────────────────────────────────────
  // Score chip now uses the same white05/white07 surface as dashboard cards.

  Widget _buildCompletionScreen() {
    final percentage = _shuffledExpenses.isNotEmpty
        ? (_correctAnswers / _shuffledExpenses.length * 100).round()
        : 0;
    final passed = percentage >= 70;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result icon – gradient matches dashboard balance card gradient
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed
                      ? [AppColors.systemGreen, AppColors.systemGreen]
                      : [AppColors.systemOrange, AppColors.systemRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color:
                        (passed
                                ? AppColors.systemGreen
                                : AppColors.systemOrange)
                            .withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                passed
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.exclamationmark_triangle_fill,
                color: AppColors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              passed ? '¡EXCELENTE!' : '¡SIGUE PRACTICANDO!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.label,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clasificaste correctamente $_correctAnswers de ${_shuffledExpenses.length} gastos',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondaryLabel,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // XP chip – dashboard glass surface (white05 + white07 border)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.black07),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.star_fill,
                    color: AppColors.systemPurple,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$_score XP ganados',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColors.label,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Primary CTA
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
              color: AppColors.systemGreen,
              borderRadius: BorderRadius.circular(14),
              onPressed: _restartGame,
              child: const Text(
                'JUGAR DE NUEVO',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Secondary – matches dashboard's text-only nav buttons
            CupertinoButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'VOLVER A LECCIONES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'bill':
        return 'Pago de servicio mensual';
      case 'subscription':
        return 'Suscripción mensual';
      case 'housing':
        return 'Gasto de vivienda';
      case 'entertainment':
        return 'Entretenimiento';
      case 'groceries':
        return 'Compras del mes';
      case 'gaming':
        return 'Videojuegos';
      case 'dining':
        return 'Fuera de casa';
      case 'transport':
        return 'Transporte';
      case 'shopping':
        return 'Ropa y accesorios';
      case 'health':
        return 'Salud';
      case 'social':
        return 'Social';
      default:
        return 'Gasto';
    }
  }

  // Each category gets a contextual Cupertino icon instead of the generic doc icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'bill':
        return CupertinoIcons.bolt_fill;
      case 'subscription':
        return CupertinoIcons.play_rectangle_fill;
      case 'housing':
        return CupertinoIcons.house_fill;
      case 'entertainment':
        return CupertinoIcons.film_fill;
      case 'groceries':
        return CupertinoIcons.cart_fill;
      case 'gaming':
        return CupertinoIcons.gamecontroller_fill;
      case 'dining':
        return CupertinoIcons.flame_fill;
      case 'transport':
        return CupertinoIcons.car_fill;
      case 'shopping':
        return CupertinoIcons.bag_fill;
      case 'health':
        return CupertinoIcons.heart_fill;
      case 'social':
        return CupertinoIcons.person_2_fill;
      default:
        return CupertinoIcons.doc_text_fill;
    }
  }
}

class _ExpenseItem {
  final String name;
  final int amount;
  final bool isNeed;
  final String category;

  const _ExpenseItem({
    required this.name,
    required this.amount,
    required this.isNeed,
    required this.category,
  });
}
