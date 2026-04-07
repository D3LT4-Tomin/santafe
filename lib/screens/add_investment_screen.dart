import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _returnController = TextEditingController(text: '0');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return 'El nombre de la inversión es obligatorio';
    }
    if (_amountController.text.trim().isEmpty) {
      return 'El monto es obligatorio';
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return 'El monto debe ser un número válido';
    if (amount <= 0) return 'El monto debe ser mayor a 0';

    if (_returnController.text.trim().isNotEmpty) {
      final returnRate = double.tryParse(_returnController.text.trim());
      if (returnRate == null) return 'El rendimiento debe ser un número válido';
      if (returnRate < 0) return 'El rendimiento no puede ser negativo';
      if (returnRate > 100) return 'El rendimiento no puede exceder 100%';
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
      final amount = double.parse(_amountController.text.trim());
      double? returnRate;
      if (_returnController.text.trim().isNotEmpty) {
        returnRate = double.parse(_returnController.text.trim());
      }

      final account = AccountModel(
        name: _nameController.text.trim(),
        balance: amount,
        type: AccountType.investment,
        returnRate: returnRate,
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
        middle: const Text('Agregar Inversión'),
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
            // Icono de inversión
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.systemGreen. withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.systemGreen. withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.systemGreen. withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      size: 40,
                      color: AppColors.systemGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Agregar Inversión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Registra tus inversiones para seguir su rendimiento',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nombre de la inversión
            _buildTextField(
              controller: _nameController,
              placeholder: 'Nombre de la inversión',
              icon: CupertinoIcons.tag,
              example: 'Ej: CETES, Fondos de inversión',
            ),

            const SizedBox(height: 16),

            // Monto invertido
            _buildTextField(
              controller: _amountController,
              placeholder: 'Monto invertido',
              icon: CupertinoIcons.money_dollar_circle,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefix: const Text(
                '\$ ',
                style: TextStyle(color: AppColors.label),
              ),
              example: 'Ej: 10000',
            ),

            const SizedBox(height: 16),

            // Rendimiento esperado (opcional)
            _buildTextField(
              controller: _returnController,
              placeholder: 'Rendimiento esperado % (opcional)',
              icon: CupertinoIcons.chart_pie,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefix: const Text('', style: TextStyle(color: AppColors.label)),
              suffix: const Text(
                ' %',
                style: TextStyle(color: AppColors.secondaryLabel),
              ),
              example: 'Ej: 8.5',
            ),

            const SizedBox(height: 32),

            // Info adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.systemBlue. withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.systemBlue. withValues(alpha: 0.15),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    color: AppColors.systemBlue,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Las inversiones se mostrarán en tu patrimonio neto y podrás seguir su rendimiento.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryLabel,
                        height: 1.4,
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    Widget? prefix,
    Widget? suffix,
    String? example,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                  suffix: suffix != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: suffix,
                        )
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(),
                  style: const TextStyle(color: AppColors.label),
                  placeholderStyle: const TextStyle(
                    color: AppColors.tertiaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (example != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              example,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.tertiaryLabel,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
