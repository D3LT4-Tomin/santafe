import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/insights_screen.dart';

// ─── Tip Card ─────────────────────────────────────────────────────────────────
class TipCard extends StatelessWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.blueTipBg,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.blueTipBorder, width: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x330A84FF),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    CupertinoIcons.lightbulb_fill,
                    color: AppColors.systemBlue,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip del día',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.08,
                        color: AppColors.systemBlue,
                        height: 1.38,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '¿Sabías que puedes abrir una cuenta Nivel 1 en 5 minutos con tu CURP?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.24,
                        color: AppColors.label,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: AppColors.secondaryLabel,
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2748), Color(0xFF0A1A35)],
          ),
          border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1A0A84FF),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x120A84FF),
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
                        color: const Color(0x330A84FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0x4D0A84FF),
                          width: 0.5,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          'NUEVO · CUENTA DIGITAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.systemBlue,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cuenta Flex\nSin comisiones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: AppColors.label,
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
                        color: Color(0xB3FFFFFF),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A84FF), Color(0xFF409CFF)],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x400A84FF),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Padding(
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
                                    color: AppColors.label,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  CupertinoIcons.arrow_right,
                                  size: 12,
                                  color: AppColors.label,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '9% RAT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.systemGreen,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'rendimiento anual',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0x80FFFFFF),
                                letterSpacing: -0.1,
                                height: 1.3,
                              ),
                            ),
                          ],
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
            color: AppColors.white05,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            border: Border.fromBorderSide(BorderSide(color: AppColors.white07)),
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
