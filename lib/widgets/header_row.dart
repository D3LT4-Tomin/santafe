import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/user_account_screen.dart';
import '../screens/notification_screen.dart';

// ─── Header Row ───────────────────────────────────────────────────────────────
class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            width: 36,
            height: 36,
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
        const NavButton(icon: CupertinoIcons.bell, badgeCount: 2),
      ],
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
