import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../models/account_model.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';
import '../screens/add_bank_account_screen.dart';
import '../screens/add_cash_account_screen.dart';
import '../screens/add_investment_screen.dart';
import '../screens/account_movements_screen.dart';

class CuentaScreen extends StatefulWidget {
  final ScrollController scrollController;
  const CuentaScreen({super.key, required this.scrollController});

  @override
  State<CuentaScreen> createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  @override
  void initState() {
    super.initState();
    _blob1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _blob2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _blob1Anim = CurvedAnimation(
      parent: _blob1Controller,
      curve: Curves.easeInOut,
    );
    _blob2Anim = CurvedAnimation(
      parent: _blob2Controller,
      curve: Curves.easeInOut,
    );

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _appearController.forward();
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // ── Background blobs ────────────────────────────────────────────────
        RepaintBoundary(
          child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
        ),

        // ── Scrollable content ──────────────────────────────────────────────
        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 76, bottom: 100),
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: const Column(
                  children: [
                    _NetWorthCard(),
                    SizedBox(height: 24),
                    _BankAccountsSection(),
                    SizedBox(height: 16),
                    _CashSection(),
                    SizedBox(height: 16),
                    _InvestmentsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Frosted header chrome ───────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(child: _buildHeaderChrome(topPadding)),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.only(
              top: topPadding + 10,
              bottom: 20,
              left: 16,
              right: 8,
            ),
            child: const HeaderRow(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderChrome(double topPadding) {
    return SizedBox(
      height: topPadding + 66.0,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.frostedBlue, Color(0x00070D1A)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Net Worth Card ───────────────────────────────────────────────────────────

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        final totalBalance = data.totalBalance;
        final bankAccounts = data.accounts
            .where((a) => a.type == AccountType.bank)
            .toList();
        final cashAccounts = data.accounts
            .where((a) => a.type == AccountType.cash)
            .toList();
        final investmentAccounts = data.accounts
            .where((a) => a.type == AccountType.investment)
            .toList();

        final bankTotal = bankAccounts.fold(0.0, (sum, a) => sum + a.balance);
        final cashTotal = cashAccounts.fold(0.0, (sum, a) => sum + a.balance);
        final investmentTotal = investmentAccounts.fold(
          0.0,
          (sum, a) => sum + a.balance,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.white07),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PATRIMONIO NETO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: AppColors.secondaryLabel,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_formatCurrency(totalBalance)}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.label,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const ColoredBox(
                    color: AppColors.separator,
                    child: SizedBox(height: 0.5, width: double.infinity),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _NetWorthPill(
                        label: 'BANCOS',
                        value: '\$${_formatCurrency(bankTotal)}',
                        color: AppColors.systemBlue,
                      ),
                      const SizedBox(width: 10),
                      _NetWorthPill(
                        label: 'EFECTIVO',
                        value: '\$${_formatCurrency(cashTotal)}',
                        color: AppColors.systemGreen,
                      ),
                      const SizedBox(width: 10),
                      _NetWorthPill(
                        label: 'INVERSIONES',
                        value: '\$${_formatCurrency(investmentTotal)}',
                        color: AppColors.systemPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 0) {
      return amount
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return amount.toStringAsFixed(2);
  }
}

class _NetWorthPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NetWorthPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: color,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared: section card shell ───────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle; // optional total amount shown under the label
  final String? badge; // optional count badge, e.g. "2 cuentas"
  final Color badgeColor;
  final VoidCallback onAdd;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor = AppColors.systemBlue,
    required this.onAdd,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 0),
              child: Row(
                children: [
                  // Section label (Expanded so add button never overflows)
                  const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.label,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (badge != null) ...[
                                const SizedBox(width: 10),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      badge!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Add button — tight, no extra padding
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(36, 36),
                    onPressed: onAdd,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.systemBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          CupertinoIcons.add,
                          color: AppColors.systemBlue,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const ColoredBox(
              color: AppColors.separator,
              child: SizedBox(height: 0.5, width: double.infinity),
            ),

            ...children,
          ],
        ),
      ),
    );
  }
}

// ─── Shared: inset row separator ─────────────────────────────────────────────

class _RowSeparator extends StatelessWidget {
  const _RowSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: ColoredBox(
        color: AppColors.separator,
        child: SizedBox(height: 0.5, width: double.infinity),
      ),
    );
  }
}

// ─── Shared: empty state ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.tray,
            color: AppColors.tertiaryLabel,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryLabel,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bank Accounts Section ────────────────────────────────────────────────────

class _BankAccountsSection extends StatelessWidget {
  const _BankAccountsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        final bankAccounts = data.accounts
            .where((a) => a.type == AccountType.bank)
            .toList();
        final totalBalance = bankAccounts.fold(
          0.0,
          (sum, a) => sum + a.balance,
        );

