import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBankSelected = true;

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

        final weeklyPrefix = weeklyIncome >= 0 ? '+' : '';
        final weeklyText =
            '$weeklyPrefix\$${weeklyIncome.toStringAsFixed(0)} esta semana';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.white10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D000000),
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
                        '\$$balanceMain',
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
                        CupertinoIcons.arrow_up_right,
                        size: 12,
                        color: AppColors.systemGreen,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        weeklyText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.08,
                          color: AppColors.systemGreen,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: ColoredBox(
                      color: AppColors.separator,
                      child: SizedBox(height: 0.5, width: double.infinity),
                    ),
                  ),
                  _buildCashBankToggle(dataProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCashBankToggle(DataProvider dataProvider) {
    final hasAccounts = dataProvider.accounts.isNotEmpty;

    if (!hasAccounts) {
      return const SizedBox(height: 52);
    }

    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x59000000),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.white08),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                ToggleOption(
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  label: 'Efectivo',
                  selected: !_isBankSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isBankSelected = false);
                  },
                ),
                ToggleOption(
                  icon: CupertinoIcons.building_2_fill,
                  label: 'Banco',
                  selected: _isBankSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isBankSelected = true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ToggleOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 260),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x470A84FF), Color(0x290A84FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0x590A84FF),
                    width: 0.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x330A84FF), blurRadius: 10),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    key: ValueKey('$icon-$selected'),
                    size: 17,
                    color: selected
                        ? AppColors.systemBlue
                        : const Color(0x998E8E93),
                  ),
                ),
                const SizedBox(width: 7),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.3,
                    color: selected ? AppColors.label : const Color(0x998E8E93),
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
