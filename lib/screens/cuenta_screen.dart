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
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
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
            child: const Column(
              children: [
                _BankAccountsSection(),
                SizedBox(height: 28),
                _CashSectionsSection(),
              ],
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
            child: HeaderRow(searchBarOpacity: _searchBarOpacity),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              _BankAccountCard(
                bankName: 'Banco de Chile',
                accountNumber: '•••• 5678',
                balance: '\$245,670',
              ),
              const SizedBox(height: 12),
              _BankAccountCard(
                bankName: 'Scotiabank',
                accountNumber: '•••• 1234',
                balance: '\$89,230',
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.plus_circle,
                      color: AppColors.systemBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Agregar cuenta bancaria',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.systemBlue,
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white07),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CAJAS DE EFECTIVO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.secondaryLabel,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 16),
              _CashSectionCard(name: 'Efectivo Personal', amount: '\$25,000'),
              const SizedBox(height: 12),
              _CashSectionCard(name: 'Propinas', amount: '\$8,500'),
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.plus_circle,
                      color: AppColors.systemBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Crear nueva caja',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.systemBlue,
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bank Account Card ──────────────────────────────────────────────────────────
class _BankAccountCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String balance;

  const _BankAccountCard({
    required this.bankName,
    required this.accountNumber,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.separator),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.creditcard_fill,
              color: AppColors.systemBlue,
              size: 20,
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
                Text(
                  accountNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            balance,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
              height: 1.29,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cash Section Card ──────────────────────────────────────────────────────────
class _CashSectionCard extends StatelessWidget {
  final String name;
  final String amount;

  const _CashSectionCard({required this.name, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.separator),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.money_dollar_circle_fill,
              color: AppColors.systemGreen,
              size: 20,
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
                height: 1.33,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
              height: 1.29,
            ),
          ),
        ],
      ),
    );
  }
}
