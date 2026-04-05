import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  bool _isExpense = true;
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Comida';
  String? _selectedAccountId;
  String? _selectedAccountName;
  bool _isLoading = false;

  final List<String> _expenseCategories = [
    'Comida',
    'Transporte',
    'Suscripción',
    'Salud',
    'Entretenimiento',
    'Servicios',
    'Varios',
  ];

  final List<String> _incomeCategories = [
    'Salario',
    'Freelance',
    'Inversión',
    'Bono',
    'Venta',
    'Otro',
  ];

  List<String> get _currentCategories =>
      _isExpense ? _expenseCategories : _incomeCategories;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAccount();
    });
  }

  void _initializeAccount() {
    final dataProvider = context.read<DataProvider>();
    if (dataProvider.accounts.isNotEmpty) {
      setState(() {
        _selectedAccountId = dataProvider.accounts.first.id;
        _selectedAccountName = dataProvider.accounts.first.name;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    final description = _descriptionController.text.trim();
    final amountText = _amountController.text.trim();

    if (description.isEmpty) {
      _showError('Ingresa una descripción');
      return;
    }

    if (amountText.isEmpty) {
      _showError('Ingresa un monto');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Ingresa un monto válido');
      return;
    }

    if (_selectedAccountId == null) {
      _showError('Selecciona una cuenta');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = TransactionModel(
        title: description,
        subtitle:
            '$_selectedCategory · ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        amount: _isExpense ? -amount : amount,
        category: _selectedCategory,
        origin: _selectedAccountName ?? 'Cuenta',
        tipo: _isExpense ? 'egreso' : 'ingreso',
        createdAt: DateTime.now(),
        accountId: _selectedAccountId,
        accountName: _selectedAccountName,
      );

      final dataProvider = context.read<DataProvider>();
      await dataProvider.addTransaction(transaction);

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
    final bottomPadding =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x4D8E8E93),
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: SizedBox(width: 36, height: 5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.systemBlue),
                        ),
                      ),
                      const Text(
                        'Agregar',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _isLoading ? null : _saveTransaction,
                        child: _isLoading
                            ? const CupertinoActivityIndicator()
                            : const Text(
                                'Listo',
                                style: TextStyle(
                                  color: AppColors.systemBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Container(height: 0.5, color: AppColors.separator),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isExpense = true;
                            _selectedCategory = 'Comida';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isExpense
                                  ? AppColors.systemRed
                                  : AppColors.white05,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isExpense
                                    ? AppColors.systemRed
                                    : AppColors.white10,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Gasto',
                                style: TextStyle(
                                  color: _isExpense
                                      ? Colors.white
                                      : AppColors.secondaryLabel,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isExpense = false;
                            _selectedCategory = 'Salario';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isExpense
                                  ? AppColors.systemGreen
                                  : AppColors.white05,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !_isExpense
                                    ? AppColors.systemGreen
                                    : AppColors.white10,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Ingreso',
                                style: TextStyle(
                                  color: !_isExpense
                                      ? Colors.white
                                      : AppColors.secondaryLabel,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoTextField(
                    controller: _descriptionController,
                    placeholder: 'Descripción',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppColors.label,
                    ),
                    placeholderStyle: const TextStyle(
                      fontSize: 17,
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoTextField(
                    controller: _amountController,
                    placeholder: '\$0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                    ),
                    placeholderStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white05,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Categoría',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showCategoryPicker(),
                          child: Row(
                            children: [
                              Text(
                                _selectedCategory,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.label,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                CupertinoIcons.chevron_down,
                                size: 14,
                                color: AppColors.secondaryLabel,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white05,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Cuenta',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showAccountPicker(dataProvider),
                          child: Row(
                            children: [
                              Text(
                                _selectedAccountName ?? 'Seleccionar',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.label,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                CupertinoIcons.chevron_down,
                                size: 14,
                                color: AppColors.secondaryLabel,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: AppColors.secondaryBackground,
        child: CupertinoPicker(
          itemExtent: 40,
          onSelectedItemChanged: (index) {
            setState(() {
              _selectedCategory = _currentCategories[index];
            });
          },
          children: _currentCategories
              .map(
                (cat) => Center(
                  child: Text(
                    cat,
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
    );
  }

  void _showAccountPicker(DataProvider dataProvider) {
    if (dataProvider.accounts.isEmpty) {
      _showError('No tienes cuentas. Agrega una cuenta primero.');
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: AppColors.secondaryBackground,
        child: CupertinoPicker(
          itemExtent: 40,
          onSelectedItemChanged: (index) {
            final account = dataProvider.accounts[index];
            setState(() {
              _selectedAccountId = account.id;
              _selectedAccountName = account.name;
            });
          },
          children: dataProvider.accounts
              .map(
                (account) => Center(
                  child: Text(
                    account.name,
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
    );
  }
}
