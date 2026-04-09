import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/learning_provider.dart';
import '../widgets/animated_blobs.dart';
import 'user_settings_screen.dart';

class UserAccountScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const UserAccountScreen({super.key, this.scrollController});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

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
            controller: widget.scrollController ?? ScrollController(),
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 76, bottom: 120),
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: Column(
                  children: [
                    const _ProfileHeader(),
                    const SizedBox(height: 28),
                    const _AchievementsSection(),
                    const SizedBox(height: 28),
                    const _PlanCard(),
                    const SizedBox(height: 28),
                    _GlassSettingsRow(
                      icon: CupertinoIcons.gear_alt_fill,
                      color: AppColors.systemGreen,
                      label: 'Configuración',
                      trailing: const _TrailingChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const UserSettingsScreen(),
                          ),
                        );
                      },
                      isLast: true,
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Finanzas v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glass Card Container ─────────────────────────────────────────────────────
/// Wraps any child in a frosted-glass card with [sigmaX]/[sigmaY] blur,
/// a subtle white-tinted fill, and a soft border.
class _GlassCard extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final BorderRadius? borderRadius;

  const _GlassCard({
    required this.child,
    this.sigmaX = 18,
    this.sigmaY = 18,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: radius,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: child,
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final displayName = user?.displayName ?? 'Usuario';
        final initials = _getInitials(displayName);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.legacyBlue,
                          AppColors.legacyBlueLight,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryLabel,
                            height: 1.33,
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
      },
    );
  }
}

// ─── Achievements Section ─────────────────────────────────────────────────────
class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.systemGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.star_fill,
                      color: AppColors.systemGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Logros',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                      letterSpacing: -0.41,
                      height: 1.29,
                    ),
                  ),
                  const Spacer(),
                  Consumer<LearningProvider>(
                    builder: (context, lp, _) {
                      final earnedCount = _achievements
                          .where((a) => lp.hasBadge(a.badgeId))
                          .length;
                      return Text(
                        '$earnedCount/${_achievements.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryLabel,
                          height: 1.33,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const ColoredBox(
                color: AppColors.separator,
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              const SizedBox(height: 16),
              Consumer<LearningProvider>(
                builder: (context, lp, _) {
                  return GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _achievements
                        .map(
                          (a) => _HexBadge(
                            achievement: a,
                            earned: lp.hasBadge(a.badgeId),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Achievement {
  final String badgeId;
  final String label;
  final IconData icon;
  const _Achievement({
    required this.badgeId,
    required this.label,
    required this.icon,
  });
}

const _achievements = [
  _Achievement(
    badgeId: 'first_lesson',
    label: 'Primer\nlección',
    icon: CupertinoIcons.pencil,
  ),
  _Achievement(
    badgeId: 'first_savings',
    label: 'Primer\nahorro',
    icon: CupertinoIcons.money_dollar,
  ),
  _Achievement(
    badgeId: 'cazador_gastos',
    label: 'Cazador de\ngastos',
    icon: CupertinoIcons.money_dollar_circle_fill,
  ),
  _Achievement(
    badgeId: 'week_streak',
    label: 'Una semana\nde racha',
    icon: CupertinoIcons.rocket_fill,
  ),
  _Achievement(
    badgeId: 'five_lessons',
    label: '5 lecciones\nseguidas',
    icon: CupertinoIcons.pencil_slash,
  ),
  _Achievement(
    badgeId: 'month_streak',
    label: 'Un mes\nde racha',
    icon: CupertinoIcons.calendar,
  ),
  _Achievement(
    badgeId: 'year_streak',
    label: '365 días\nde racha',
    icon: CupertinoIcons.gift_fill,
  ),
  _Achievement(
    badgeId: 'night_study',
    label: 'Noche\nestudiosa',
    icon: CupertinoIcons.moon_fill,
  ),
  _Achievement(
    badgeId: 'explorer',
    label: 'Explorador',
    icon: CupertinoIcons.cube_box_fill,
  ),
  _Achievement(
    badgeId: 'constant',
    label: 'Constante',
    icon: CupertinoIcons.link,
  ),
];

class _HexBadge extends StatelessWidget {
  final _Achievement achievement;
  final bool earned;
  const _HexBadge({required this.achievement, required this.earned});

  @override
  Widget build(BuildContext context) {
    final iconColor = earned ? AppColors.systemGreen : AppColors.tertiaryLabel;
    final bgColor = earned
        ? AppColors.systemGreen.withValues(alpha: 0.12)
        : AppColors.cardBackground;
    final borderColor = earned
        ? AppColors.systemGreen.withValues(alpha: 0.28)
        : AppColors.black07;
    final labelColor = earned ? AppColors.label : AppColors.tertiaryLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: CustomPaint(
            painter: _HexPainter(fillColor: bgColor, borderColor: borderColor),
            child: Center(
              child: Icon(achievement.icon, color: iconColor, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          achievement.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: labelColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

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
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
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

// ─── Plan Card ────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.systemPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.sparkles,
                      color: AppColors.systemPurple,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Plan gratuito',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                      letterSpacing: -0.41,
                      height: 1.29,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Cuentas básicas y seguimiento de gastos',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryLabel,
                  height: 1.33,
                  letterSpacing: -0.24,
                ),
              ),
              const SizedBox(height: 16),
              const ColoredBox(
                color: AppColors.separator,
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Feature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Hasta 3 cuentas',
                  ),
                  const SizedBox(width: 16),
                  _Feature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Resumen semanal',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Feature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Categorías básicas',
                  ),
                  const SizedBox(width: 16),
                  _Feature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Metas de ahorro',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Feature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: AppColors.systemPurple, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared row separator ─────────────────────────────────────────────────────
class _RowSeparator extends StatelessWidget {
  const _RowSeparator();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 56),
      child: ColoredBox(
        color: AppColors.separator,
        child: SizedBox(height: 0.5, width: double.infinity),
      ),
    );
  }
}

// ─── Glass Settings Row ───────────────────────────────────────────────────────
class _GlassSettingsRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  final bool isLast;

  const _GlassSettingsRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _GlassCard(
        child: Column(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.label,
                          height: 1.33,
                        ),
                      ),
                    ),
                    trailing,
                  ],
                ),
              ),
            ),
            if (!isLast) const _RowSeparator(),
          ],
        ),
      ),
    );
  }
}

// ─── Trailing Chevron ─────────────────────────────────────────────────────────
class _TrailingChevron extends StatelessWidget {
  const _TrailingChevron();
  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.chevron_right,
      size: 14,
      color: AppColors.tertiaryLabel,
    );
  }
}