        return _SectionCard(
          title: 'CUENTAS BANCARIAS',
          subtitle: '\$${_formatCurrency(totalBalance)}',
          badge:
              '${bankAccounts.length} ${bankAccounts.length == 1 ? 'cuenta' : 'cuentas'}',
          badgeColor: AppColors.systemBlue,
          onAdd: () => Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const AddBankAccountScreen()),
          ),
          children: bankAccounts.isEmpty
              ? [const _EmptyState(message: 'Conecta tu primer banco')]
              : [
                  for (int i = 0; i < bankAccounts.length; i++) ...[
                    _BankAccountRow(account: bankAccounts[i]),
                    if (i < bankAccounts.length - 1) const _RowSeparator(),
                  ],
                  const SizedBox(height: 4),
                ],
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _BankAccountRow extends StatelessWidget {
  final AccountModel account;

  const _BankAccountRow({required this.account});

  @override
  Widget build(BuildContext context) {
    final isCredit = account.bankSubtype == BankAccountSubtype.credit;
    final subtypeColor = isCredit
        ? AppColors.systemPurple
        : AppColors.systemBlue;
    final subtypeIcon = isCredit
        ? CupertinoIcons.creditcard
        : CupertinoIcons.creditcard_fill;
    final subtypeLabel = isCredit ? 'Crédito' : 'Débito';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AccountMovementsScreen(
              accountId: account.id!,
              accountName: account.name,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: subtypeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(subtypeIcon, color: subtypeColor, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label,
                          letterSpacing: -0.2,
                          height: 1.33,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: subtypeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subtypeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: subtypeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isCredit
                              ? AppColors.systemPurple
                              : AppColors.systemGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          isCredit
                              ? _buildCreditSubtitle(account)
                              : 'Sincronizado · ${account.accountNumber ?? '••••'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel,
                            height: 1.33,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatCurrency(account.balance)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                    letterSpacing: -0.2,
                    height: 1.33,
                  ),
                ),
                if (isCredit && (account.creditLimit ?? 0) > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${((account.balance / account.creditLimit!) * 100).toStringAsFixed(0)}% usado',
                    style: TextStyle(
                      fontSize: 11,
                      color: account.balance > account.creditLimit! * 0.8
                          ? AppColors.systemRed
                          : AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.tertiaryLabel,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  String _buildCreditSubtitle(AccountModel account) {
    final parts = <String>[];
    if (account.creditLimit != null && account.creditLimit! > 0) {
      parts.add('\$${_formatCurrency(account.creditLimit!)}');
    }
    if (account.cutOffDay != null) {
      parts.add('Corte día ${account.cutOffDay}');
    }
    if (account.paymentDay != null) {
      parts.add('Pago día ${account.paymentDay}');
    }
    return parts.isEmpty ? account.accountNumber ?? '••••' : parts.join(' · ');
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// ─── Cash Section ─────────────────────────────────────────────────────────────

class _CashSection extends StatelessWidget {
  const _CashSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        final cashAccounts = data.accounts
            .where((a) => a.type == AccountType.cash)
            .toList();
        final totalBalance = cashAccounts.fold(
          0.0,
          (sum, a) => sum + a.balance,
        );

        return _SectionCard(
          title: 'MI EFECTIVO',
          subtitle: '\$${_formatCurrency(totalBalance)}',
          badge:
              '${cashAccounts.length} ${cashAccounts.length == 1 ? 'cartera' : 'carteras'}',
          badgeColor: AppColors.systemGreen,
          onAdd: () => Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const AddCashAccountScreen()),
          ),
          children: cashAccounts.isEmpty
              ? [const _EmptyState(message: 'Agrega tu primera cartera')]
              : [
                  for (int i = 0; i < cashAccounts.length; i++) ...[
                    _CashRow(account: cashAccounts[i]),
                    if (i < cashAccounts.length - 1) const _RowSeparator(),
                  ],
                  const SizedBox(height: 4),
                ],
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _CashRow extends StatelessWidget {
  final AccountModel account;

  const _CashRow({required this.account});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AccountMovementsScreen(
              accountId: account.id!,
              accountName: account.name,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.systemGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  CupertinoIcons.money_dollar,
                  color: AppColors.systemGreen,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                account.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label,
                  letterSpacing: -0.2,
                  height: 1.33,
                ),
              ),
            ),
            Text(
              '\$${_formatCurrency(account.balance)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.label,
                letterSpacing: -0.2,
                height: 1.33,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.tertiaryLabel,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// ─── Investments Section ──────────────────────────────────────────────────────

class _InvestmentsSection extends StatelessWidget {
  const _InvestmentsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        final investmentAccounts = data.accounts
            .where((a) => a.type == AccountType.investment)
            .toList();
        final totalBalance = investmentAccounts.fold(
          0.0,
          (sum, a) => sum + a.balance,
        );

        return _SectionCard(
          title: 'INVERSIONES',
          subtitle: '\$${_formatCurrency(totalBalance)}',
          badge: investmentAccounts.isNotEmpty
              ? '${investmentAccounts.length}'
              : null,
          badgeColor: AppColors.systemPurple,
          onAdd: () => Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const AddInvestmentScreen()),
          ),
          children: investmentAccounts.isEmpty
              ? [const _EmptyState(message: 'Vincula tu primera inversión')]
              : [
                  for (int i = 0; i < investmentAccounts.length; i++) ...[
                    _InvestmentRow(account: investmentAccounts[i]),
                    if (i < investmentAccounts.length - 1)
                      const _RowSeparator(),
                  ],
                  const SizedBox(height: 4),
                ],
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _InvestmentRow extends StatelessWidget {
  final AccountModel account;

  const _InvestmentRow({required this.account});

  @override
  Widget build(BuildContext context) {
    final isPositive = (account.returnRate ?? 0) >= 0;
    final changeColor = isPositive
        ? AppColors.systemGreen
        : AppColors.systemRed;
    final changeIcon = isPositive
        ? CupertinoIcons.arrow_up_right
        : CupertinoIcons.arrow_down_right;
    final returnRate = account.returnRate ?? 0;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AccountMovementsScreen(
              accountId: account.id!,
              accountName: account.name,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.systemPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  CupertinoIcons.graph_square_fill,
                  color: AppColors.systemPurple,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                      letterSpacing: -0.2,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    returnRate > 0
                        ? 'Rendimiento: ${returnRate.toStringAsFixed(1)}%'
                        : 'Sin rendimiento',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatCurrency(account.balance)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                    letterSpacing: -0.2,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(changeIcon, color: changeColor, size: 11),
                    const SizedBox(width: 3),
                    Text(
                      '${returnRate >= 0 ? '+' : ''}${returnRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: changeColor,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.tertiaryLabel,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
