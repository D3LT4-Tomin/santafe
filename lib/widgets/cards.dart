import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/insights_screen.dart';

// ─── Savings Goal Card ────────────────────────────────────────────────────────
class SavingsGoalCard extends StatelessWidget {
  const SavingsGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.legacyGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        CupertinoIcons.flag_fill,
                        color: AppColors.systemGreen,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'META DE AHORRO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.systemGreen,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Viaje a Japón 🇯🇵',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: AppColors.label,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        r'$12,450 / $25,000',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        '49% completado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryLabel,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.49,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.systemGreen,
                        borderRadius: BorderRadius.circular(4),
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

// ─── Bank Promo Card ──────────────────────────────────────────────────────────
class BankPromoCard extends StatelessWidget {
  const BankPromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.systemGreen,
              AppColors.systemGreen.withValues(alpha: 0.85),
            ],
          ),
          border: Border.all(color: AppColors.white30, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardBackground,
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          'NUEVO · GUARDADITO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Guardadito\nBanco Azteca',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hasta 9% de rendimiento anual.\nAbre en 3 minutos con tu CURP.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.1,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Abrir cuenta',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.systemGreen,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  CupertinoIcons.arrow_right,
                                  size: 12,
                                  color: AppColors.systemGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

// ─── Weekly Summary Card ──────────────────────────────────────────────────────
class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to insights tab (index 1)
        // We need to access the AppShell state to change the tab
        // For simplicity, we'll navigate to the insights screen directly
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) =>
                InsightsScreen(scrollController: ScrollController()),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: AppColors.cardBorder, width: 0.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESUMEN SEMANAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.secondaryLabel,
                    height: 1.33,
                  ),
                ),
                SizedBox(height: 8),
                Text('Vas por buen camino 🚀', style: AppTextStyles.title3),
                SizedBox(height: 4),
                Text(
                  'Ahorraste \$240 más que la semana pasada.',
                  style: AppTextStyles.subheadline,
                ),
                SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                  child: LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 6,
                    backgroundColor: AppColors.tertiaryFill,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.systemGreen,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Meta semanal', style: AppTextStyles.caption1),
                    Text(
                      '68%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.systemGreen,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
