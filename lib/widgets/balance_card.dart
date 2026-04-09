import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        final totalBalance = dataProvider.totalBalance;
        final weeklyIncome = dataProvider.weeklyIncome;

        final formattedBalance = totalBalance.toStringAsFixed(2).split('.');
        final balanceMain = formattedBalance[0];
        final balanceDecimal = formattedBalance.length > 1
            ? formattedBalance[1]
            : '00';

        // Add commas to the main part of the balance
        final formattedBalanceMain = balanceMain.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );

        final weeklyPrefix = weeklyIncome >= 0 ? '+' : '';
        final weeklyMain = weeklyIncome
            .abs()
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (match) => '${match[1]},',
            );
        final weeklyText = '$weeklyPrefix\$$weeklyMain esta semana';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DINERO DISPONIBLE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: AppColors.secondaryLabel,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$$formattedBalanceMain',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.37,
                          color: AppColors.label,
                          height: 1.21,
                        ),
                      ),
                      Text('.$balanceDecimal', style: AppTextStyles.title2),
                      const SizedBox(width: 6),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'MXN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.24,
                            color: AppColors.secondaryLabel,
                            height: 1.33,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        weeklyIncome >= 0
                            ? CupertinoIcons.arrow_up_right
                            : CupertinoIcons.arrow_down_right,
                        size: 12,
                        color: weeklyIncome >= 0
                            ? AppColors.systemGreen
                            : AppColors.systemRed,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        weeklyText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.08,
                          color: weeklyIncome >= 0
                              ? AppColors.systemGreen
                              : AppColors.systemRed,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ),
                  // Cash/Bank toggle removed per user request
                  // const Padding(
                  //   padding: EdgeInsets.symmetric(vertical: 16),
                  //   child: ColoredBox(
                  //     color: AppColors.separator,
                  //     child: SizedBox(height: 0.5, width: double.infinity),
                  //   ),
                  // ),
                  // _buildCashBankToggle(dataProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Cash/Bank toggle removed
}
