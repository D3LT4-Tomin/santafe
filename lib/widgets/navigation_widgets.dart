import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class BackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const BackButton({super.key, this.onPressed, this.color, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      child: Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          color: (color ?? CupertinoColors.white).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.chevron_left,
            size: size - 6,
            color: color ?? CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class SettingsHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SettingsHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.secondaryLabel,
              height: 1.33,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class PlanBadge extends StatelessWidget {
  final bool isPremium;
  final bool compact;

  const PlanBadge({super.key, required this.isPremium, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [CupertinoColors.systemPurple, CupertinoColors.systemIndigo]
              : [CupertinoColors.systemGrey, CupertinoColors.systemGrey2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? CupertinoIcons.star_fill : CupertinoIcons.star,
            size: compact ? 12 : 14,
            color: CupertinoColors.white,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            isPremium ? 'Premium' : 'Básico',
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
