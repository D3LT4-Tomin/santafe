import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Add Expense Sheet ────────────────────────────────────────────────────────
class AddExpenseSheet extends StatelessWidget {
  const AddExpenseSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x4D8E8E93),
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: SizedBox(width: 36, height: 5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar',
                      style: TextStyle(color: AppColors.systemBlue)),
                ),
                const Text('Nuevo Gasto', style: AppTextStyles.headline),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Listo',
                      style: TextStyle(
                        color: AppColors.systemBlue,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
          ),
          const ColoredBox(
            color: AppColors.separator,
            child: SizedBox(height: 0.5, width: double.infinity),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: CupertinoTextField(
              placeholder: 'Descripción del gasto',
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              style: AppTextStyles.body,
              placeholderStyle: TextStyle(
                fontSize: 17,
                color: AppColors.secondaryLabel,
                letterSpacing: -0.41,
                height: 1.29,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoTextField(
              placeholder: '\$0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.35,
                color: AppColors.label,
                height: 1.27,
              ),
              placeholderStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryLabel,
                letterSpacing: 0.35,
                height: 1.27,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
