import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/user_account_screen.dart';
import '../screens/notification_screen.dart';

// ─── Header Row ───────────────────────────────────────────────────────────────
class HeaderRow extends StatelessWidget {
  final ValueNotifier<double> searchBarOpacity;
  final VoidCallback? onSearchPressed;

  const HeaderRow({
    super.key,
    required this.searchBarOpacity,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: searchBarOpacity,
      builder: (context, opacity, _) {
        final t = 1.0 - opacity;
        final radius = 999.0 - t * (999.0 - 18.0);
        return LayoutBuilder(
          builder: (context, constraints) {
            const avatarW = 36.0;
            const avatarGap = 10.0;
            const bellW = 44.0;
            const bellGap = 6.0;
            final maxSearchW =
                constraints.maxWidth -
                avatarW -
                avatarGap -
                bellW -
                bellGap -
                10.0;
            final searchW = (40.0 + (maxSearchW - 40.0) * (1.0 - t)).clamp(
              40.0,
              maxSearchW,
            );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Navigate to user account screen
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const UserAccountScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: avatarW,
                    height: avatarW,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0x2EFFFFFF), width: 1.5),
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA7VAjlyQ-_WFHJr8FNWcHoYI3luJZXn-tOYVP9SwZ2nNsBlP2TOffmkZ-46agZwWRJr7tUeIHcP7TCelC4KxKN03Cwb9RY7oAmPqvxHawtiGTe02-U196Nb20svBobESuRH6pL-3jXll3HAvxPMUAcQYqM_CC1PHyG3dCPDmLi6s_DRLih6fR5PohT4JU9EVqnhz_ZwxRG_sOootFOhlWPuXUhVgLy6LsNGiAU9zzUt5qWbgGruFnPxSfNIRtkla0w7NzCo68QudBL',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          CupertinoIcons.person_fill,
                          color: AppColors.secondaryLabel,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: avatarGap),
                const Expanded(child: SizedBox.shrink()),
                GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: t > 0.5 ? 340 : 600),
                    curve: t > 0.5 ? Curves.easeOutCubic : Curves.easeOutQuart,
                    width: searchW,
                    height: 36,
                    decoration: BoxDecoration(
                      color: t > 0.5
                          ? const Color(0x1AFFFFFF)
                          : const Color(0x14FFFFFF),
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                        color: Color.fromRGBO(255, 255, 255, 0.06 + t * 0.08),
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          OverflowBox(
                            alignment: Alignment.centerLeft,
                            maxWidth: double.infinity,
                            child: SizedBox(
                              width: maxSearchW,
                              child: Opacity(
                                opacity: (1.0 - t * 2.2).clamp(0.0, 1.0),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Icon(
                                      CupertinoIcons.search,
                                      color: AppColors.secondaryLabel,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    SizedBox(width: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (t == 0.0)
                            OverflowBox(
                              alignment: Alignment.centerLeft,
                              maxWidth: double.infinity,
                              child: SizedBox(
                                width: maxSearchW,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
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
                                        style: TextStyle(
                                          fontSize: 15,
                                          letterSpacing: -0.24,
                                          color: AppColors.label,
                                          height: 1.33,
                                        ),
                                        decoration: BoxDecoration(),
                                        padding: EdgeInsets.zero,
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          onSearchPressed?.call();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                            ),
                          Opacity(
                            opacity: ((t * 2.0) - 1.0).clamp(0.0, 1.0),
                            child: Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.search,
                                color: AppColors.systemBlue,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
            Icon(icon, color: AppColors.systemBlue, size: 22),
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
