import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class AddCashAccountScreen extends StatefulWidget {
  const AddCashAccountScreen({super.key});

  @override
  State<AddCashAccountScreen> createState() => _AddCashAccountScreenState();
}

class _AddCashAccountScreenState extends State<AddCashAccountScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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
      final account = AccountModel(
        name: _nameController.text.trim(),
        accountNumber: null,
        balance: double.parse(_balanceController.text.trim()),
        type: AccountType.cash,
        createdAt: DateTime.now(),
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
        middle: const Text('Agregar Cuenta de Efectivo'),
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
              icon: CupertinoIcons.money_dollar_circle,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _balanceController,
              placeholder: 'Saldo actual',
              icon: CupertinoIcons.money_dollar_circle,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefix: const Text(
                '\$ ',
                style: TextStyle(color: AppColors.label),
              ),
            ),
          ],
        ),
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
        color: AppColors.white05,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white10),
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
}
