import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Detalle del Gasto')),
      child: SafeArea(
        child: Center(
          child: Text(
            'Expense Detail Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.label,
            ),
          ),
        ),
      ),
    );
  }
}
