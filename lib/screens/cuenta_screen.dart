import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
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

  final _searchBarOpacity = ValueNotifier<double>(1.0);

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
    _blob1Anim =
        CurvedAnimation(parent: _blob1Controller, curve: Curves.easeInOut);
    _blob2Anim =
        CurvedAnimation(parent: _blob2Controller, curve: Curves.easeInOut);

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
    _searchBarOpacity.dispose();
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
            child: HeaderRow(
              searchBarOpacity: _searchBarOpacity,
              onSearchPressed: () {},
            ),
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
              // Label
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

              // Amount
              const Text(
                '\$145,410.25',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 6),

              // Delta row
              Row(
                children: const [
                  Icon(
                    CupertinoIcons.arrow_up_right,
                    color: AppColors.systemGreen,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+\$3,240.00',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.systemGreen,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'este mes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Divider
              const ColoredBox(
                color: AppColors.separator,
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              const SizedBox(height: 16),

              // Pills
              const Row(
                children: [
                  _NetWorthPill(
                    label: 'BANCOS',
                    value: '\$132,080',
                    color: AppColors.systemBlue,
                  ),
                  SizedBox(width: 10),
                  _NetWorthPill(
                    label: 'EFECTIVO',
                    value: '\$6,250',
                    color: AppColors.systemGreen,
                  ),
                  SizedBox(width: 10),
                  _NetWorthPill(
                    label: 'INVERSIONES',
                    value: '\$7,080',
                    color: AppColors.systemPurple,
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
          color: color. withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color. withValues(alpha: 0.15)),
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
  final String? subtitle;   // optional total amount shown under the label
  final String? badge;      // optional count badge, e.g. "2 cuentas"
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
                                    color: badgeColor. withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
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
                        color: AppColors.systemBlue. withValues(alpha: 0.10),
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
    const accounts = [
      (
        name: 'BBVA Nómina',
        number: '•••• 5678',
        balance: '\$42,850.00',
        logo: 'https://www.bbva.com/favicon.ico',
      ),
      (
        name: 'Scotiabank',
        number: '•••• 1234',
        balance: '\$89,230.00',
        logo: 'https://www.scotiabank.cl/favicon.ico',
      ),
    ];

    return _SectionCard(
      title: 'CUENTAS BANCARIAS',
      subtitle: '\$132,080.00',
      badge: '${accounts.length} cuentas',
      badgeColor: AppColors.systemBlue,
      onAdd: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const AddBankAccountScreen()),
      ),
      children: accounts.isEmpty
          ? [const _EmptyState(message: 'Conecta tu primer banco')]
          : [
              for (int i = 0; i < accounts.length; i++) ...[
                _BankAccountRow(
                  bankName: accounts[i].name,
                  accountNumber: accounts[i].number,
                  balance: accounts[i].balance,
                  logoUrl: accounts[i].logo,
                ),
                if (i < accounts.length - 1) const _RowSeparator(),
              ],
              const SizedBox(height: 4),
            ],
    );
  }
}

class _BankAccountRow extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String balance;
  final String logoUrl;

  const _BankAccountRow({
    required this.bankName,
    required this.accountNumber,
    required this.balance,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AccountMovementsScreen(
              accountId: bankName,
              accountName: bankName,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Bank logo container
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      CupertinoIcons.building_2_fill,
                      color: AppColors.systemBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + sync status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
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
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.systemGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Sincronizado · $accountNumber',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryLabel,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Balance + chevron
            Text(
              balance,
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
}

// ─── Cash Section ─────────────────────────────────────────────────────────────

class _CashSection extends StatelessWidget {
  const _CashSection();

  @override
  Widget build(BuildContext context) {
    const wallets = [
      (
        name: 'Cartera Principal',
        amount: '\$1,250.00',
        icon: CupertinoIcons.money_dollar,
        color: AppColors.systemBlue,
      ),
      (
        name: 'Bajo el colchón',
        amount: '\$5,000.00',
        icon: CupertinoIcons.square_stack,
        color: AppColors.systemPurple,
      ),
    ];

    return _SectionCard(
      title: 'MI EFECTIVO',
      subtitle: '\$6,250.00',
      badge: '${wallets.length} carteras',
      badgeColor: AppColors.systemGreen,
      onAdd: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const AddCashAccountScreen()),
      ),
      children: wallets.isEmpty
          ? [const _EmptyState(message: 'Agrega tu primera cartera')]
          : [
              for (int i = 0; i < wallets.length; i++) ...[
                _CashRow(
                  name: wallets[i].name,
                  amount: wallets[i].amount,
                  icon: wallets[i].icon,
                  color: wallets[i].color,
                ),
                if (i < wallets.length - 1) const _RowSeparator(),
              ],
              const SizedBox(height: 4),
            ],
    );
  }
}

class _CashRow extends StatelessWidget {
  final String name;
  final String amount;
  final IconData icon;
  final Color color;

  const _CashRow({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) =>
                AccountMovementsScreen(accountId: name, accountName: name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color. withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
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
              amount,
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
}

// ─── Investments Section ──────────────────────────────────────────────────────

class _InvestmentsSection extends StatelessWidget {
  const _InvestmentsSection();

  @override
  Widget build(BuildContext context) {
    const investments = [
      (
        name: 'Cripto',
        subtitle: 'Portafolio digital',
        balance: '\$4,120',
        change: '+8.3%',
        positive: true,
        icon: CupertinoIcons.arrow_up_arrow_down_circle_fill,
        color: AppColors.systemOrange,
      ),
      (
        name: 'Acciones',
        subtitle: 'Mercado de valores',
        balance: '\$8,310',
        change: '+14.2%',
        positive: true,
        icon: CupertinoIcons.graph_square_fill,
        color: AppColors.systemPurple,
      ),
    ];

    return _SectionCard(
      title: 'INVERSIONES',
      subtitle: '\$12,430.25',
      badge: '+14.2%',
      badgeColor: AppColors.systemGreen,
      onAdd: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const AddInvestmentScreen()),
      ),
      children: investments.isEmpty
          ? [const _EmptyState(message: 'Vincula tu primera inversión')]
          : [
              for (int i = 0; i < investments.length; i++) ...[
                _InvestmentRow(
                  name: investments[i].name,
                  subtitle: investments[i].subtitle,
                  balance: investments[i].balance,
                  change: investments[i].change,
                  positive: investments[i].positive,
                  icon: investments[i].icon,
                  color: investments[i].color,
                ),
                if (i < investments.length - 1) const _RowSeparator(),
              ],
              const SizedBox(height: 4),
            ],
    );
  }
}

class _InvestmentRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final String balance;
  final String change;
  final bool positive;
  final IconData icon;
  final Color color;

  const _InvestmentRow({
    required this.name,
    required this.subtitle,
    required this.balance,
    required this.change,
    required this.positive,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor =
        positive ? AppColors.systemGreen : AppColors.systemRed;
    final changeIcon = positive
        ? CupertinoIcons.arrow_up_right
        : CupertinoIcons.arrow_down_right;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) =>
                AccountMovementsScreen(accountId: name, accountName: name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color. withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                    subtitle,
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
                  balance,
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
                      change,
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
}
