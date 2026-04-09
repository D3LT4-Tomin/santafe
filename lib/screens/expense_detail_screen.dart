import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const ExpenseDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.tipo == 'egreso';
    final amountColor = isExpense ? AppColors.systemRed : AppColors.systemGreen;
    final amountPrefix = isExpense ? '-' : '+';
    final amountAbs = transaction.amount.abs().toStringAsFixed(2);
    final formattedAbs = amountAbs.split('.');
    final amountMain = formattedAbs[0];
    final amountDecimal = formattedAbs.length > 1 ? formattedAbs[1] : '00';

    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          isExpense ? 'Detalle del Gasto' : 'Detalle del Ingreso',
          style: AppTextStyles.headline,
        ),
        backgroundColor: AppColors.frostedGreen.withValues(alpha: 0.5),
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardBackground,
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isExpense
                        ? CupertinoIcons.arrow_down_circle_fill
                        : CupertinoIcons.arrow_up_circle_fill,
                    size: 48,
                    color: amountColor,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$amountPrefix\$$amountMain',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.37,
                          color: amountColor,
                          height: 1.21,
                        ),
                      ),
                      Text(
                        '.$amountDecimal',
                        style: AppTextStyles.title2.copyWith(
                          color: amountColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.black07),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Descripción', value: transaction.title),
                  _DetailRow(label: 'Categoría', value: transaction.category),
                  _DetailRow(
                    label: 'Cuenta',
                    value: transaction.accountName ?? transaction.origin,
                  ),
                  _DetailRow(
                    label: 'Fecha',
                    value: _formatDate(transaction.createdAt),
                  ),
                  _DetailRow(
                    label: 'Tipo',
                    value: isExpense ? 'Gasto' : 'Ingreso',
                    valueColor: amountColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showDeleteConfirmation(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.systemRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.systemRed.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.trash,
                      color: AppColors.systemRed,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Eliminar transacción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.systemRed,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Eliminar transacción'),
        content: Text(
          '¿Estás seguro de eliminar "${transaction.title}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteTransaction(context);
            },
            child: const Text('Eliminar'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    try {
      final dataProvider = context.read<DataProvider>();
      await dataProvider.deleteTransaction(transaction.id!);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo eliminar: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.subheadline.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.label,
            ),
          ),
        ],
      ),
    );
  }
}
