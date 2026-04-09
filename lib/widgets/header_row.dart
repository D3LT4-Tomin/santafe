import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/user_account_screen.dart';
import '../screens/notification_screen.dart';

// ─── Header Row ───────────────────────────────────────────────────────────────
class HeaderRow extends StatefulWidget {
  final ValueNotifier<double> searchBarOpacity;
  final VoidCallback? onSearchPressed;
  final int? currentTabIndex;

  const HeaderRow({
    super.key,
    required this.searchBarOpacity,
    this.onSearchPressed,
    this.currentTabIndex,
  });

  @override
  State<HeaderRow> createState() => _HeaderRowState();
}

class _HeaderRowState extends State<HeaderRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderController;
  late Animation<double> _borderAnimation;
  int? _lastTabIndex;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _borderController, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(HeaderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentTabIndex != _lastTabIndex &&
        widget.currentTabIndex != null) {
      _lastTabIndex = widget.currentTabIndex;
      _borderController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

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
    const avatarW = 36.0;
    const avatarGap = 10.0;
    const bellW = 44.0;
    const bellGap = 6.0;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.user?.displayName ?? 'Usuario';
        final initials = _getInitials(userName);

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxSearchW =
                constraints.maxWidth -
                avatarW -
                avatarGap -
                bellW -
                bellGap -
                10.0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const UserAccountScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: avatarW,
                    height: avatarW,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.systemGreen.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.systemGreen.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.systemGreen,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: avatarGap),
                const Expanded(child: SizedBox.shrink()),
                GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: AnimatedBuilder(
                    animation: _borderController,
                    builder: (context, child) {
                      return Container(
                        width: maxSearchW,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated rounded border going around
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _TrackBorderPainter(
                                  progress: _borderAnimation.value,
                                  color: AppColors.systemGreen,
                                  strokeWidth: 2.0,
                                ),
                              ),
                            ),
                            // Content with padding
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.search,
                                    color: AppColors.secondaryLabel,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: CupertinoTextField(
                                      readOnly: true,
                                      placeholder: 'Chatear con tu asistente',
                                      placeholderStyle:
                                          AppTextStyles.subheadline,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        letterSpacing: -0.24,
                                        color: AppColors.label,
                                      ),
                                      decoration: const BoxDecoration(),
                                      padding: EdgeInsets.zero,
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        widget.onSearchPressed?.call();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: bellGap),
                const NavButton(icon: CupertinoIcons.bell, badgeCount: 2),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Track Border Painter ────────────────────────────────────────────────────
class _TrackBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _TrackBorderPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Inset the rectangle by half the stroke width to prevent clipping
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Create the rounded rectangle matching your container's radius
    final rrect = RRect.fromRectAndRadius(
      rect, 
      Radius.circular(18.0 - (strokeWidth / 2)),
    );

    // Convert to a path
    final path = Path()..addRRect(rrect);

    // Use PathMetrics to draw only the animated percentage
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final extractPath = metric.extractPath(0.0, metric.length * progress);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(_TrackBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ─── Nav Button ───────────────────────────────────────────────────────────────
class NavButton extends StatelessWidget {
  final IconData icon;
  final int? badgeCount;

  const NavButton({super.key, required this.icon, this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (icon == CupertinoIcons.bell) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => const NotificationScreen(),
            ),
          );
        }
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.systemGreen, size: 22),
            if (badgeCount != null && badgeCount! > 0)
              const Positioned(
                top: 8,
                right: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.systemRed,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 8, height: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
