import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';
import 'conceptos_base_lesson.dart';
import 'ahorro_activo_lesson.dart';
import 'comer_fuera_vs_cocinar_lesson.dart';

class AprenderScreen extends StatefulWidget {
  final ScrollController scrollController;
  const AprenderScreen({super.key, required this.scrollController});

  @override
  State<AprenderScreen> createState() => _AprenderScreenState();
}

class _AprenderScreenState extends State<AprenderScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  final _searchBarOpacity = ValueNotifier<double>(1.0);

  @override
  void initState() {
    super.initState();
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

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _appearController.forward();
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    _searchBarOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        RepaintBoundary(
          child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 76, bottom: 80),
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: const Column(
                  children: [
                    _ProgressCard(),
                    SizedBox(height: 28),
                    _RecommendationCard(),
                    SizedBox(height: 28),
                    _LearningRoadmap(),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(child: _buildHeaderChrome(topPadding)),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.only(
              top: topPadding + 10,
              bottom: 20,
              left: 16,
              right: 8,
            ),
            child: HeaderRow(
              searchBarOpacity: _searchBarOpacity,
              onSearchPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderChrome(double topPadding) {
    return SizedBox(
      height: topPadding + 66.0,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.frostedBlue, Color(0x00070D1A)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Card ────────────────────────────────────────────────────────────
// Replaces the floating START LESSON button with contextual progress
// that lives naturally in the scroll flow.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    const double progress = 2 / 6; // 2 of 6 lessons complete

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.systemBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.book_fill,
                      color: AppColors.systemBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'MAESTRÍA FINANCIERA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Comer fuera vs. Cocinar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.label,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '2 / 6',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppColors.white07,
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.systemBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A84FF), Color(0xFF409CFF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330A84FF),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const ComerFueraVsCocinarLesson(),
                      ),
                    ),
                    child: const Text(
                      'Continuar lección',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recommendation Card ──────────────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.systemPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: AppColors.systemPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RECOMENDACIÓN IA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.systemPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Basado en tus gastos en Tacos El Güero, te recomendamos aprender sobre comer fuera vs. cocinar en casa.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.label,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => const ComerFueraVsCocinarLesson(),
                        ),
                      ),
                      child: const Text(
                        'Ver lección →',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.systemPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Learning Roadmap ─────────────────────────────────────────────────────────
enum _NodeStatus { completed, active, locked }

class _NodeData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final _NodeStatus status;
  const _NodeData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
  });
}

class _LearningRoadmap extends StatelessWidget {
  const _LearningRoadmap();

  static const _nodes = [
    _NodeData(
      title: 'Conceptos Base',
      subtitle: 'Fundamentos del dinero',
      icon: CupertinoIcons.checkmark_seal_fill,
      color: AppColors.systemGreen,
      status: _NodeStatus.completed,
    ),
    _NodeData(
      title: 'Ahorro Activo',
      subtitle: 'Hábitos que funcionan',
      icon: CupertinoIcons.checkmark_seal_fill,
      color: AppColors.systemBlue,
      status: _NodeStatus.completed,
    ),
    _NodeData(
      title: 'Comer fuera vs. Cocinar',
      subtitle: '5 min · Lección actual',
      icon: CupertinoIcons.flame_fill,
      color: AppColors.systemOrange,
      status: _NodeStatus.active,
    ),
    _NodeData(
      title: 'Inversión 101',
      subtitle: 'Tu dinero trabajando',
      icon: CupertinoIcons.graph_circle_fill,
      color: AppColors.systemPurple,
      status: _NodeStatus.locked,
    ),
    _NodeData(
      title: 'Crédito Inteligente',
      subtitle: 'Usar sin endeudarse',
      icon: CupertinoIcons.creditcard_fill,
      color: AppColors.systemIndigo,
      status: _NodeStatus.locked,
    ),
    _NodeData(
      title: 'Libertad Financiera',
      subtitle: 'El objetivo final',
      icon: CupertinoIcons.star_fill,
      color: AppColors.systemOrange,
      status: _NodeStatus.locked,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RUTA DE APRENDIZAJE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.secondaryLabel,
                    height: 1.33,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.systemBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '2 de 6',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.systemBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 2-column grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _nodes.map((node) => _LessonCard(node: node)).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Lesson Card ──────────────────────────────────────────────────────────────
class _LessonCard extends StatelessWidget {
  final _NodeData node;
  const _LessonCard({required this.node});

  Widget _getLessonPage(String title) {
    switch (title) {
      case 'Conceptos Base':
        return const ConceptosBaseLesson();
      case 'Ahorro Activo':
        return const AhorroActivoLesson();
      case 'Comer fuera vs. Cocinar':
        return const ComerFueraVsCocinarLesson();
      default:
        return const ConceptosBaseLesson();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = node.status == _NodeStatus.completed;
    final isActive = node.status == _NodeStatus.active;
    final isLocked = node.status == _NodeStatus.locked;

    final Color cardColor = isLocked
        ? AppColors.white05
        : node.color.withOpacity(0.10);
    final Color borderColor = isLocked
        ? AppColors.white07
        : node.color.withOpacity(0.22);
    final Color iconBg = isLocked
        ? AppColors.white07
        : node.color.withOpacity(0.18);
    final Color iconColor = isLocked ? AppColors.tertiaryLabel : node.color;
    final Color titleColor = isLocked
        ? AppColors.secondaryLabel
        : AppColors.label;
    final Color subColor = isLocked ? AppColors.tertiaryLabel : node.color;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isLocked
          ? null
          : () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => _getLessonPage(node.title)),
            ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? node.color.withOpacity(0.55) : borderColor,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: node.color.withOpacity(0.18),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(node.icon, color: iconColor, size: 18),
                  ),
                  if (isCompleted)
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.systemGreen,
                      size: 18,
                    )
                  else if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: node.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Ahora',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: node.color,
                        ),
                      ),
                    )
                  else
                    Icon(
                      CupertinoIcons.lock_fill,
                      color: AppColors.tertiaryLabel,
                      size: 14,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                node.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                node.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
