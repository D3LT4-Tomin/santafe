import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
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
        RepaintBoundary(
          child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 76, bottom: 80),
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
                    SizedBox(height: 28),
                    _BankAccountsSection(),
                    SizedBox(height: 28),
                    _CashSection(),
                    SizedBox(height: 28),
                    _InvestmentsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
              const Text(
                '\$145,410.25',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.label,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(
                    CupertinoIcons.arrow_up_right,
                    color: AppColors.systemGreen,
                    size: 13,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+\$3,240.00',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.systemGreen,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'este mes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const ColoredBox(
                color: AppColors.separator,
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  _NetWorthPill(
                    label: 'Bancos',
                    value: '\$132,080',
                    color: AppColors.systemBlue,
                  ),
                  SizedBox(width: 10),
                  _NetWorthPill(
                    label: 'Efectivo',
                    value: '\$6,250',
                    color: AppColors.systemGreen,
                  ),
                  SizedBox(width: 10),
                  _NetWorthPill(
                    label: 'Inversiones',
                    value: '\$12,430',
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.label,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared: section card shell ───────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
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
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onAdd, minimumSize: Size(36, 36),
                    child: const Icon(
                      CupertinoIcons.add,
                      color: AppColors.systemBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.tray,
            color: AppColors.tertiaryLabel,
            size: 28,
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

// ─── Bank Accounts Section ────────────────────────────────────────────────────
class _BankAccountsSection extends StatelessWidget {
  const _BankAccountsSection();

  @override
  Widget build(BuildContext context) {
    // Replace with real data / empty list to see empty state
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
      onAdd: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const AddBankAccountScreen(),
          ),
        );
      },
      children: accounts.isEmpty
          ? [const _EmptyState(message: 'Conecta tu primer banco')]
          : [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    const Text(
                      '\$132,080.00',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.label,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.systemBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '2 cuentas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.systemBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const ColoredBox(
                color: AppColors.separator,
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              for (int i = 0; i < accounts.length; i++) ...[
                _BankAccountRow(
                  bankName: accounts[i].name,
                  accountNumber: accounts[i].number,
                  balance: accounts[i].balance,
                  logoUrl: accounts[i].logo,
                ),
                if (i < accounts.length - 1) const _RowSeparator(),
              ],
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
            builder: (context) => AccountMovementsScreen(
              accountId: bankName,
              accountName: bankName,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  logoUrl,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    CupertinoIcons.building_2_fill,
                    color: AppColors.systemBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.systemBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
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
            Text(
              balance,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.label,
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
      onAdd: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const AddCashAccountScreen(),
          ),
        );
      },
      children: wallets.isEmpty
          ? [const _EmptyState(message: 'Agrega tu primera cartera')]
          : [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    const Text(
                      '\$6,250.00',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.label,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.systemGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '2 carteras',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.systemGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const ColoredBox(
                color: AppColors.separator,
                child: SizedBox(height: 0.5, width: double.infinity),
              ),
              for (int i = 0; i < wallets.length; i++) ...[
                _CashRow(
                  name: wallets[i].name,
                  amount: wallets[i].amount,
                  icon: wallets[i].icon,
                  color: wallets[i].color,
                ),
                if (i < wallets.length - 1) const _RowSeparator(),
              ],
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
            builder: (context) =>
                AccountMovementsScreen(accountId: name, accountName: name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label,
                  height: 1.33,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.label,
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
        icon: CupertinoIcons.arrow_up_arrow_down_circle_fill,
        color: AppColors.systemOrange,
      ),
      (
        name: 'Acciones',
        subtitle: 'Mercado de valores',
        balance: '\$8,310',
        change: '+14.2%',
        icon: CupertinoIcons.graph_square_fill,
        color: AppColors.systemPurple,
      ),
    ];

    return _SectionCard(
      title: 'INVERSIONES',
      onAdd: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const AddInvestmentScreen()),
        );
      },
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            children: [
              const Text(
                '\$12,430.25',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.label,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.systemGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      CupertinoIcons.arrow_up_right,
                      color: AppColors.systemGreen,
                      size: 11,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '+14.2%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.systemGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const ColoredBox(
          color: AppColors.separator,
          child: SizedBox(height: 0.5, width: double.infinity),
        ),
        if (investments.isEmpty)
          const _EmptyState(message: 'Vincula tu primera inversión')
        else ...[
          for (int i = 0; i < investments.length; i++) ...[
            _InvestmentRow(
              name: investments[i].name,
              subtitle: investments[i].subtitle,
              balance: investments[i].balance,
              change: investments[i].change,
              icon: investments[i].icon,
              color: investments[i].color,
            ),
            if (i < investments.length - 1) const _RowSeparator(),
          ],
        ],
      ],
    );
  }
}

class _InvestmentRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final String balance;
  final String change;
  final IconData icon;
  final Color color;

  const _InvestmentRow({
    required this.name,
    required this.subtitle,
    required this.balance,
    required this.change,
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
            builder: (context) =>
                AccountMovementsScreen(accountId: name, accountName: name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.arrow_up_right,
                      color: AppColors.systemGreen,
                      size: 11,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      change,
                      style: const TextStyle(
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
