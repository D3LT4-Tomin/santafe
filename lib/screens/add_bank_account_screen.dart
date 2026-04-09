import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, LinearProgressIndicator;
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  final _creditLimitController = TextEditingController(text: '0');
  BankAccountSubtype _subtype = BankAccountSubtype.debit;
  int _cutOffDay = 25;
  int _paymentDay = 10;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return 'El nombre de la cuenta es obligatorio';
    }
    if (_balanceController.text.trim().isEmpty) {
      return 'El saldo es obligatorio';
    }
    final balance = double.tryParse(_balanceController.text.trim());
    if (balance == null) return 'El saldo debe ser un número válido';
    if (balance < 0) return 'El saldo no puede ser negativo';

    if (_subtype == BankAccountSubtype.credit) {
      final limit = double.tryParse(_creditLimitController.text.trim());
      if (limit == null || limit <= 0) {
        return 'Ingresa un límite de crédito válido';
      }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? accountNumber;
      final numberText = _numberController.text.trim();
      if (numberText.isNotEmpty) {
        final last4 = numberText.length > 4
            ? numberText.substring(numberText.length - 4)
            : numberText;
        accountNumber = '****$last4';
      }

      double? creditLimit;
      int? cutOffDay;
      int? paymentDay;
      if (_subtype == BankAccountSubtype.credit) {
        creditLimit = double.tryParse(_creditLimitController.text.trim()) ?? 0;
        cutOffDay = _cutOffDay;
        paymentDay = _paymentDay;
      }

      final account = AccountModel(
        name: _nameController.text.trim(),
        accountNumber: accountNumber,
        balance: double.parse(_balanceController.text.trim()),
        type: AccountType.bank,
        createdAt: DateTime.now(),
        bankSubtype: _subtype,
        creditLimit: creditLimit,
        cutOffDay: cutOffDay,
        paymentDay: paymentDay,
      );

      final dataProvider = context.read<DataProvider>();
      await dataProvider.addAccount(account);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error al guardar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Agregar Cuenta Bancaria'),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _save,
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _nameController,
              placeholder: 'Nombre de la cuenta',
              icon: CupertinoIcons.building_2_fill,
            ),
            const SizedBox(height: 16),
            _buildAccountTypeSelector(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _numberController,
              placeholder: 'Últimos 4 dígitos de la tarjeta',
              icon: CupertinoIcons.number,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildMoneyField(
              controller: _balanceController,
              placeholder: '0.00',
              helperText: _subtype == BankAccountSubtype.credit
                  ? 'DEUDA ACTUAL'
                  : 'SALDO ACTUAL',
              icon: _subtype == BankAccountSubtype.credit
                  ? CupertinoIcons.arrow_down_circle
                  : CupertinoIcons.money_dollar_circle,
              iconColor: _subtype == BankAccountSubtype.credit
                  ? AppColors.systemRed
                  : AppColors.systemGreen,
            ),
            if (_subtype == BankAccountSubtype.credit) ...[
              const SizedBox(height: 16),
              _buildMoneyField(
                controller: _creditLimitController,
                placeholder: '0.00',
                helperText: 'LÍMITE DE CRÉDITO',
                icon: CupertinoIcons.creditcard,
                iconColor: AppColors.systemPurple,
              ),
              const SizedBox(height: 16),
              _buildDateSelectors(),
              const SizedBox(height: 12),
              _buildCreditInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _subtype = BankAccountSubtype.debit),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _subtype == BankAccountSubtype.debit
                      ? AppColors.systemGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.creditcard_fill,
                      size: 18,
                      color: _subtype == BankAccountSubtype.debit
                          ? Colors.white
                          : AppColors.secondaryLabel,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Débito',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _subtype == BankAccountSubtype.debit
                            ? Colors.white
                            : AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _subtype = BankAccountSubtype.credit),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _subtype == BankAccountSubtype.credit
                      ? AppColors.systemPurple
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.creditcard,
                      size: 18,
                      color: _subtype == BankAccountSubtype.credit
                          ? Colors.white
                          : AppColors.secondaryLabel,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Crédito',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _subtype == BankAccountSubtype.credit
                            ? Colors.white
                            : AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showDayPicker(isCutOff: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.calendar,
                    color: AppColors.secondaryLabel,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de corte',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                      Text(
                        'Día $_cutOffDay',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showDayPicker(isCutOff: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.money_dollar_circle,
                    color: AppColors.secondaryLabel,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de pago',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                      Text(
                        'Día $_paymentDay',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDayPicker({required bool isCutOff}) {
    final currentDay = isCutOff ? _cutOffDay : _paymentDay;
    final days = List.generate(28, (i) => i + 1);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: AppColors.secondaryBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    isCutOff ? 'Fecha de corte' : 'Fecha de pago',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Aceptar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: currentDay - 1,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    if (isCutOff) {
                      _cutOffDay = days[index];
                    } else {
                      _paymentDay = days[index];
                    }
                  });
                },
                children: days
                    .map(
                      (day) => Center(
                        child: Text(
                          'Día $day',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.label,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditInfo() {
    final limit = double.tryParse(_creditLimitController.text.trim()) ?? 0;
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0;
    final available = limit - balance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.systemPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.systemPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.info_circle_fill,
                color: AppColors.systemPurple,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Crédito disponible',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.systemPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${available.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
            ),
          ),
          if (limit > 0) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: balance / limit,
                backgroundColor: AppColors.cardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  balance > limit * 0.8
                      ? AppColors.systemRed
                      : AppColors.systemPurple,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    Widget? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(icon, color: AppColors.secondaryLabel, size: 20),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              prefix: prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: prefix,
                    )
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: const BoxDecoration(),
              style: const TextStyle(color: AppColors.label),
              placeholderStyle: const TextStyle(color: AppColors.tertiaryLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyField({
    required TextEditingController controller,
    required String placeholder,
    required String helperText,
    required IconData icon,
    Color? iconColor,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: (iconColor ?? AppColors.systemGreen).withValues(
                  alpha: 0.8,
                ),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.secondaryLabel,
                  size: 20,
                ),
              ),
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: placeholder,
                  keyboardType:
                      keyboardType ??
                      const TextInputType.numberWithOptions(decimal: true),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '\$ ',
                      style: TextStyle(color: AppColors.label, fontSize: 18),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(),
                  style: const TextStyle(color: AppColors.label, fontSize: 18),
                  placeholderStyle: const TextStyle(
                    color: AppColors.tertiaryLabel,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
