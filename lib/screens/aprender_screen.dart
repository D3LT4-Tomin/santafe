import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';
import '../widgets/buttons.dart';

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

        // ── Scrollable content ────────────────────────────────────
        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 76,
              bottom: 160,
            ), // Increased bottom padding to accommodate fixed FAB
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: const Column(
                  children: [
                    _EducationHeader(),
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

        // ── Header ───────────────────────────────────────────────
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

        // ── Always visible Start Lesson FAB ────────────────────────────────────────
        Positioned(
          bottom: 48,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A84FF), Color(0xFF409CFF)],
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330A84FF),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                CupertinoIcons.play,
                color: CupertinoColors.white,
                size: 24,
              ),
              onPressed: () {},
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
                  stops: [0.0, 1.0],
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

// ─── Education Header ─────────────────────────────────────────────────────────────
class _EducationHeader extends StatelessWidget {
  const _EducationHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            'PATH',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.label,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MAESTRÍA FINANCIERA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: AppColors.systemBlue.withOpacity(0.6),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recommendation Card ──────────────────────────────────────────────────────────
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.home,
                  color: AppColors.systemBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMENDACIÓN IA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.systemBlue,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Basado en tus gastos en Tacos El Güero, te recomendamos: \nComer fuera vs. Cocinar',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.label,
                        height: 1.4,
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

// ─── Learning Roadmap ─────────────────────────────────────────────────────────────
class _LearningRoadmap extends StatelessWidget {
  const _LearningRoadmap();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Path visualization
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white07),
            ),
            child: Column(
              children: [
                // Node 1: Conceptos Base (Completed)
                _RoadmapNode(
                  title: 'Conceptos Base',
                  status: _NodeStatus.completed,
                  icon: CupertinoIcons.check_mark_circled,
                  color: AppColors.systemBlue,
                ),

                // Curved connection line
                Container(
                  height: 40,
                  child: Center(
                    child: CustomPaint(
                      size: Size(4, 30),
                      painter: _CurvedLinePainter(
                        color: AppColors.systemBlue.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),

                // Node 2: Ahorro Activo (Completed)
                _RoadmapNode(
                  title: 'Ahorro Activo',
                  status: _NodeStatus.completed,
                  icon: CupertinoIcons.check_mark_circled,
                  color: AppColors.systemBlue,
                ),

                // Curved connection line
                Container(
                  height: 40,
                  child: Center(
                    child: CustomPaint(
                      size: Size(4, 30),
                      painter: _CurvedLinePainter(
                        color: AppColors.systemBlue.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),

                // Node 3: Current (Comer fuera vs. Cocinar)
                _RoadmapNode(
                  title: 'Comer fuera vs. Cocinar',
                  status: _NodeStatus.active,
                  icon: CupertinoIcons.home,
                  color: AppColors.systemBlue,
                ),

                // Curved connection line
                Container(
                  height: 40,
                  child: Center(
                    child: CustomPaint(
                      size: Size(4, 30),
                      painter: _CurvedLinePainter(
                        color: AppColors.tertiaryLabel.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),

                // Node 4: Inversión 101 (Locked)
                _RoadmapNode(
                  title: 'Inversión 101',
                  status: _NodeStatus.locked,
                  icon: CupertinoIcons.lock,
                  color: AppColors.tertiaryLabel,
                ),

                // Curved connection line
                Container(
                  height: 40,
                  child: Center(
                    child: CustomPaint(
                      size: Size(4, 30),
                      painter: _CurvedLinePainter(
                        color: AppColors.tertiaryLabel.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),

                // Node 5: Crédito Inteligente (Locked)
                _RoadmapNode(
                  title: 'Crédito Inteligente',
                  status: _NodeStatus.locked,
                  icon: CupertinoIcons.creditcard_fill,
                  color: AppColors.tertiaryLabel,
                ),

                // Curved connection line
                Container(
                  height: 40,
                  child: Center(
                    child: CustomPaint(
                      size: Size(4, 30),
                      painter: _CurvedLinePainter(
                        color: AppColors.tertiaryLabel.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),

                // Node 6: Final Boss (Libertad Financiera)
                _RoadmapNode(
                  title: 'Libertad Financiera',
                  status: _NodeStatus.locked,
                  icon: CupertinoIcons.star,
                  color: AppColors.tertiaryLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Curved Line Painter ──────────────────────────────────────────────────────────
class _CurvedLinePainter extends CustomPainter {
  final Color color;

  _CurvedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2,
      size.width / 2,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CurvedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─── Roadmap Node Status Enum ─────────────────────────────────────────────────────
enum _NodeStatus { completed, active, locked }

// ─── Roadmap Node ─────────────────────────────────────────────────────────────────
class _RoadmapNode extends StatelessWidget {
  final String title;
  final _NodeStatus status;
  final IconData icon;
  final Color color;

  const _RoadmapNode({
    required this.title,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    bool isInteractive = false;

    switch (status) {
      case _NodeStatus.completed:
        bgColor = AppColors.systemBlue.withOpacity(0.15);
        borderColor = AppColors.systemBlue.withOpacity(0.3);
        break;
      case _NodeStatus.active:
        bgColor = AppColors.systemBlue.withOpacity(0.25);
        borderColor = AppColors.systemBlue;
        isInteractive = true;
        break;
      case _NodeStatus.locked:
        bgColor = AppColors.tertiaryBackground;
        borderColor = AppColors.separator;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Icon(
                icon,
                color: status == _NodeStatus.active
                    ? AppColors.systemBlue
                    : color,
                size: status == _NodeStatus.active ? 28 : 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: status == _NodeStatus.locked
                  ? AppColors.tertiaryLabel
                  : color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
