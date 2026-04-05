import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
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

  // Notification toggles
  bool _notifGastos = true;
  bool _notifMetas = true;
  bool _notifResumen = false;
  bool _notifPromociones = false;

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
            padding: EdgeInsets.only(top: topPadding + 76, bottom: 80),
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: Column(
                  children: [
                    // ── Avatar header ─────────────────────────────────
                    const _AvatarHeader(),
                    const SizedBox(height: 28),

                    // ── Suscripción ───────────────────────────────────
                    const _SubscriptionCard(),
                    const SizedBox(height: 28),

                    // ── Logros ────────────────────────────────────────
                    const _AchievementsGrid(),
                    const SizedBox(height: 28),

                    // ── Configuración ─────────────────────────────────
                    _SettingsRow(
                      icon: CupertinoIcons.gear_alt_fill,
                      color: AppColors.systemBlue,
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

                    // ── Version ───────────────────────────────────────
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

// ─── Avatar Header ────────────────────────────────────────────────────────────
class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader();

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
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.white07),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0A84FF), Color(0xFF409CFF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.systemBlue.withOpacity(0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      // Edit badge
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white07,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.pencil,
                            size: 12,
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Name + email
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
                        const SizedBox(height: 10),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: () => HapticFeedback.selectionClick(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.systemBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.systemBlue.withOpacity(0.2),
                              ),
                            ),
                            child: const Text(
                              'Editar perfil',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.systemBlue,
                              ),
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
      },
    );
  }
}

// ─── Subscription Card ────────────────────────────────────────────────────────
class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1040), Color(0xFF0D1F40)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.systemPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.systemPurple.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.systemPurple.withOpacity(0.2),
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
                        'Finanzas Pro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.systemPurple.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.systemPurple.withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      'ACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.systemPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const ColoredBox(
                color: Color(0x1AFFFFFF),
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _PlanFeature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Cuentas ilimitadas',
                  ),
                  const SizedBox(width: 16),
                  _PlanFeature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'IA personalizada',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PlanFeature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Exportar datos',
                  ),
                  const SizedBox(width: 16),
                  _PlanFeature(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    label: 'Sin anuncios',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Se renueva el 15 de abril',
                    style: TextStyle(fontSize: 12, color: Color(0x99FFFFFF)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () => HapticFeedback.selectionClick(),
                    child: const Text(
                      'Gestionar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.systemPurple,
                      ),
                    ),
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

class _PlanFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlanFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: AppColors.systemPurple, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xCCFFFFFF),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Section ─────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SettingsSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.secondaryLabel,
                height: 1.33,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white07),
            ),
            child: Column(children: rows),
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

// ─── Settings Row ─────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.isDestructive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.systemRed.withOpacity(0.12)
                        : color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isDestructive ? AppColors.systemRed : color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? AppColors.systemRed
                          : AppColors.label,
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
    );
  }
}

// ─── Toggle Row ───────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: value,
                activeColor: AppColors.systemBlue,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                },
              ),
            ],
          ),
        ),
        if (!isLast) const _RowSeparator(),
      ],
    );
  }
}

// ─── Trailing helpers ─────────────────────────────────────────────────────────
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

class _TrailingValue extends StatelessWidget {
  final String value;
  const _TrailingValue(this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppColors.secondaryLabel),
        ),
        const SizedBox(width: 4),
        const Icon(
          CupertinoIcons.chevron_right,
          size: 14,
          color: AppColors.tertiaryLabel,
        ),
      ],
    );
  }
}

// ─── Sign Out Button ──────────────────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => HapticFeedback.mediumImpact(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.systemRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.systemRed.withOpacity(0.18)),
          ),
          child: const SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.systemRed,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Achievements grid ────────────────────────────────────────────────────────
class _Achievement {
  final String label;
  final IconData icon;
  final bool earned;
  const _Achievement({
    required this.label,
    required this.icon,
    required this.earned,
  });
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid();

  static const _achievements = [
    _Achievement(
      label: 'Primer\nlección',
      icon: CupertinoIcons.pencil,
      earned: true,
    ),
    _Achievement(
      label: 'Primer\nahorro',
      icon: CupertinoIcons.money_dollar,
      earned: true,
    ),
    _Achievement(
      label: 'Una semana\nde racha',
      icon: CupertinoIcons.rocket_fill,
      earned: true,
    ),
    _Achievement(
      label: '5 lecciones\nseguidas',
      icon: CupertinoIcons.pencil_slash,
      earned: true,
    ),
    _Achievement(
      label: 'Un mes\nde racha',
      icon: CupertinoIcons.calendar,
      earned: false,
    ),
    _Achievement(
      label: '365 días\nde racha',
      icon: CupertinoIcons.gift_fill,
      earned: false,
    ),
    _Achievement(
      label: 'Noche\nestudiosa',
      icon: CupertinoIcons.moon_fill,
      earned: false,
    ),
    _Achievement(
      label: 'Explorador',
      icon: CupertinoIcons.cube_box_fill,
      earned: false,
    ),
    _Achievement(label: 'Constante', icon: CupertinoIcons.link, earned: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _achievements.map((a) => _HexBadge(achievement: a)).toList(),
      ),
    );
  }
}

class _HexBadge extends StatelessWidget {
  final _Achievement achievement;
  const _HexBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earned;
    final iconColor = earned ? AppColors.systemBlue : AppColors.tertiaryLabel;
    final bgColor = earned
        ? AppColors.systemBlue.withOpacity(0.12)
        : AppColors.white05;
    final borderColor = earned
        ? AppColors.systemBlue.withOpacity(0.28)
        : AppColors.white07;
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
