import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../models/learning_model.dart';

class LessonStarterScreen extends StatefulWidget {
  final String lessonId;
  final Widget lessonScreen;

  const LessonStarterScreen({
    super.key,
    required this.lessonId,
    required this.lessonScreen,
  });

  static Route<void> route({
    required String lessonId,
    required Widget lessonScreen,
  }) => CupertinoPageRoute(
    fullscreenDialog: true,
    builder: (_) =>
        LessonStarterScreen(lessonId: lessonId, lessonScreen: lessonScreen),
  );

  @override
  State<LessonStarterScreen> createState() => _LessonStarterScreenState();
}

class _LessonStarterScreenState extends State<LessonStarterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  void _startLesson() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (_) => widget.lessonScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = LessonCatalog.getById(widget.lessonId);
    if (lesson == null) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.lessonBackground,
      body: Stack(
        children: [
          Positioned(
            top: topPadding + 8,
            left: 8,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: _StarterCard(lesson: lesson),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 24,
            child: GestureDetector(
              onTap: _startLesson,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.legacyBlue, AppColors.legacyBlueLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.legacyBlue.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Empezar lección',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  final LessonModel lesson;

  const _StarterCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.systemGreen.withValues(alpha: 0.2),
                  AppColors.systemPurple.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Icon(
              CupertinoIcons.book_fill,
              color: AppColors.systemGreen,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            lesson.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor(lesson.category).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _getCategoryColor(
                  lesson.category,
                ).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              lesson.category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getCategoryColor(lesson.category),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: CupertinoIcons.clock,
                label: '${lesson.durationMinutes} min',
              ),
              const SizedBox(width: 16),
              _InfoChip(
                icon: CupertinoIcons.star_fill,
                label: '${lesson.points} pts',
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Aprende conceptos clave para\nmejorar tus finanzas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white54, height: 1.4),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Gestión':
        return AppColors.systemIndigo;
      case 'Planeación':
        return AppColors.systemGreen;
      case 'Ahorro':
        return AppColors.systemGreen;
      default:
        return AppColors.systemGreen;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.goldAccent : Colors.white54;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
