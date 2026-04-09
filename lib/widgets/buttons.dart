import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryButtonGradientStart,
                AppColors.primaryButtonGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryButtonShadow,
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: CupertinoColors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.41,
                    color: CupertinoColors.white,
                    height: 1.29,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── FAB Button ───────────────────────────────────────────────────────────────
class FabButton extends StatefulWidget {
  final VoidCallback onTap;

  const FabButton({super.key, required this.onTap});

  @override
  State<FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<FabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryButtonGradientStart,
                AppColors.primaryButtonGradientEnd,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryButtonShadowLight,
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.plus,
            color: CupertinoColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
