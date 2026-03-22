import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class AddCashAccountScreen extends StatelessWidget {
  const AddCashAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Agregar Cuenta de Efectivo'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            'Add Cash Account Screen',
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
