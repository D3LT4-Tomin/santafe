import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';
import '../widgets/buttons.dart';

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
    _searchBarOpacity.dispose();
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

        // ── Scrollable content ────────────────────────────────────
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
                child: Column(
                  children: const [
                    _AccountsHeader(),
                    SizedBox(height: 28),
                    _BankAccountsSection(),
                    SizedBox(height: 28),
                    _CashSectionsSection(),
                    SizedBox(height: 28),
                    _InvestmentsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Header ───────────────────────────────────────────────
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
                  stops: [0.0, 1.0],
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

// ─── Accounts Header ──────────────────────────────────────────────────────────────
class _AccountsHeader extends StatelessWidget {
  const _AccountsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TU PATRIMONIO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.systemBlue.withOpacity(0.6),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestionar Activos',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.label,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bank Accounts Section ──────────────────────────────────────────────────────
class _BankAccountsSection extends StatelessWidget {
  const _BankAccountsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(24), // More rounded corners
          border: Border.all(color: AppColors.white07),
        ),
        child: Stack(
          children: [
            // Decorative circle element
            Positioned(
              top: -16,
              right: -16,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.systemBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CUENTAS BANCARIAS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: AppColors.secondaryLabel,
                          height: 1.33,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text(
                          'Conectar Banco',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: AppColors.systemBlue,
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _EnhancedBankAccountCard(
                    bankName: 'BBVA Nómina',
                    accountNumber: '•••• 5678',
                    balance: '\$42,850.00',
                    logoUrl: 'https://www.bbva.com/favicon.ico',
                  ),
                  const SizedBox(height: 12),
                  _EnhancedBankAccountCard(
                    bankName: 'Scotiabank',
                    accountNumber: '•••• 1234',
                    balance: '\$89,230',
                    logoUrl: 'https://www.scotiabank.cl/favicon.ico',
                  ),
                  const SizedBox(height: 16),
                  _ConnectBankButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Enhanced Bank Account Card ──────────────────────────────────────────────────
class _EnhancedBankAccountCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String balance;
  final String logoUrl;

  const _EnhancedBankAccountCard({
    required this.bankName,
    required this.accountNumber,
    required this.balance,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground,
        borderRadius: BorderRadius.circular(20), // More rounded
        border: Border.all(color: AppColors.separator),
      ),
      child: Stack(
        children: [
          // Decorative element
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            logoUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                CupertinoIcons.building_2_fill,
                                color: AppColors.systemBlue,
                                size: 24,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bankName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.label,
                              height: 1.33,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.systemBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Sincronizado',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.systemBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    CupertinoIcons.ellipsis_vertical,
                    color: AppColors.tertiaryLabel,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Balance disponible',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryLabel,
                  height: 1.33,
                ),
              ),
              Text(
                balance,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.label,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Connect Bank Button ──────────────────────────────────────────────────────────
class _ConnectBankButton extends StatelessWidget {
  const _ConnectBankButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0x1A0A84FF), Color(0x1A409CFF)],
        ),
        border: Border.all(color: AppColors.systemBlue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.systemBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: AppColors.systemBlue,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Conectar Banco',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.systemBlue,
              ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }
}

// ─── Cash Sections Section ──────────────────────────────────────────────────────
class _CashSectionsSection extends StatelessWidget {
  const _CashSectionsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(24), // More rounded corners
          border: Border.all(color: AppColors.white07),
        ),
        child: Stack(
          children: [
            // Decorative circle element
            Positioned(
              top: -16,
              right: -16,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.systemGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MI EFECTIVO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: AppColors.secondaryLabel,
                          height: 1.33,
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.add_circled,
                        color: AppColors.secondaryLabel,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CashWalletCard(
                          name: 'Cartera Principal',
                          amount: '\$1,250.00',
                          icon: CupertinoIcons.money_dollar,
                          color: AppColors.systemBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CashWalletCard(
                          name: 'Bajo el colchón',
                          amount: '\$5,000.00',
                          icon: CupertinoIcons.square_stack,
                          color: AppColors.systemPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Agregar Cartera',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cash Wallet Card ──────────────────────────────────────────────────────────
class _CashWalletCard extends StatelessWidget {
  final String name;
  final String amount;
  final IconData icon;
  final Color color;

  const _CashWalletCard({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground,
        borderRadius: BorderRadius.circular(20), // More rounded
        border: Border.all(color: AppColors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.secondaryLabel,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.label,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Investments Section ──────────────────────────────────────────────────────────
class _InvestmentsSection extends StatelessWidget {
  const _InvestmentsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(24), // More rounded corners
          border: Border.all(color: AppColors.white07),
        ),
        child: Stack(
          children: [
            // Decorative glow element
            Positioned(
              bottom: -32,
              right: -32,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.systemPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.graph_square_fill,
                            color: AppColors.systemPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'INVERSIONES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.secondaryLabel,
                              height: 1.33,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.systemPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Vincular',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: AppColors.systemPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.separator),
                    ),
                    child: Stack(
                      children: [
                        // Decorative glow
                        Positioned(
                          bottom: -20,
                          right: -20,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.systemPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total invertido',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryLabel,
                                        height: 1.33,
                                      ),
                                    ),
                                    Text(
                                      '\$12,430.25',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.label,
                                        height: 1.1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.arrow_up_right,
                                          color: AppColors.systemBlue,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+14.2%',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.systemBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Últimos 30 días',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.secondaryLabel,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Simple line chart mockup
                                Container(
                                  width: 64,
                                  height: 32,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AppColors.systemPurple
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 4,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: AppColors.systemPurple
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 4,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: AppColors.systemPurple
                                              .withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 4,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.systemPurple
                                              .withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.systemPurple
                                              .withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 4,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.systemPurple,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(height: 1, color: AppColors.separator),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cripto',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.tertiaryLabel,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        '\$4,120',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.label,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Acciones',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.tertiaryLabel,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        '\$8,310',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.label,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
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
          ],
        ),
      ),
    );
  }
}
