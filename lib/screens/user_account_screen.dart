import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/animated_blobs.dart';
import 'user_settings_screen.dart';
import 'subscription_screen.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).loadPlan();
    });
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

        // Botón de regreso grande y visible
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.chevron_left,
                size: 24,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController ?? ScrollController(),
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 70, bottom: 120),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: radius,
              border: Border.all(color: AppColors.white07),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      CupertinoColors.systemPurple,
                      CupertinoColors.systemIndigo,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemPurple.withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (user?.displayName ?? user?.email ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label,
                  letterSpacing: -0.41,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryLabel,
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, child) {
        final lessonsCompleted = learningProvider.completedLessonsCount;
        final totalLessons = learningProvider.totalLessonsCount;
        final progress = totalLessons > 0
            ? lessonsCompleted / totalLessons
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progreso de aprendizaje',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label,
                          letterSpacing: -0.24,
                        ),
                      ),
                      Text(
                        '$lessonsCompleted / $totalLessons',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                CupertinoColors.systemPurple,
                                CupertinoColors.systemIndigo,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress < 0.3
                        ? '¡Sigue aprendiendo!'
                        : progress < 0.7
                        ? '¡Vas muy bien!'
                        : '¡Casi terminas!',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryLabel,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final isPremium = provider.isPremium;
        final limits = provider.limits;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
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
                            gradient: LinearGradient(
                              colors: isPremium
                                  ? [
                                      CupertinoColors.systemPurple,
                                      CupertinoColors.systemIndigo,
                                    ]
                                  : [
                                      CupertinoColors.systemGrey,
                                      CupertinoColors.systemGrey2,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPremium
                                ? CupertinoIcons.star_fill
                                : CupertinoIcons.star,
                            color: CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isPremium ? 'Plan Premium' : 'Plan Básico',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.label,
                              letterSpacing: -0.41,
                              height: 1.29,
                            ),
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: AppColors.tertiaryLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isPremium
                          ? 'Acceso completo a todas las funciones'
                          : 'Funciones básicas disponibles',
                      style: const TextStyle(
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
                          icon: isPremium
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.checkmark_circle,
                          label: isPremium
                              ? 'Cuentas ilimitadas'
                              : 'Hasta ${limits.maxAccounts} cuentas',
                        ),
                        const SizedBox(width: 16),
                        _Feature(
                          icon: isPremium
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.checkmark_circle,
                          label: isPremium
                              ? 'Transacciones ilimitadas'
                              : '100 transacciones',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Feature(
                          icon: isPremium
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.checkmark_circle,
                          label: 'Resumen semanal',
                        ),
                        const SizedBox(width: 16),
                        _Feature(
                          icon: isPremium
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.checkmark_circle,
                          label: 'Metas de ahorro',
                        ),
                      ],
                    ),
                    if (!isPremium) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              CupertinoColors.systemPurple,
                              CupertinoColors.systemIndigo,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Mejorar a Premium',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          Icon(icon, size: 16, color: CupertinoColors.systemGreen),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel,
                height: 1.38,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

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
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white05,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.white07),
          ),
          child: Column(
            children: [
              Padding(
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
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 58),
                  child: ColoredBox(
                    color: AppColors.separator,
                    child: const SizedBox(height: 0.5, width: double.infinity),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
